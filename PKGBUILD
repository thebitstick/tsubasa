# Maintainer: TheBitStick <the at bitstick dot rip>
pkgname=tsubasa-git
_pkgname=tsubasa
pkgver=r43.ba0f14a
pkgrel=1
pkgdesc="Script for sharing screenshots and/or status updates"
arch=('any')
url="https://github.com/thebitstick/tsubasa"
license=('GPL3')
depends=('fish' 'zenity' 'toot')
makedepends=('git')
optdepends=('gnome-screenshot: for screenshotting on GNOME/Wayland and other X11 desktops'
	    'grimshot: for screenshotting on Sway and other wlroots desktops')
provides=('tsubasa')
conflicts=('tsubasa')
source=('git+https://github.com/thebitstick/tsubasa')
sha512sums=('SKIP')

pkgver() {
	cd ${_pkgname}
	printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
	install -D -t "$pkgdir/usr/bin" "${_pkgname}/tsubasa.fish"
	install -D -t "$pkgdir/usr/share/applications" "${_pkgname}/tsubasa.desktop"
	mv "$pkgdir/usr/bin/tsubasa.fish" "$pkgdir/usr/bin/tsubasa"
} 
