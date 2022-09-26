#!/usr/lib/lua

local M = {}
local fs = require 'hiui.fs'
local json = require 'cjson'
local uci = require('uci').cursor()
function M.checkFirmwareVersion()
    local result = {}
    if fs.access('/tmp/firmware.info') then
        local f, err = io.open('/tmp/firmware.info', 'r')
        if f then
            local content = f:read("*a")
            result = json.decode(content)
        end
    end
    local v, err = fs.readfile('/etc/glversion')
    if not v then
        f = io.popen(
                "cat /etc/openwrt_release|grep DISTRIB_RELEASE |awk -F'=' '{gsub(/\\047/,\"\"); print $2}'")
        if f then v = f:read("*a") end
    end
    result.curVer = v
    local ct, err = fs.readfile('/etc/version.date')
    result.compileTime = ct
    return result

end

function M.downloadFirmware(url)
    os.execute("curl -s -o /tmp/firmware.bin %s &" % url)
end

function M.downloadProgress()
    local process = {}
    local info = fs.stat('/tmp/firmware.bin')
    process.size = info.size
    return process
end

function M.checkWebVersion()
    local result = {}
    if fs.access('/tmp/webui.info') then
        local f, err = io.open('/tmp/webui.info', 'r')
        if f then
            local content = f:read("*a")
            result = json.decode(content)
        end
    end
    local f = io.popen(
                  "opkg info hiui-ui-core |grep -E 'Version|Architecture' |awk '{print $2=$2}'")
    if f then
        local ver = f:read()
        local arch = f:read()
        result.curVer = ver
        result.arch = arch
    end
    return result
end

return M
