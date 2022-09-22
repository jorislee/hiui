#!/usr/lib/lua

local M = {}
local fs = require 'hiui.fs'
local uci = require 'uci'
local http = require 'socket.http'
function M.checkFirmwareVersion()
    local c = uci.cursor()
    local url = c:get('hiui', 'global', 'host')
    local result = {}
    if url then result = http.request(url .. "/api/publish/device/checkver") end
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

return M
