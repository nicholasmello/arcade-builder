################################################################################
#
# rusthello package
#
################################################################################

RUST_HELLO_VERSION = 1.0
RUST_HELLO_SITE = package/rust-hello/src
RUST_HELLO_SITE_METHOD = local

define RUST_HELLO_CONFIGURE_CMDS
	(cd $(@D); $(HOST_DIR)/bin/cargo generate-lockfile)
endef

$(eval $(cargo-package))
