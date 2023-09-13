################################################################################
#
# buildinfo package
#
################################################################################

BUILDINFO_VERSION = 1.0
BUILDINFO_SITE = package/buildinfo/src
BUILDINFO_SITE_METHOD = local

define BUILDINFO_BUILD_CMDS
    $(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define BUILDINFO_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/buildinfo $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))

