.PHONY: all clean distclean dist package

ifeq ($(PREFIX),)
    PREFIX := /usr/local/
endif


DIST_NAME := surface-go-wifi
DIST_VERSION := 0.0.2
DEB_BUILD_ARCH := $(shell getconf LONG_BIT | sed "s/32/i386/" | sed "s/64/amd64/")

SOURCE_LIST := Makefile CHANGES.md LICENSE.md README.md lib/ package/ src/

HAS_DPKGDEB := $(shell command -v dpkg-deb >/dev/null 2>&1 ; echo $$?)
HAS_UNCOMMITTED := $(shell git diff --quiet 2>/dev/null ; echo $$?)


all: package


clean:
	-@$(RM) -r build/

distclean: clean
	-@$(RM) -r dist/

dist:
	@$(RM) -r build/dist/
	@mkdir -p build/dist/$(DIST_NAME)-$(DIST_VERSION)/
	@cp -r $(SOURCE_LIST) build/dist/$(DIST_NAME)-$(DIST_VERSION)/
	@tar -cz -C build/dist/  --owner=0 --group=0 -f build/dist/$(DIST_NAME)-$(DIST_VERSION).tar.gz $(DIST_NAME)-$(DIST_VERSION)/
	@mkdir -p dist/
	@mv build/dist/$(DIST_NAME)-$(DIST_VERSION).tar.gz dist/
	@echo Output at dist/$(DIST_NAME)-$(DIST_VERSION).tar.gz

package: dist
	$(if $(findstring 0,$(HAS_DPKGDEB)),,$(error Package 'dpkg-deb' not installed))
	$(if $(findstring 0,$(HAS_UNCOMMITTED)),,$(warning Uncommitted changes present))
	@echo "Packaging for $(DEB_BUILD_ARCH)"
	@$(eval PACKAGE_NAME = $(DIST_NAME)_$(DIST_VERSION)_$(DEB_BUILD_ARCH))
	@$(eval PACKAGE_DIR = /tmp/$(PACKAGE_NAME)/)
	-@$(RM) -r $(PACKAGE_DIR)/
	@mkdir $(PACKAGE_DIR)/
	@cp -r package/deb/DEBIAN $(PACKAGE_DIR)/
	@sed -i "s/MAJOR.MINOR.PATCH/$(DIST_VERSION)/" $(PACKAGE_DIR)/DEBIAN/control
	@sed -i "s/ARCHITECTURE/$(DEB_BUILD_ARCH)/" $(PACKAGE_DIR)/DEBIAN/control
	@mkdir -p $(PACKAGE_DIR)/usr/share/doc/surface-go-wifi/
	@cp package/deb/copyright $(PACKAGE_DIR)/usr/share/doc/surface-go-wifi/copyright
	@cp CHANGES.md build/changelog
	@sed -i '/^$$/d' build/changelog
	@sed -i '/## Release Notes ##/d' build/changelog
	@sed -i '1{s/### \(.*\) \[.*/surface-go-wifi \(\1\) stable; urgency=low/}' build/changelog
	@sed -i '/###/,$$d' build/changelog
	@sed -i 's/\* \(.*\)/  \* \1/' build/changelog
	@echo >> build/changelog
	@echo ' -- Josip Medved <jmedved@jmedved.com>  $(shell date -R)' >> build/changelog
	@gzip -cn --best build/changelog > $(PACKAGE_DIR)/usr/share/doc/surface-go-wifi/changelog.gz
	@find $(PACKAGE_DIR)/ -type d -exec chmod 755 {} +
	@find $(PACKAGE_DIR)/ -type f -exec chmod 644 {} +
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/postinst
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/postrm
	@install -d $(PACKAGE_DIR)/usr/lib/surface-go-wifi/
	@install -d $(PACKAGE_DIR)/usr/lib/surface-go-wifi/bin/
	@install -d $(PACKAGE_DIR)/usr/lib/surface-go-wifi/backup/hw2.1/
	@install -d $(PACKAGE_DIR)/usr/lib/surface-go-wifi/backup/hw3.0/
	@install -m 644 lib/board.bin $(PACKAGE_DIR)/usr/lib/surface-go-wifi/board.bin
	@install -m 755 src/restore.sh $(PACKAGE_DIR)/usr/lib/surface-go-wifi/bin/restore
	@fakeroot dpkg-deb --build $(PACKAGE_DIR)/ > /dev/null
	@cp /tmp/$(PACKAGE_NAME).deb dist/
	@$(RM) -r $(PACKAGE_DIR)/
	@lintian dist/$(PACKAGE_NAME).deb
	@echo Output at dist/$(PACKAGE_NAME).deb
