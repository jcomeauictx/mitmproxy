# Maintainer:
pkgname=mitmproxy
pkgver=0.9.2
pkgrel=1
pkgdesc="Man-in-the-middleware, an HTTPS proxy"
url="https://github.com/jcomeauictx/mitmproxy"
arch="i386"
options="!check"  # Requires a running X11 server.
license="MIT"
depends_dev="libffi-dev"
makedepends="$depends_dev python3-dev"
subpackages=""
source="https://api.github.com/repos/jcomeauictx/mitmproxy/tarball/alpine-ish"

_major=${pkgver%.*}
builddir="$srcdir"/tk$pkgver/unix

build() {
	make
}

package() {
	# remove buildroot traces
}

dev() {
}

sha512sums="d12ef3a5bde9e10209a24e9f978bd23360a979d8fa70a859cf750a79ca51067a11ef6df7589303b52fe2a2baed4083583ddaa19e2c7cb433ea523639927f1be5 alpine-ish-src.tar.gz"
