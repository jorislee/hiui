#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk
PKG_NAME:=nginx-build
PKG_VERSION:=1.0.0
PKG_RELEASE?=1
APP_TITLE:=nginx-build
APP_NAME:=nginx-build
APP_DEPENDS:=+nginx-ssl +@NGINX_HTTP_GZIP_STATIC +@NGINX_HTTP_ACCESS +@NGINX_HTTP_REWRITE +@NGINX_LUA

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=hiui
  CATEGORY:=Hiui
  SUBMENU:=Applications
  TITLE:=$(APP_TITLE)
  DEPENDS:= +nginx-ssl +@NGINX_HTTP_GZIP_STATIC +@NGINX_HTTP_ACCESS +@NGINX_HTTP_REWRITE +@NGINX_LUA
  PKGARCH:=all
endef

define Build/Prepare
	$(CP) ./htdoc $(PKG_BUILD_DIR)
	echo "VITE_APP_NAME=$(APP_NAME)" > $(PKG_BUILD_DIR)/htdoc/.env.local
	npm --prefix $(PKG_BUILD_DIR)/htdoc install
endef

define Build/Compile
	npm --prefix $(PKG_BUILD_DIR)/htdoc run build
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/www/views
	$(CP) $(PKG_BUILD_DIR)//htdoc/dist/* $(1)/www/views
	if [ -d ./files -a -f ./files/menu.json ]; then \
		$(INSTALL_DIR) $(1)/usr/share/hiui/menu.d; \
		$(INSTALL_CONF) ./files/menu.json $(1)/usr/share/hiui/menu.d/$(APP_NAME).json; \
	fi
	if [ -d ./files/rpc ]; then \
		$(CP) ./files/rpc $(1)/usr/share/hiui/rpc; \
	fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

# call BuildPackage - OpenWrt buildroot signature
