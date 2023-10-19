################################################################################
#
# buildinfo package
#
################################################################################

BUILDINFO_READER_VERSION = 1.0
BUILDINFO_READER_SITE = package/buildinfo-reader/src
BUILDINFO_READER_SITE_METHOD = local

define BUILDINFO_READER_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/buildinfo $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))

