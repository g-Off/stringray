TOOL_NAME = stringray
VERSION = 0.3.0

REPO = https://github.com/g-Off/$(TOOL_NAME)
RELEASE_TAR = $(REPO)/archive/$(VERSION).tar.gz
SHA = $(shell curl -L -s $(RELEASE_TAR) | shasum -a 256 | sed 's/ .*//')

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(TOOL_NAME)
BUILD_PATH = $(shell swift build --show-bin-path -c $(CONFIGURATION))/$(TOOL_NAME)

SWIFTC_FLAGS = -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"
CONFIGURATION = debug

debug: generate_version
debug: build

generate_version:
	@sed 's/__VERSION__/$(VERSION)/g' Version.swift.template > Sources/stringray/Version.swift

release:
	@echo $(SHA)
	
build:
	swift build --configuration $(CONFIGURATION) $(SWIFTC_FLAGS)

install: CONFIGURATION = release	
install: SWIFTC_FLAGS += --static-swift-stdlib --disable-sandbox
install: clean build
	mkdir -p $(PREFIX)/bin
	cp -f $(BUILD_PATH) $(INSTALL_PATH)
	
test:
	swift test $(SWIFTC_FLAGS)
	
xcode: generate_version
xcode:
	swift package generate-xcodeproj --xcconfig-overrides=Overrides.xcconfig
	xed .

clean:
	swift package clean
	
.PHONY: debug release build test xcode clean install
