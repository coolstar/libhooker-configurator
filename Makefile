# See if we want verbose make.
V             ?= 0
# Debug build or not?
DEBUG         ?= 0
# Beta build or not?
BETA          ?= 0

# Platform to build for.
LHC_PLATFORM ?= iphoneos-arm64
TARGET_CODESIGN = $(shell which ldid)
ARCH            = arm64
PLATFORM        = iphoneos
DEB_ARCH        = iphoneos-arm
DEB_DEPENDS     = org.coolstar.libhooker (>=1.4.0), firmware (>= 12.2) | org.swift.libswift (>= 5.0), firmware (>= 12.0)
PREFIX          =

ifneq (,$(shell which xcpretty))
ifeq ($(V),0)
XCPRETTY := | xcpretty
endif
endif

MAKEFLAGS += --no-print-directory

export EXPANDED_CODE_SIGN_IDENTITY =
export EXPANDED_CODE_SIGN_IDENTITY_NAME =

STRIP = xcrun strip

ifneq ($(BETA),0)
LHC_VERSION = $$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)/Info.plist)+$$(git show -s --format=%cd --date=short HEAD | sed s/-//g).$$(git show -s --format=%cd --date=unix HEAD | sed s/-//g).$$(git rev-parse --short=7 HEAD)
else
LHC_VERSION = $$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)/Info.plist)
endif
export PRODUCT_BUNDLE_IDENTIFIER = "org.coolstar.libhooker"
LHC_ID   = org.coolstar.libhooker-configurator
LHC_NAME = libhooker-configurator
LHC_APP  = libhooker.app

LHCTMP = $(TMPDIR)/libhooker
LHC_STAGE_DIR = $(LHCTMP)/stage
LHC_APP_DIR = $(LHCTMP)/install/$(PREFIX)/Applications/libhooker.app

ifneq ($(DEBUG),0)
BUILD_CONFIG  := Debug
else
BUILD_CONFIG  := Release
endif

ifeq ($(shell dpkg-deb --help | grep "zstd" && echo 1),1)
DPKG_TYPE ?= zstd
else
DPKG_TYPE ?= xz
endif

giveMeRoot/bin/giveMeRoot: giveMeRoot/giveMeRoot.c
	$(MAKE) -C giveMeRoot \
		CC="xcrun -sdk $(PLATFORM) cc -arch $(ARCH)"

$(LHC_APP_DIR):
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'libhooker configurator.xcodeproj' -scheme 'libhooker configurator' -configuration $(BUILD_CONFIG) -arch $(ARCH) -sdk $(PLATFORM) -derivedDataPath $(LHCTMP) \
		archive -archivePath="$(LHCTMP)/libhooker.xcarchive" \
		CODE_SIGNING_ALLOWED=NO PRODUCT_BUNDLE_IDENTIFIER=$(PRODUCT_BUNDLE_IDENTIFIER) \
		DSTROOT=$(LHCTMP)/install $(XCPRETTY)
	@rm -f $(LHC_APP_DIR)/Frameworks/libswift*.dylib
	@function process_exec { \
		$(STRIP) $$1; \
	}; \
	function process_bundle { \
		process_exec $$1/$$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" $$1/Info.plist); \
	}; \
	export -f process_exec process_bundle; \
	find $(LHC_APP_DIR) -name '*.dylib' -print0 | xargs -I{} -0 bash -c 'process_exec "$$@"' _ {}; \
	find $(LHC_APP_DIR) \( -name '*.framework' -or -name '*.appex' \) -print0 | xargs -I{} -0 bash -c 'process_bundle "$$@"' _ {}; \
	process_bundle $(LHC_APP_DIR)

all:: $(LHC_APP_DIR) giveMeRoot/bin/giveMeRoot

stage: all
	@mkdir -p $(LHC_STAGE_DIR)/$(PREFIX)/Applications/
	@cp -a ./layout/DEBIAN $(LHC_STAGE_DIR)
	@cp -a $(LHC_APP_DIR) $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)
	@cp giveMeRoot/bin/giveMeRoot $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)/
	@$(TARGET_CODESIGN) -SEntitlements.plist $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)/
	@$(TARGET_CODESIGN) -SgiveMeRoot/Entitlements.plist $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)/giveMeRoot
	@chmod 4755 $(LHC_STAGE_DIR)/$(PREFIX)/Applications/$(LHC_APP)/giveMeRoot
	@sed -e s/@@MARKETING_VERSION@@/$(LHC_VERSION)/ \
		-e 's/@@PACKAGE_ID@@/$(LHC_ID)/' \
		-e 's/@@PACKAGE_NAME@@/$(LHC_NAME)/' \
		-e 's/@@DEB_ARCH@@/$(DEB_ARCH)/' \
		-e 's/@@DEB_DEPENDS@@/$(DEB_DEPENDS)/' $(LHC_STAGE_DIR)/DEBIAN/control.in > $(LHC_STAGE_DIR)/DEBIAN/control
	@rm -f $(LHC_STAGE_DIR)/DEBIAN/control.in

package: stage
	@mkdir -p ./packages
	@dpkg-deb -Z$(DPKG_TYPE) --root-owner-group -b $(LHC_STAGE_DIR) ./packages/$(LHC_ID)_$(LHC_VERSION)_$(DEB_ARCH).deb

clean::
	@$(MAKE) -C giveMeRoot clean
	@rm -rf $(LHCTMP)
	
