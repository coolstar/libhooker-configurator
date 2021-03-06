include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/null.mk

ifeq ($(call __executable,xcpretty),$(_THEOS_TRUE))
ifneq ($(_THEOS_VERBOSE),$(_THEOS_TRUE))
	XCPRETTY := | xcpretty
endif
endif

ifeq ($(call __theos_bool,$(DEBUG)),$(_THEOS_TRUE))
	BUILD_CONFIG := Debug
else
	BUILD_CONFIG := Release
endif

export EXPANDED_CODE_SIGN_IDENTITY =
export EXPANDED_CODE_SIGN_IDENTITY_NAME =

TARGET_CODESIGN = /usr/local/bin/ldid
LIBHOOKER_APP_DIR = $(THEOS_OBJ_DIR)/install/Applications/libhooker.app

giveMeRoot/bin/giveMeRoot: giveMeRoot/giveMeRoot.c
	$(MAKE) -C giveMeRoot

$(LIBHOOKER_APP_DIR):
	set -o pipefail; \
		xcodebuild -scheme 'libhooker configurator' -configuration $(BUILD_CONFIG) -arch arm64 -sdk iphoneos -derivedDataPath $(THEOS_OBJ_DIR) \
		archive -archivePath="$(THEOS_OBJ_DIR)/libhooker.xcarchive" \
		CODE_SIGNING_ALLOWED=NO PRODUCT_BUNDLE_IDENTIFIER="org.coolstar.libhooker" \
		DSTROOT=$(THEOS_OBJ_DIR)/install $(XCPRETTY)
	rm -f $(LIBHOOKER_APP_DIR)/Frameworks/libswift*.dylib
	$(ECHO_NOTHING)rm -f $(LIBHOOKER_APP_DIR)/Frameworks/libswift*.dylib$(ECHO_END)
	$(ECHO_NOTHING)function process_exec { \
		$(TARGET_STRIP) $$1; \
	}; \
	function process_bundle { \
		process_exec $$1/$$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" $$1/Info.plist); \
	}; \
	export -f process_exec process_bundle; \
	find $(LIBHOOKER_APP_DIR) -name '*.dylib' -print0 | xargs -I{} -0 bash -c 'process_exec "$$@"' _ {}; \
	find $(LIBHOOKER_APP_DIR) \( -name '*.framework' -or -name '*.appex' \) -print0 | xargs -I{} -0 bash -c 'process_bundle "$$@"' _ {}; \
	process_bundle $(LIBHOOKER_APP_DIR)$(ECHO_END)

all:: $(LIBHOOKER_APP_DIR) giveMeRoot/bin/giveMeRoot

internal-stage::
	mkdir -p $(THEOS_STAGING_DIR)/Applications/
	cp -a $(LIBHOOKER_APP_DIR) $(THEOS_STAGING_DIR)/Applications/
	cp giveMeRoot/bin/giveMeRoot $(THEOS_STAGING_DIR)/Applications/libhooker.app/
	$(TARGET_CODESIGN) -Sent.plist $(THEOS_STAGING_DIR)/Applications/libhooker.app/
	$(TARGET_CODESIGN) -SgiveMeRoot/Ent.plist $(THEOS_STAGING_DIR)/Applications/libhooker.app/giveMeRoot
	chmod 4755 $(THEOS_STAGING_DIR)/Applications/libhooker.app/giveMeRoot

internal-clean::
	$(MAKE) -C giveMeRoot clean

.PHONY: $(THEOS_OBJ_DIR)/libhooker.app/libhooker
