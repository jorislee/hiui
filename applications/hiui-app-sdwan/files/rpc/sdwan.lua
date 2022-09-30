local M = {}
local uci = require("uci").cursor()
local https = require("ssl.https")
local json = require 'cjson'

function M.status()
    local tmp = io.popen("wg", "r")
    local status
    if tmp then status = tmp:read("*a") end
    local service = uci:get_all("wireguard")
    return {wg = status, service = service, code = 0}
end

function M.getSpeed()
    local result = {}
    local f = io.popen('wg_speed.sh wg0')
    if f then
        local req = f:read("*a")
        if string.len(req) > 10 then result = json.decode(req) end
        f:close()
    end
    return result
end

function M.enable(params)
    uci:foreach("wireguard", "proxy", function(s)
        uci:set("wireguard", s[".name"], "enable", params.enable)
    end)
    if params.enable == "1" then
        os.execute("/etc/init.d/wireguard stop")
    else
        os.execute("/etc/init.d/wireguard start")
    end
end

function M.getShunt()
    local ltn12 = require("ltn12")
    local rtty = uci:get_all("rtty")
    local tmp = io.popen("awk -F'/' '/hi-th-api/ {print $2}' /etc/dnsmasq.conf")
    local host
    if tmp then
        host = tmp:read()
        if rtty.general.ssl == '1' then
            host = "https://" .. host .. "/hi/shunt/list/"
        else
            host = "http://" .. host .. '/hi/shunt/list/'
        end
        tmp:close()
    end
    local response_body = {}
    https.request({
        url = host .. rtty.general.id,
        method = "GET",
        headers = {["onlyid"] = rtty.general.onlyid},
        sink = ltn12.sink.table(response_body)
    })
    local result = json.decode(table.concat(response_body))
    return {result = result}
end

return M
