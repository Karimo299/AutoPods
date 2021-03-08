TARGET = iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = sharingd
ARCHS= arm64 arm64e

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoPods

AutoPods_FILES = Tweak.x
AutoPods_CFLAGS = -fobjc-arc
AutoPods_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
