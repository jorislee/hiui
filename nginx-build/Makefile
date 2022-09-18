#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk

APP_TITLE:=nginx-build
APP_NAME:=nginx-build
APP_DEPENDS:=+nginx-ssl +@NGINX_HTTP_GZIP_STATIC +@NGINX_HTTP_ACCESS +@NGINX_HTTP_REWRITE +@NGINX_LUA
include ../hiui.mk

# call BuildPackage - OpenWrt buildroot signature
