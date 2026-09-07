# Maintainer: William C. Canin
pkgname=argvus-system-monitor
pkgver=0.1.0
pkgrel=1
pkgdesc="btop system monitor integration and ARGVUS configuration layer."
arch=('any')
url="https://github.com/argvus/argvus-system-monitor"
license=('GPL-3.0-only')
depends=(
  'argvus-session'
  'argvus-terminal'
  'btop'
)
makedepends=()
options=('!debug')
source=()
sha256sums=()

package() {
  cd "${startdir}"
  make DESTDIR="${pkgdir}" PREFIX=/usr install
}
