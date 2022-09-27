#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include ${CURDIR}/../../version.mk

PKG_NAME:=$(notdir ${CURDIR})
PKG_VERSION:=$(strip $(call findrev))
PKG_RELEASE?=1

ifeq ($(CONFIG_HIUI_USE_HOST_NODE),n)
NPM:=$(STAGING_DIR_HOSTPKG)/bin/npm
endif

NPM?=npm

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=hiui
  CATEGORY:=Hiui
  SUBMENU:=Applications
  TITLE:=$(APP_TITLE)
  DEPENDS:=$(APP_DEPENDS)
  PKGARCH:=all
endef

define Build/Prepare
	$(CP) ./htdoc $(PKG_BUILD_DIR)
	echo "VITE_APP_NAME=$(APP_NAME)" > $(PKG_BUILD_DIR)/htdoc/.env.local
	$(NPM) --prefix $(PKG_BUILD_DIR)/htdoc install
endef

define Build/Compile
	$(NPM) --prefix $(PKG_BUILD_DIR)/htdoc run build
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/www/views $(1)/etc/init.d $(1)/etc/uci-defaults $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)//htdoc/dist/* $(1)/www/views
	if [ -f ./files/menu.json ]; then \
		$(INSTALL_DIR) $(1)/usr/share/hiui/menu.d; \
		$(INSTALL_CONF) ./files/menu.json $(1)/usr/share/hiui/menu.d/$(APP_NAME).json; \
	fi
	if [ -d ./files/rpc ]; then \
		$(CP) ./files/rpc $(1)/usr/share/hiui/rpc; \
	fi
	if [ -d ./files/init.d ]; then \
		$(INSTALL_BIN) ./files/init.d/* $(1)/etc/init.d/; \
	fi
	if [ -d ./files/uci-defaults ]; then \
		$(INSTALL_BIN) ./files/uci-defaults/* $(1)/etc/uci-defaults/; \
	fi
	if [ -d ./files/sbin ]; then \
		$(INSTALL_BIN) ./files/sbin/* $(1)/usr/sbin/; \
	fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
