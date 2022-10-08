local M = {}
local iwinfo = require 'iwinfo'
local uci = require("uci").cursor()

local function trim(s)
    local result, err = string.gsub(s, ":", "")
    return result
end

local function isIntable(value, tb)
    for k, v in pairs(tb) do if v == value then return true end end
    return false
end

local function addHistory(params)
    uci:set("hiui", trim(params.bssid), "history-sta")
    uci:set("hiui", trim(params.bssid), "ssid", params.ssid)
    uci:set("hiui", trim(params.bssid), "bssid", params.bssid)
    uci:set("hiui", trim(params.bssid), "key", params.key)
    uci:set("hiui", trim(params.bssid), "device", params.device)
    uci:set("hiui", trim(params.bssid), "encryption", params.encryption)
    uci:set("hiui", trim(params.bssid), "channel", params.channel)
    uci:commit("hiui")
end

function M.scan()
    local devices = {}
    local scanResult = {}
    uci:foreach("wireless", "wifi-iface", function(s)
        if not isIntable(s.device, devices) then
            devices[#devices + 1] = s.device
        end
    end)
    for key, value in pairs(devices) do
        local driver_type = iwinfo.type(value)
        if driver_type and iwinfo[driver_type]["scanlist"] then
            local tmp = iwinfo[driver_type]["scanlist"](value)
            scanResult[value] = tmp
        end
    end

    return scanResult
end

function M.join(params)
    uci:set("wireless", "sta", "wifi-iface")
    assert(params.device, "no device")
    uci:set("wireless", "sta", "device", params.device)
    uci:set("wireless", "sta", "mode", "sta")
    uci:set("wireless", "sta", "ifname", "wlan-sta")
    uci:set("wireless", "sta", "network", "wwan")
    assert(params.ssid, "no ssid")
    uci:set("wireless", "sta", "ssid", params.ssid)
    assert(params.bssid, "no bssid")
    uci:set("wireless", "sta", "bssid", params.bssid)
    assert(params.encryption, "no encryption")
    uci:set("wireless", "sta", "encryption", params.encryption)
    assert(params.channel, "no channel")
    uci:set("wireless", "sta", "channel", params.channel)
    uci:set("wireless", params.device, "channel", params.channel)
    assert(params.key, "no key")
    uci:set("wireless", "sta", "key", params.key)
    uci:set("wireless", "sta", "disabled", '0')
    uci:set("wireless", params.device, "disabled", '0')

    uci:set("network", "wwan", "interface")
    uci:set("network", "wwan", "proto", "dhcp")

    local section
    local _tmp
    uci:foreach("firewall", "zone", function(s)
        if s.name == 'wan' then
            section = s['.name']
            _tmp = s.network
            if type(_tmp) == "string" and not string.find(_tmp, 'wwan') then
                _tmp = _tmp .. ' wwan'
            elseif type(_tmp) == "table" and not isIntable("wwan", _tmp) then
                table.insert(_tmp, "wwan")
            end
            return
        end
    end)
    assert(section, "no section")
    uci:delete("firewall", section, "network")
    uci:set("firewall", section, "network", _tmp)
    uci:commit("firewall")
    uci:commit("network")
    uci:commit("wireless")
    if params.remember then addHistory(params) end
    os.execute("/etc/init.d/firewall reload && wifi down;sleep 3;wifi up")
    return {code = 0}
end

function M.history()
    local result = {}
    uci:foreach("hiui", "history-sta", function(s) table.insert(result, s) end)
    return result
end

function M.delHistory(params)
    uci:delete("hiui", params[".name"])
    uci:commit("hiui")
    return {code = 0}
end

function M.updateHistory(params)
    assert(params.device, "no device")
    uci:set("wireless", "sta", "device", params.device)
    uci:set("wireless", "sta", "mode", "sta")
    uci:set("wireless", "sta", "network", "wwan")
    assert(params.ssid, "no ssid")
    uci:set("wireless", "sta", "ssid", params.ssid)
    assert(params.bssid, "no bssid")
    uci:set("wireless", "sta", "bssid", params.bssid)
    assert(params.encryption, "no encryption")
    uci:set("wireless", "sta", "encryption", params.encryption)
    assert(params.channel, "no channel")
    uci:set("wireless", "sta", "channel", params.channel)
    uci:set("wireless", params.device, "channel", params.channel)
    if params.key then
        uci:set("wireless", "sta", "key", params.key)
    else
        uci:set("wireless", "sta", "key", 'none')
    end

    uci:set("wireless", "sta", "disabled", '0')
    uci:set("wireless", params.device, "disabled", '0')
    uci:commit("wireless")
    uci:commit("hiui")
    os.execute("wifi down;sleep 3;wifi up")
    return {code = 0}
end

return M
