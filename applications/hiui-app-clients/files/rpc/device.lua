#!/usr/bin/lua

local iwinfo = require "iwinfo"
local uci = require('uci').cursor()
local split = require "hiui.split"
local json = require 'cjson'

local mac = string.upper(arg[1])
local ip = arg[2]
local name = string.gsub(arg[3], '%s+', '')
local con_type = arg[4]

local function conType(_mac)
    local device = 'Wired'
    if con_type then
        device = 'Wired'
    else
        uci:foreach("wireless", "wifi-iface", function(s)
            local driver_type = iwinfo.type(s.ifname)
            if driver_type and iwinfo[driver_type]["assoclist"] then
                local assoclist = iwinfo[driver_type]["assoclist"](s.ifname)
                for key, value in pairs(assoclist) do
                    if key == _mac then device = s.device end
                end
            end
        end)
    end

    if device ~= 'Wired' then
        return uci:get("wireless", device, 'band')
    else
        return device
    end
end

local function writeFile(clients)
    local tmp = io.open("/etc/clients", "w")
    io.output(tmp)
    for index, value in ipairs(clients) do
        local line = string.format("%s  %s  %s  %s  %s  %s  %s  %s  %s  %s\n",
                                   value[1], value[2], value[3], value[4],
                                   value[5], value[6], value[7], value[8],
                                   value[9], value[10])
        io.write(line)
    end
    io.close(tmp)
end

local function updateDatas()
    local clients = {}
    local hasMac = false

    for line in io.lines("/etc/clients", "r") do

        local client = split(line, '%s+', false)
        if string.find(line, mac) then
            hasMac = true
            client[1] = mac
            if ip and name then
                client[2] = ip
                client[3] = name
            end
            client[4] = conType(mac)
            client[5] = 1
        end
        clients[#clients + 1] = client

    end

    if not hasMac then
        local client = {mac, ip, name, conType(mac), 1, 0, 0, 0, 0, 0}
        clients[#clients + 1] = client
    end

    writeFile(clients)
end

updateDatas()
