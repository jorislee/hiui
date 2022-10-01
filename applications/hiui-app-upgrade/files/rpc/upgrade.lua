#!/usr/lib/lua

local M = {}
local fs = require 'hiui.fs'
local json = require 'cjson'
local https = require 'ssl.https'
local split = require 'hiui.split'
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
    os.execute(string.format("curl -s -o /tmp/firmware.bin %s &", url))
end

function M.downloadProgress()
    local process = {}
    local info = fs.stat('/tmp/firmware.bin')
    process.size = info.size
    return process
end

function M.checkWebVersion()
    local result = {}
    local remote = {}
    local f = io.popen(
                  "awk '/Package: hiui/ {print $2;getline;print $2}' /usr/lib/opkg/status")

    if f then
        local loc = {}
        while true do
            local item = {}
            item.name = f:read()
            if not item.name then break end
            item.curVer = f:read()
            table.insert(loc, item)
        end
        f:close()
        result.loc = loc
    end

    if fs.access('/tmp/webui.info') then
        local f, err = io.open('/tmp/webui.info', 'r')
        if f then
            local content = f:read("*a")
            remote = json.decode(content)
        end
    else

        local ob = https.request(
                       'https://api.github.com/repos/zzzzzhy/hiui/releases')
        if ob then
            ob = json.decode(ob)
            local assets = ob[1].assets
            for index, value in ipairs(assets) do
                local rem = {}
                local tmp = split(value.name, '_')
                rem.name = tmp[1]
                rem.curVer = tmp[2]
                rem.downloadUrl = value.browser_download_url
                table.insert(remote, rem)
            end
        end

    end
    result.remote = remote
    f = io.popen(
            "grep -A5 -E 'Package: hiui-rpc-core' /usr/lib/opkg/status|awk '$1==\"Architecture:\" {print $2}'")
    local arch = f:read()
    result.arch = arch

    return result
end

function M.ipkUpgrade(params)
    local pkgs
    for index, value in ipairs(params) do pkgs = pkgs .. ' ' .. value end
    os.execute(string.format("opkg install %s", pkgs))
end

function M.reload() os.execute('/etc/init.d/nginx restart') end

return M
