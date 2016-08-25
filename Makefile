SDKVERSION=5.0
GO_EASY_ON_ME=1
THEOS_DEVICE_IP = 192.168.0.32
include theos/makefiles/common.mk

TWEAK_NAME = VoiceSearch
VoiceSearch_FILES = Tweak.xm
VoiceSearch_FRAMEWORKS = UIKit AudioToolbox AVFoundation Foundation CoreGraphics QuartzCore
VoiceSearch_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/tweak.mk
