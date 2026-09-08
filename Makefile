PREFIX ?= /usr
DESTDIR ?=
INSTALL ?= install
RM ?= rm -f

.DEFAULT_GOAL := help

.PHONY: help install uninstall validate build clean

help:
	@echo "Available targets:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make validate"

install:
	$(INSTALL) -Dm755 usr/bin/argvus-system-monitor \
		"$(DESTDIR)$(PREFIX)/bin/argvus-system-monitor"
	$(INSTALL) -Dm644 usr/share/applications/argvus-system-monitor.desktop \
		"$(DESTDIR)$(PREFIX)/share/applications/argvus-system-monitor.desktop"
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus-system-monitor"
	cp -R --no-preserve=ownership usr/share/argvus-system-monitor/. "$(DESTDIR)$(PREFIX)/share/argvus-system-monitor/"
	$(INSTALL) -Dm644 LICENSE \
		"$(DESTDIR)$(PREFIX)/share/licenses/argvus-system-monitor/LICENSE"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/bin/argvus-system-monitor"
	$(RM) "$(DESTDIR)$(PREFIX)/share/applications/argvus-system-monitor.desktop"
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus-system-monitor"
	$(RM) "$(DESTDIR)$(PREFIX)/share/licenses/argvus-system-monitor/LICENSE"

validate:
	@set -eu; \
	test -x usr/bin/argvus-system-monitor; \
	test -f usr/share/applications/argvus-system-monitor.desktop; \
	test -f usr/share/argvus-system-monitor/btop/btop.conf; \
	for theme in usr/share/argvus-system-monitor/btop/themes/*.theme; do test -f "$$theme"; done; \
	sh -n usr/bin/argvus-system-monitor; \
	if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -e SC1090 -e SC1091 usr/bin/argvus-system-monitor; \
	else \
		echo "shellcheck not found; skipped"; \
	fi; \
	if command -v desktop-file-validate >/dev/null 2>&1; then \
		desktop-file-validate usr/share/applications/argvus-system-monitor.desktop; \
	else \
		echo "desktop-file-validate not found; skipped"; \
	fi; \
	! find usr -path '*/bin/btop' -o -path '*/applications/btop.desktop' | grep -q .
	@echo "argvus-system-monitor validation ok"

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f *.pkg.tar* packaging/arch/*.zst packaging/arch/*.tar.gz
