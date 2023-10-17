################################################################################
#
# qt-test package
#
################################################################################

QT_TEST_VERSION = 1.0
QT_TEST_SITE = package/qt-test/src
QT_TEST_SITE_METHOD = local

QT_TEST_DEPENDENCIES = qt5base

define QT_TEST_CONFIGURE_CMDS
	(cd $(@D); $(QT5_QMAKE))
endef

define QT_TEST_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QT_TEST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/qt-test $(TARGET_DIR)/usr/bin/qt-test
endef

$(eval $(generic-package))

