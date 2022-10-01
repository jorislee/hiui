#!/usr/bin/lua

local iwinfo = require "iwinfo"
local uci = require('uci').cursor()
local split = require "hiui.split"

local mac = string.upper(arg[1])
local ip = arg[2]
local name
if arg[3] then
    name = string.gsub(arg[3], '%s+', '')
else
    name = 'unknown'
end
local con_type
local online
if arg[4] == 'Wired' then
    con_type = arg[4]
else
    online = arg[4] == "0x2" and 1 or 0
end

local function conType(_mac)
    local device = 'Wired'
    local found = false
    if con_type == "Wired" then
        device = 'Wired'
    else
        uci:foreach("wireless", "wifi-iface", function(s)
            if s.ifname and not found then
                local driver_type = iwinfo.type(s.ifname)
                if driver_type and iwinfo[driver_type]["assoclist"] then
                    local assoclist = iwinfo[driver_type]["assoclist"](s.ifname)
                    for key, value in pairs(assoclist) do
                        if key == _mac then
                            device = s.device
                            found = true
                            return
                        end
                    end
                end
            end
        end)
    end

    if device ~= 'Wired' then return uci:get("wireless", device, 'band') end
    return device
end

local function writeFile(clients)
    local tmp = io.open("/tmp/clients_bak", "w")
    io.output(tmp)
    for index, value in ipairs(clients) do
        if value[1] and value[11] then
            local line = string.format(
                             "%s  %s  %s  %s  %s  %s  %s  %s  %s  %s  %s\n",
                             value[1], value[2], value[3], value[4], value[5],
                             value[6], value[7], value[8], value[9], value[10],
                             value[11])
            io.write(line)
        end
    end
    io.close(tmp)
end

local function updateDatas()
    local clients = {}
    local hasMac = false

    for line in io.lines("/etc/clients", "r") do
        if string.len(line) > 10 then
            local client = split(line, '%s+', false)
            if string.find(line, mac) then
                hasMac = true
                client[1] = mac
                if ip and name then
                    client[2] = ip
                    client[3] = name
                end
                if client[4] ~= "Wired" then
                    client[4] = conType(mac)
                end
                client[5] = online
            end
            clients[#clients + 1] = client
        end
    end

    if not hasMac then
        local client = {mac, ip, name, conType(mac), 1, 0, 0, 0, 0, 0, 0}
        clients[#clients + 1] = client
    end

    writeFile(clients)
    os.execute("cp /tmp/clients_bak /etc/clients")
end

updateDatas()
