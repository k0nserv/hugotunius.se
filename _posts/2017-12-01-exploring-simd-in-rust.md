---
layout: post
title: "Exploring SIMD in Rust"
categories: rust
date: 2017-12-01
description: >
  My experiecne exploring the use of SIMD instructions in Rust to speed up Vector dot products for Raytracing.
---

If you follow me on [Twitter](https://twitter.com/K0nserv) it is unlikely you have missed that I have been building a [Raytracer](http://github.com/k0nserv/rusttracer) in [Rust](https://www.rust-lang.org/en-US/). Unsatisfied with the performance I have been profiling it and considering ways to speed up rendering. Among the techniques I have been interested in are SIMD instructions.

[SIMD](https://en.wikipedia.org/wiki/SIMD), Single Instruction, multiple data, are special CPU instructions in modern CPUs. They enable the processor to compute several values with a single cycle. On Intel platforms these instructions are called SSE for Streaming SMID Extensions.

In my Raytracer the most critical code is the ray-triangle intersection tests. When rendering most scenes a lot of time is spent in this part of code and millions or even billions of tests are performed. Core to the ray-triangle intersection algorithm are vector dots products and cross products. Given this I figured that using SIMD instructions for the dot product would speed up the rendering significantly. It did not and what follows is a summary of why this is.

At the time of writing this is the definition of my `Vector3` datatype

{% highlight rust line %}
pub struct Vector3 {
    pub x: f64,
    pub y: f64,
    pub z: f64,
}
{% endhighlight %}

The dot product of two vectors is the sum of the product of all the components.

{% highlight rust line %}
impl Vector {
  pub fn dot(&self, other: &Self) -> f64 {
      self.x * other.x + self.y * other.y + self.z * other.z
  }
}
{% endhighlight %}


Given my assumption that using SIMD instructions to compute the dot product would improve performance I integrated the [stdsmid](https://docs.rs/stdsimd/0.0.3/stdsimd/) crate and wrote a new implementation of the dot product using SSE.

{% highlight rust line %}
pub struct Vector3 {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    simd_vec: f64x4,
}

#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
#[target_feature = "+sse4.1"]
unsafe fn dot_sse2(a: f64x4, b: f64x4) -> f64 {
    let product = a * b;

    product.extract(0) + product.extract(1) + product.extract(2)
}

// Vector 3 specific
impl Vector3 {
    pub fn dot_sse(&self, other: &Self) -> f64 {
    #[cfg(all(any(target_arch = "x86_64", target_arch = "x86"),
              target_feature = "sse2"))]
        {
            unsafe { dot_sse2(self.simd_vec, other.simd_vec) }
        }
    #[cfg(not(all(any(target_arch = "x86_64", target_arch = "x86"),
              target_feature = "sse2")))]
        {
            self.x * other.x + self.y * other.y + self.z * other.z
        }
    }
{% endhighlight %}

I suspected that creating the required `stdsimd::simd::f64x4` value twice for very dot product would annihilate any performance improvement from the SIMD instructions so I opted to create it when creating the vector itself.

I ran a few benchmarks by rendering the same scene several times. To my surprise I found that the performance degraded by roughly 20%. Somehow the new SIMD version of the code was slower, not faster.

This result confused me. I was sure I had messed up the implementation somehow. While researching I discovered [`_mm_dp_ps`](https://msdn.microsoft.com/en-us/library/bb514054(v=vs.120).aspx), an SIMD instruction designed specifically to compute dot products. Unfortunately this instructions uses 128bit registers and is implemented for single precision floats. I use double precision floats in my raytracer. However I was convinced that my implementation was incorrect and decided to create a new project to investigate this.

I decided that I would also test how a vector type with single precision floats(`f32`) components compared to one with double precision floats(`f64`). Modern processors use 64bit registers and instructions, so surely there should be no difference between the two. I created a benchmark that compared the performance of computing the dot product between three cases:

+ Naive implementation with `f32` components.
+ Naive implementation with `f64` components.
+ An SIMD implementation with `f32` using `_mm_dp_ps`.

![]({{ 'img/exploring-simd-in-rust/benchmark.png' | asset_url }})

This confirmed that the `f32` and `f64` versions were indeed equally fast. However contrary to my expectation the SIMD version was again the slowest. In fact it was about **10 times slower** than the other two.


I was getting more confused the more time I spent trying to understand this. I thought SIMD instructions were supposed to be fast. Surely doing something with one CPU instruction would be faster than doing it with more than one? I decided that I should look at the assembly emitted by the Rust compiler to verify SIMD instructions where actually being used. With this implementation for the SIMD dot product

{% highlight rust line %}
#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
#[target_feature = "+sse4.1"]
pub unsafe fn dot_sse(a: f32x4, b: f32x4) -> f32 {
    vendor::_mm_dp_ps(a, b, 0x71).extract(0)
}

pub fn dot_f32_sse(a: &Vector3<f32>, b: &Vector3<f32>) -> f32 {
    let a = f32x4::new(a.x, a.y, a.z, 0.0);
    let b = f32x4::new(b.x, b.y, b.z, 0.0);
    unsafe { dot_sse(a, b) }
}
{% endhighlight %}

`cargo rustc --lib --release -- --emit asm` produced the following asm.

{% highlight asm line %}
__ZN17vector_benchmarks7dot_sse17h19e9d56d320ebbadE:
	.cfi_startproc
	pushq	%rbp
Lcfi0:
	.cfi_def_cfa_offset 16
Lcfi1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Lcfi2:
	.cfi_def_cfa_register %rbp
	dpps	$113, %xmm1, %xmm0
	popq	%rbp
	retq
	.cfi_endproc
{% endhighlight %}

Notably a `dpps` SIMD instruction is generated for the `_mm_dp_ps` call.

As expected the naive implementation

{% highlight rust line %}
pub fn dot_naive(a: &Vector3<f32>, b: &Vector3<f32>) -> f32 {
    a.x * b.x + a.y * b.y + a.z * b.z
}
{% endhighlight %}

produces more assembly


{% highlight asm line %}
__ZN17vector_benchmarks9dot_naive17h71bdc9abb734cc99E:
	.cfi_startproc
	pushq	%rbp
Lcfi6:
	.cfi_def_cfa_offset 16
Lcfi7:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Lcfi8:
	.cfi_def_cfa_register %rbp
	movss	(%rdi), %xmm0
	movss	4(%rdi), %xmm1
	mulss	(%rsi), %xmm0
	mulss	4(%rsi), %xmm1
	addss	%xmm0, %xmm1
	movss	8(%rdi), %xmm0
	mulss	8(%rsi), %xmm0
	addss	%xmm1, %xmm0
	popq	%rbp
	retq
	.cfi_endproc
{% endhighlight %}

Notably there are 8 CPU instructions dealing with the dot product calculation here. Would this not imply that the SIMD version should be 8 times faster? My benchmark was definitely not showing that. At this point I decided that I could not trust the [bencher](https://docs.rs/bencher/0.1.4/bencher/) crate I was using to run the benchmarks. Instead I would use the true and tested `time` utility and a small program to exercise the different options. I wrote a small program that just calculated the dot product of two vectors many times.


{% highlight rust line %}
const DEFAULT_NUM_ITERATIONS: u64 = 1_000_000_000_0;

#[cfg(any(target_arch = "x86", target_arch = "x86_64"))]
#[target_feature = "+sse4.1"]
fn main() {
    let a = f32x4::new(23.2, 39.1, 21.0, 0.0);
    let b = f32x4::new(-5.2, 0.1, 13.4, 0.0);
    let v1: Vector3<f32> = Vector3::new(23.2, 39.1, 21.0);
    let v2: Vector3<f32> = Vector3::new(-5.2, 0.1, 13.4);

    let mut x = 0.0;

    for _ in 0..DEFAULT_NUM_ITERATIONS {
        // x += unsafe { dot_sse(a, b) };
        x += v1.dot(&v2);
    }

    println!("Done {}", x);
}
{% endhighlight %}

By commenting out the different implementations I could test both with `time`. I found that under these conditions the SIMD version was still about **5 times slower** than the naive implementation. I decided to look at the assembly for this code when both implementations were included. Here is the code for the for loop body:

{% highlight asm line %}
LBB0_1:
	movss	%xmm0, -12(%rbp)
	incq	%rbx
	movaps	LCPI0_0(%rip), %xmm0
	movaps	LCPI0_1(%rip), %xmm1
	callq	__ZN17vector_benchmarks7dot_sse17h5f14af7b2dded45aE
	movss	-12(%rbp), %xmm1
	addss	%xmm0, %xmm1
	movss	%xmm1, -12(%rbp)
	movss	-12(%rbp), %xmm0
	addss	LCPI0_2(%rip), %xmm0
	movq	%rbx, %rax
	shrq	$10, %rax
	cmpq	$9765625, %rax
	jb	LBB0_1
{% endhighlight %}

Notice anything that's out of place? As it turns out the Rust compiler did not inline the implementation of the SIMD version, but did inline the naive implementation. The overhead from the function call is enough to completely destroy the performance of the SIMD version. Nothing that `#[inline(always)]` can not take care of right?

{% highlight plain line %}
LLVM ERROR: Cannot select: intrinsic %llvm.x86.sse41.dpps
error: Could not compile `vector_benchmarks`.
{% endhighlight %}

As it turns out the Rust compiler does not handle conditional compilation and inlining very well 😞. However what if we just inline the SIMD nstructions in the loop? Surely this will solve it and unlock the promised performance boost of the SIMD instructions? Replacing the call to `dot_sse(a, b)` with `unsafe { x += vendor::_mm_dp_ps(a, b, 0x71).extract(0) }` did speed things up considerably.

![]({{ 'img/exploring-simd-in-rust/benchmark-sse-inline.png' | asset_url }})

But sadly the SIMD version is still not any faster than the naive implementation. I can only conclude that this is because the difference between 1 and 8 CPU instructions is negligible in the presence of CPU cache misses and main memory access.

The code for the benchmarks are available on [Github](https://github.com/k0nserv/vector-benchmarks). Feel free to reach out to me on Twitter if you discover something I have missed.

Now I should really consider implementing some better acceleration structures to speed up performance instead.
