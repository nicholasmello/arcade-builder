################################################################################
#
# example_package package
#
################################################################################

EXAMPLEPACKAGE_VERSION = 1.0
EXAMPLEPACKAGE_SITE = package/example_package/src
EXAMPLEPACKAGE_SITE_METHOD = local

define EXAMPLEPACKAGE_BUILD_CMDS
    $(MAKE) CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define EXAMPLEPACKAGE_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/example_package $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))

