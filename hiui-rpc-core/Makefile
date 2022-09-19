#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk
include ../version.mk

PKG_NAME:=hiui-rpc-core
PKG_VERSION:=$(strip $(call findrev))
PKG_RELEASE:=1

PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>
PKG_LICENSE:=MIT

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/hiui-rpc-core
  SECTION:=hiui
  CATEGORY:=Hiui
  TITLE:=Hiui rpc core
  URL:=https://github.com/zhaojh329/hiui
  DEPENDS:=+liblua +libuci-lua +libiwinfo-lua +libubus-lua +lua-cjson +luasocket
endef

define Package/hiui-rpc-core/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/nginx/conf.d $(1)/etc/nginx/lua \
		$(1)/usr/share/hiui $(1)/usr/lib/lua/hiui $(1)/usr/share/hiui/acl
	$(INSTALL_CONF) ./files/hiui.config $(1)/etc/config/hiui
	$(INSTALL_CONF) ./files/ngx/hiui.locations $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) ./files/ngx/hiui.conf $(1)/etc/nginx/conf.d
	$(INSTALL_CONF) ./files/ngx/hiui-rpc.lua $(1)/etc/nginx/lua
	$(INSTALL_CONF) ./files/ngx/hiui-upload.lua $(1)/etc/nginx/lua
	$(INSTALL_CONF) ./files/ngx/hiui-download.lua $(1)/etc/nginx/lua
	$(INSTALL_CONF) ./files/admin.acl $(1)/usr/share/hiui/acl/admin.json
	$(CP) ./files/lib/hiui $(1)/usr/lib/lua
	$(CP) ./files/lib/resty $(1)/usr/lib/lua
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/hiui $(1)/usr/lib/lua
	$(CP) ./files/rpc $(1)/usr/share/hiui
endef

$(eval $(call BuildPackage,hiui-rpc-core))
