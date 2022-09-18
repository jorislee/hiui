#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk
include ../version.mk

PKG_NAME:=hiui-ui-core
PKG_VERSION:=$(strip $(call findrev))
PKG_RELEASE:=1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT

# PKG_BUILD_DEPENDS:=!HIUI_USE_HOST_NODE:node/host

PKG_CONFIG_DEPENDS:= \
	CONFIG_HIUI_USE_HOST_NODE \
	CONFIG_HIUI_LOGIN_VIEW \
	CONFIG_HIUI_LAYOUT_VIEW \
	CONFIG_HIUI_HOME_VIEW

ifeq ($(CONFIG_HIUI_USE_HOST_NODE),n)
NPM:=$(STAGING_DIR_HOSTPKG)/bin/npm
endif

NPM?=npm

include $(INCLUDE_DIR)/package.mk

define Package/hiui-ui-core
  SECTION:=hiui
  CATEGORY:=Hiui
  TITLE:=Hiui ui core
  URL:=https://github.com/zhaojh329/hiui
  DEPENDS:=+hiui-rpc-core
  PKGARCH:=all
endef

define Package/hiui-ui-core/config
  config HIUI_LOGIN_VIEW
	string "Customize the login view"
	default "login"

  config HIUI_LAYOUT_VIEW
	string "Customize the layout view"
	default "layout"

  config HIUI_HOME_VIEW
	string "Customize the home view"
	default "network"

  config HIUI_USE_HOST_NODE
	bool "Use existing nodejs installation on the host system"
	default y
	help
	  This disables the build dependency on the node package from
	  the OpenWrt packages feed, allowing for faster development
	  builds.
endef

define Package/hiui-ui-core/conffiles
/etc/config/hiui
endef

define Build/Prepare
	$(CP) ./htdoc $(PKG_BUILD_DIR)
	echo "VITE_HIUI_LOGIN_VIEW=$(CONFIG_HIUI_LOGIN_VIEW)" > $(PKG_BUILD_DIR)/htdoc/.env.local
	echo "VITE_HIUI_LAYOUT_VIEW=$(CONFIG_HIUI_LAYOUT_VIEW)" >> $(PKG_BUILD_DIR)/htdoc/.env.local
	echo "VITE_HIUI_HOME_VIEW=$(CONFIG_HIUI_HOME_VIEW)" >> $(PKG_BUILD_DIR)/htdoc/.env.local
	$(NPM) --prefix $(PKG_BUILD_DIR)/htdoc install
endef

define Build/Compile
	$(NPM) --prefix $(PKG_BUILD_DIR)/htdoc run build
endef

define Package/hiui-ui-core/install
	$(INSTALL_DIR) $(1)/usr/share/hiui/menu.d $(1)/www
	$(INSTALL_CONF) ./files/menu.json $(1)/usr/share/hiui/menu.d/base.json
	$(CP) $(PKG_BUILD_DIR)/htdoc/dist/* $(1)/www
endef

$(eval $(call BuildPackage,hiui-ui-core))
