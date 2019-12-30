---
layout: post
title: "Efficient Terminal Drawing in Rust"
categories: rust
date: 2019-12-29
description: >
  Efficient drawing in the terminal with Rust, what I discovered implementing realtime terminal visualizations.
---

During the month of December I have for the past few years been participating in [Advent of Code](https://adventofcode.com/). Advent of Code is an [advent calendar](https://en.wikipedia.org/wiki/Advent_calendar) of programming puzzles created by [Eric Wastl](http://was.tl/) I've come to really enjoy. Naturally I am solving the puzzles in [Rust](https://www.rust-lang.org/).

**⚠️This post contains spoilers for Day 15 of Advent of Code 2019⚠️**

Getting to the topic at hand, this year the [fifteenth puzzle](https://adventofcode.com/2019/day/15) involved exploring an unknown maze using a emulated computer the puzzles has had you build. While the puzzle itself is interesting here I want to discuss specifically visualising the puzzle being solved in the terminal.

The purpose of the puzzle was to first explore the maze to find an oxygen system and discover the shortest path from the starting point to the system. For the second part the task was to simulate oxygen from the system flooding the open space within the maze. I was inspired by people on the [official subreddit](https://www.reddit.com/r/adventofcode/) to try my hand at visualising the puzzle in the terminal.

## Drawing in the Terminal

Before doing this I knew that you could do sophisticated drawing in the terminal as demonstrated by fancy progress bars, usually in Javascript tooling, and the [ncurses library](https://en.wikipedia.org/wiki/Ncurses). However I had never really gone beyond clearing the screen myself.

Armed with my knowledge that you could clear the screen I figured this should be simple enough: draw the maze, execute one tick of simulation, clear the screen and redraw the maze again.

{% highlight basic %}
10 DRAW_MAZE
20 TICK
30 CLEAR_SCREEN
40 GOTO 10
{% endhighlight %}

To draw the maze I first used a few different [Unicode block element](https://www.unicode.org/charts/PDF/U2580.pdf). A full block(█) for walls, a light shade block(░) for unknown areas, a medium shade(▒) for empty space, X for the origin, and D for the current location of the droid.

{% highlight plain %}
░░░░░░░
░░░█░░░
░░█XD░░
░░░░░░░
{% endhighlight %}
_Here the droid has discovered two walls and an empty space to the east of its starting location._

In Rust I started drawing the puzzle with roughly the following code.

{% highlight rust %}
fn print_world(world: &World) {
    let (max, min) = world.known_bounds();

    // The escape sequence `\x1B[2J` clear the screen
    let lines: String = std::iter::once("\x1B[2J\n")
        .chain((min.y..=max.y).rev().flat_map(|y| {
            (min.x..=max.x)
                .map(move |x| {
                    let location = (x, y);

                    if location == world.droid_location {
                        "D"
                    } else if location
                        == Location::default()
                    {
                        "X"
                    } else {
                        match world
                            .visited_locations
                            .get(&location)
                        {
                            None => "░",
                            Some(&tile) => match tile {
                                Tile::Empty => "▒",
                                Tile::Wall => "█",
                                Tile::OxygenSystem => "O",
                            },
                        }
                    }
                })
                .chain(std::iter::once("\n"))
        }))
        .collect();

    print!("{}", lines);
    std::io::stdout().flush().unwrap();
}
{% endhighlight %}

This actually works decently well as long as the maze, and thus the output, is small. [This video](https://www.youtube.com/watch?v=VV9SFoJfnMg) demonstrates this method of drawing. While it works while the discovered area of the maze is small, it breaks down when it grows. The terminal emulator, _iTerm_ in my case, can no longer redraw the screen fast enough and it starts flickering.

At this point rather than fixing the issue I procrastinated by adding color via the excellent [`ansi_term`](https://crates.io/crates/ansi_term) crate. It abstracts away the details of setting and unsetting the required control codes to draw in color. Fancy, but still flickering.


I couldn't avoid solving the flickering problem so I took to ~~Google~~ DuckDuckGo. Maybe my search fu was failing me, but I found very few resources explaining how to improve performance when drawing. Eventually I did find some mentions of diff based drawing and the relevant control codes for moving the cursor(`ESC[{y};{x}H`).

As with most optimization problems "do less" is usually not a bad idea, while in many contexts complete redraws are fine in the terminal it is not. My new idea for drawing was to build a sprite map that records for each x-y pair which specific block to draw. With this method it's possible to diff two renders and determine the minimal "drawing commands" to update the screen.


{% highlight rust %}
enum Sprite {
    Unknown,
    Empty,
    Wall,
    Oxygen,
    Droid,
    Origin,
}

// Rows of Sprites
// Sprite at x and y is map[y][x]
type SpriteMap = Vec<Vec<Sprite>>;
{% endhighlight %}

With these constructs only a few more functions are needed to draw with a diff approach. First a function to "print" the world, but now instead of printing we build the sprite map.

{% highlight rust %}
fn world_to_sprite_map(world: &World) -> SpriteMap {
   // Mostly the same as `print_world`,
   // but instead of printing
   // return the appropriate
   // sprite for each location.
}
{% endhighlight %}
_[Full Source](https://github.com/k0nserv/advent-of-rust-2019/blob/005155fd22903b0fe7dbef86efa5b3919ca4a946/examples/day15.rs#L39-L96)_

Secondly a way to diff two sprite maps to determine which "drawing commands" to issue. It returns a list of locations and the new sprite to draw at that location.

{% highlight rust %}
fn diff_sprites(
    current: &[Vec<Sprite>],
    new: &[Vec<Sprite>],
) -> Vec<((usize, usize), Sprite)> {
    (0..new.len())
        .flat_map(|y| {
            (0..new[y].len()).filter_map(move |x| {
                let old = current
                    .get(y)
                    .and_then(|inner| inner.get(x));


                // Without this redundant drawing it seems
                // like the terminal emulator doesn't draw
                // anything because the diff is too small.
                if x < 5 && y < 5 {
                    return Some(((x, y), new[y][x]));
                }

                if old
                    .map(|&old_sprite| {
                        old_sprite != new[y][x]
                    })
                    .unwrap_or(true)
                {
                    Some(((x, y), new[y][x]))
                } else {
                    None
                }
            })
        })
        .collect()
}
{% endhighlight %}

The diff size is almost always of size 2: repainting the last droid location as empty and the new droid location as the droid. Ironically this seems to be too fast because it causes both iTerm and Terminal on macOS to not update at each render. Redundantly re-rendering ~25 sprites on each render solves this.

Lastly a way to draw.

{% highlight rust %}
fn print_diffs(diffs: &[((usize, usize), Sprite)]) {
    let tmp_style = Style::new();

    let draw: Vec<_> = diffs
        .iter()
        .flat_map(|((x, y), sprite)| {
            std::iter::once(
                tmp_style.paint(
                    format!("\x1B[{};{}H", y + 1, x + 1)
                        .as_bytes()
                        .to_owned(),
                ),
            )
            .chain(std::iter::once(sprite.as_ansi()))
        })
        .collect();

    ANSIByteStrings(&draw)
        .write_to(&mut std::io::stdout())
        .unwrap();
}
{% endhighlight %}

Here for each location that needs to redraw we emit the sequence `ESC[{y};{x}` first then followed by the control code for drawing in color and a Unicode full block. When drawing in the terminal the origin is the upper left corner and the coordinate system is 1-indexed. In this version of the code instead of directly creating strings and using `print!` I've opted to write bytes directly to `std::io::stdout`, my hunch is that this is slightly more performant.

This approach works very well, it's possible to draw with only `1ms` long pauses between drawing. [This video](https://www.youtube.com/watch?v=q3ysisqmpwA) is a full demonstration of the puzzle that first explores the maze, then draws the shortest path from the origin to the oxygen system and lastly floods the maze with oxygen.

The full source is available on my [GitHub](https://github.com/k0nserv/advent-of-rust-2019/blob/005155fd22903b0fe7dbef86efa5b3919ca4a946/examples/day15.rs)

## Conclusion

Flicker free drawing in the terminal is possible, but not simple. Unlike environments with fast framebuffer swaps simply clearing and redrawing isn't fast enough. For tech this well established I found the lack of resources online surprising, hopefully this post helped someone.

If this got you interested in Advent of Code I recommend trying it out. You don't have wait until next December, all puzzles from previous years are available and the subreddit is full of interesting discussion on previous puzzles. I've used Advent of Code to practice and learn Rust. Whether you are learning a new language or practicing one you already know Advent of Code is great fun. Thanks Eric!


