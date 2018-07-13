---
layout: post
title:  "Yubikey SSH Authentication"
categories: security tools git
date: 2018-07-13
---

About a year ago I bought a [YubiKey Nano](https://www.yubico.com/product/yubikey-neo/) to use as a hardware token via the emerging FIDO protocol and for OTP. For some time I've been aware that it's possible to keep a PGP keypair on the key and use it for signing and authentication for git. Today I decided to finally set that up. Since this process proved to be a bit confusing I figured I would write it up.

## Getting started

I did this with my YubiKey Nano, but I believe it will work with other models as long as they support OpenPGP. I'm using macOS for this and to work with PGP you need [GPG Tools](https://gpgtools.org/) so go install that first. After installing it if you insert your YubiKey and run `gpgp --card-status` you should see output like this:

{% highlight plain %}
Reader ...........: Yubico Yubikey NEO OTP U2F CCID
Application ID ...: <ID>
Version ..........: 2.0
Manufacturer .....: Yubico
Serial number ....: <serial>
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
{% endhighlight %}


## Generating a key

From my research you can chose to generate a PGP key on your own machine and move it to the YubiKey or you can use the built in support to generate the key on the YubiKey itself. This way the key never exists on your machine. To generate the key run `gpg --edit-card` at the prompt enter `admin` and then `generate`. During this process you'll be prompted to set two PIN codes, one for the key and another that acts as an Admin PIN. The defaults are `123456` and `12345678` respectively.

> During this part I had a lot of problems with errors complaining about broken pipes or missing files. I did a few things and eventually managed to fix this. The steps I took was disabling CCID support via the the Yubikey Manager and then turning it back on. I also restarted my Macbook and killed `gpg-agent`.

After you have successfully generated a key it should show up when you run `gpg --list-keys` with an output similar to this:

{% highlight plain %}
pub   rsa2048 2018-07-13 [SC] [expires: 2019-07-13]
      DE1BAEB5D9D6A9F6B783A144841E768B6756FA89
uid           [ultimate] Hugo Tunius <h@tunius.se>
sub   rsa2048 2018-07-13 [A] [expires: 2019-07-13]
sub   rsa2048 2018-07-13 [E] [expires: 2019-07-13]
{% endhighlight %}

You can export the RSA public key by running `gpg --export-ssh-key "<name>" > ~/.ssh/yubi_key.pub` where `<name>` is the name you gave when generating the key. This key is what you want to add to GitHub/GitLab and to `~/.ssh/authorized_keys` on any remotes systems you wish to access.

## Using gpg-agent for SSH authentication

The `gpg-agent` utility can be configured to take the place of `ssh-agent` on your system. When you need to log in to a remote server or push to a git remote this agent provides authentication based on a RSA key pair stored on the YubiKey. At this point I had issues because a lot of answers and guides on the internet are outdated and talk about options that have been deprecated. To get `gpg-agent` working you need to create two files `~/.gnupg/gpg-agent.conf` and `~/.gnupg/gpg.conf`.

### gpg-agent.conf

{% highlight plain %}
pinentry-program /usr/local/MacGPG2/libexec/pinentry-mac.app/Contents/MacOS/pinentry-mac
enable-ssh-support
use-standard-socket
default-cache-ttl 600
max-cache-ttl 7200
{% endhighlight %}

The key thing here is `enable-ssh-support` which ensures that the `gpg-agent` can act as a `ssh-agent`. The `pinentry-program` is shipped with `gpg-tools` and is used to prompt for the PIN when first using the RSA key in a session.

### gpg.conf

{% highlight plain %}
no-emit-version
default-key <key-id>
use-agent
{% endhighlight %}

You can find your key id in `gpg --list-keys`, it is the long string of digits and letters on the second row.

### Making it all work

After getting this far you just need to ensure that `ssh-agent` is not interfering with your setup by setting `SSH_AUTH_SOCK` in your `.bashrc`/`.zshrc`. You also need to ensure that `gpg-agent` is running. This used to be more complex, but since GPG 2.1.0 there's a handy tool called `gpgconf` that can help. `gpgconf --launch gpg-agent` will ensure the `gpg-agent` is running.

{% highlight bash %}
export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
gpg-agent --launch gpg-agent
{% endhighlight %}

Given that you have done everything correctly you should now be able to run `ssh-add -L` and you should be able to use SSH with the keys stored on your YubiKey. If you remove the YubiKey from the computer you can no longer use the keys on the device as they are stored safely on the key itself.


## Git signing

The YubiKey contains both a SSH key pair and a PGP master key that can be used for sining. You can turn on signing for git commmits by finding your key id with `gpg --list-secret-keys --keyid-format LONG` and looking for the id after `rsa2048/XXXXXXXXX` then run `git config --global user.signingkey <key-id>`. Now you can sign commits with `git commit -S` or if you want all commits to be signed set `git config --global commit.gpgSign true`. To ensure GitHub recognises your commits as signed you need to add the output of `gpg --armor --export <key-id>` to your [GitHub Settings](https://github.com/settings/keys).

## Final notes

The details of this setup are available in my dotfiles repository in these three commits:

+ [[git] PGP settings](https://github.com/k0nserv/dotfiles/commit/39627e155e17c5a7f1cceb8afb9fb5267309c540)
+ [[gpg] Add gpg config](https://github.com/k0nserv/dotfiles/commit/660e051240edda0d564bec7a3e883dfc0568b3ec)
+ [[zshrc] Setup gpg-agent](https://github.com/k0nserv/dotfiles/commit/f215d938c31c1b3ac33163cfa80b9db7f2e90d1b)

