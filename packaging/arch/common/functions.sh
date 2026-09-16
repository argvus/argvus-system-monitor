#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154
# srcdir, pkgdir, pkgname, and pkgver are supplied by makepkg.

# GitHub source archives use <repository>-v<version> as their top-level
# directory, while the local builder creates <pkgname>-<pkgver>. Normalize
# both forms before check() and package() run.
arch_normalize_source_tree() {
	local expected="${srcdir}/${pkgname}-${pkgver}"
	local -a roots=()

	while IFS= read -r -d '' root; do
		roots+=("$root")
	done < <(find "$srcdir" -mindepth 1 -maxdepth 1 -type d -print0)

	if (( ${#roots[@]} != 1 )); then
		printf 'error: expected exactly one extracted source directory in %s\n' "$srcdir" >&2
		return 1
	fi

	if [[ "${roots[0]}" != "$expected" ]]; then
		[[ ! -e "$expected" ]] || {
			printf 'error: source destination already exists: %s\n' "$expected" >&2
			return 1
		}
		mv -- "${roots[0]}" "$expected"
	fi
}

arch_check_system_monitor_payload() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"

	test -x "${source_root}/src/usr/bin/argvus-system-monitor"
	test -f "${source_root}/src/usr/share/applications/argvus-system-monitor.desktop"
	test -f "${source_root}/src/usr/share/argvus/system-monitor/config/btop/btop.conf"
	test -n "$(find "${source_root}/src/usr/share/argvus/system-monitor/config/btop/themes" -name '*.theme' -type f -print -quit)"
}

arch_package_system_monitor_payload() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"

	install -Dm755 "${source_root}/src/usr/bin/argvus-system-monitor" \
		"${pkgdir}/usr/bin/argvus-system-monitor"
	install -Dm644 "${source_root}/src/usr/share/applications/argvus-system-monitor.desktop" \
		"${pkgdir}/usr/share/applications/argvus-system-monitor.desktop"
	install -d "${pkgdir}/usr/share/argvus-system-monitor/btop/themes"
	install -Dm644 "${source_root}/src/usr/share/argvus/system-monitor/config/btop/btop.conf" \
		"${pkgdir}/usr/share/argvus-system-monitor/btop/btop.conf"
	install -m644 "${source_root}/src/usr/share/argvus/system-monitor/config/btop/themes/"*.theme \
		"${pkgdir}/usr/share/argvus-system-monitor/btop/themes/"
	install -Dm644 "${source_root}/LICENSE" \
		"${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
