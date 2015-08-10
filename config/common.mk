PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Disable excessive dalvik debug messages
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.debug.alloc=0

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/tesla/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/tesla/prebuilt/common/bin/50-slim.sh:system/addon.d/50-slim.sh \
    vendor/tesla/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/tesla/prebuilt/common/etc/backup.conf:system/etc/backup.conf

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# tesla-specific init file
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/etc/init.local.rc:root/init.slim.rc

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/etc/mkshrc:system/etc/mkshrc \
    vendor/tesla/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf

PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/tesla/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit \
    vendor/tesla/prebuilt/common/bin/sysinit:system/bin/sysinit

# Embed SuperUser
SUPERUSER_EMBEDDED := true

# Required packages
PRODUCT_PACKAGES += \
    CellBroadcastReceiver \
    Development \
    SpareParts \
    Superuser \
    su

# Optional packages
PRODUCT_PACKAGES += \
    Basic \
    LiveWallpapersPicker \
    PhaseBeam

# AudioFX
PRODUCT_PACKAGES += \
    Eleven \
    AudioFX

# Extra Optional packages
PRODUCT_PACKAGES += \
    SlimLauncher \
    LockClock \
    LatinIME \
    BluetoothExt \
    DashClock \
    KernelAdiutor \
    WallpaperPicker

# Extra tools
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Screen recorder package and lib
PRODUCT_PACKAGES += \
    ScreenRecorder \
    libscreenrecorder

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/tesla/overlay/common

# SuperSU
PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
    vendor/tesla/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/tesla/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/tesla/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

# Versioning System
# teslaLP first version.
PRODUCT_VERSION_MAJOR = 5.1.1
PRODUCT_VERSION_MINOR = High_Voltage
PRODUCT_VERSION_MAINTENANCE = 2.0
ifdef TESLA_BUILD_EXTRA
    TESLA_POSTFIX := -$(TESLA_BUILD_EXTRA)
endif
ifndef TESLA_BUILD_TYPE
    TESLA_BUILD_TYPE := TRDS
    TESLA_POSTFIX := -$(shell date +"%Y%m%d")
endif

# Chromium Prebuilt
ifeq ($(PRODUCT_PREBUILT_WEBVIEWCHROMIUM),yes)
-include prebuilts/chromium/$(TARGET_DEVICE)/chromium_prebuilt.mk
endif

# Set all versions
TESLA_VERSION := Tesla-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(TESLA_POSTFIX)
TESLA_MOD_VERSION := Tesla-$(TESLA_BUILD)-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)-$(TESLA_BUILD_TYPE)$(TESLA_POSTFIX)

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    tesla.ota.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE) \
    ro.tesla.version=$(TESLA_VERSION) \
    ro.modversion=$(TESLA_MOD_VERSION) \
    ro.tesla.buildtype=$(TESLA_BUILD_TYPE)

# Squisher Location
SQUISHER_SCRIPT := vendor/tesla/tools/squisher
