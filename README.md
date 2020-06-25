# Tsubasa

Script for sharing screenshots and/or status updates using [ihabunek/toot](https://github.com/ihabunek/toot)

## Usage
```bash
Usage:
tsubasa [OPTION...] <command>

Help Options:
	-h,--help	Show help options
	-V,--version	Print version information and exit
	-v,--verbose	Print debug logging

Application Commands:
	nothing		(default) Saves a screenshot to the XDG Pictures directory and shares to Fediverse via toot
	window		Saves a screenshot of the current window to the XDG Pictures directory and shares to Fediverse via toot
	area		Saves a screenshot of a selected region to the XDG Pictures directory and shares to Fediverse via toot
	text		Share a status update to Fediverse via toot
```

#### Example
`$ tsubasa --verbose window`

Takes screenshot of a window and sends it to Fediverse via toot, while being verbose and printing debugging info.

## Installation
### AUR
`$ yay -S tsubasa` for [tsubasa](https://aur.archlinux.org/packages/tsubasa)

OR

`$ yay -S tsubasa-git` for [tsubasa-git](https://aur.archlinux.org/packages/tsubasa-git/)
### PKGBUILD
`$ makepkg -sic`
### Other
It's just a shell script. Put it in your $PATH and you're good.

---

### Disclaimer
I had originally planned on developing a successor to ShareXin, that was properly maintained and fully implemented in Rust.

But since then developing ShareXin, my interests have changed, and while I enjoy using Rust, I don't feel like maintaing an app I wasn't entirely sure how to fix in the first place.

I had originally made ShareXin as a simple Python script, putting together the Python Twitter API with PyQt5. I then turned it into a Rust app, that relied on external utilities for almost all of its functionality.

To me, it was nothing but a script pretending to be a compiled binary. It used [sferik/t](https://github.com/sferik/t) for Twitter, [ihabunek/toot](https://github.com/ihabunek/toot) for Mastodon, and the only parts of ShareXin that used actual Rust were the Imgur API, and GTK, and those aren't much.

I won't be creating a successor to ShareXin, but rather creating a script for those who still want ShareXin functionality in an easier format. This behaves like ShareXin for all the reasons I made it for. If it is useful to you, go ahead and use it. If you'd like to extend it, go ahead and fork it.

The only improvements I will be making to this script will be to make it more portable and ensuring functionality on systems I use. But that's it. If you don't use GNOME or Sway, I'm sorry. If you don't use Linux/BSD, I'm sorry. If you'd prefer Twitter or some other services to upload to, I'm sorry.

### Alternatives
[Francesco149/sharenix](https://github.com/Francesco149/sharenix) - While not very active, it is a great Go app that has more in common with ShareX than ShareXin ever did. If you need custom API support, here you go!
