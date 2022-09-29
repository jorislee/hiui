local M = {}
local split = require "hiui.split"
local fs = require 'hiui.fs'
local json = require 'cjson'
local uci = require 'uci'

-- local function glinetApi(item, url)
--     local http = require("socket.http")
--     local ltn12 = require("ltn12")
--     local _f, err = io.popen("basename /tmp/gl_token* |awk -F'_' '{print $3}'")
--     if not _f then return nil, err end
--     local token = _f:read()
--     _f:close()
--     local request_body = item
--     local response_body = {}
--     http.request({
--         url = url,
--         method = "POST",
--         headers = {["Authorization"] = token},
--         source = ltn12.source.string(request_body),
--         sink = ltn12.sink.table(response_body)
--     })
--     local result = json.decode(table.concat(response_body))
--     return {result = result}
-- end

local function stringToBoolean(param, s)
    if param == s then
        return true
    else
        return false
    end
end

local function writeBak(clients)
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
        else
            io.write(value .. "\n")
        end

    end
    io.close(tmp)
end

function M.getClients()
    local c = uci.cursor()
    if fs.access('/etc/clients') then
        local clients = {}
        for line in io.lines("/etc/clients", "r") do
            local item = {}
            local tmp = split(line, '%s+', false)
            if #tmp == 11 then
                item.mac = tmp[1]
                item.ip = tmp[2]
                item.name = tmp[3]
                item.iface = tmp[4]
                item.online = stringToBoolean(tmp[5], '1')
                item.alive = tmp[6]
                item.blocked = stringToBoolean(tmp[7], '1')
                item.up = tmp[8]
                item.down = tmp[9]
                item.total_up = tmp[10]
                item.total_down = tmp[11]
                item.bind = false
                c:foreach('dhcp', 'host', function(s)
                    if s.mac == item.mac then
                        item.bind = true
                        return
                    end
                end)
                table.insert(clients, item)
            end
        end
        return {code = 0, clients = clients}

    else
        return {code = 404}
    end

end

function M.delClient(item)
    os.execute(string.format("sed -i '/%s/d' /etc/clients", item.mac))
    return {code = 0}
end

function M.addBlocked(item)
    if type(item) == "string" then item = json.decode(item) end
    local clients = {}
    for line in io.lines("/etc/clients", "r") do
        local needChange = false
        for index, value in ipairs(item.macs) do
            if string.find(line, value) then
                local client = split(line, '%s', false)
                client[7] = 1
                clients[#clients + 1] = client
                needChange = true
                break
            end
        end
        if not needChange then clients[#clients + 1] = line end
    end
    writeBak(clients)
    os.execute("cp /tmp/clients_bak /etc/clients")
    for index, mac in ipairs(item.macs) do
        os.execute(string.format("ipset add block_device %s", mac))
    end
    return {code = 0}
end

function M.delBlocked(item)
    if type(item) == "string" then item = json.decode(item) end
    local clients = {}
    for line in io.lines("/etc/clients", "r") do
        local needChange = false
        for index, mac in ipairs(item.macs) do
            if string.find(line, mac) then
                local client = split(line, '%s', false)
                client[7] = 0
                clients[#clients + 1] = client
                needChange = true
                break
            end
        end
        if not needChange then clients[#clients + 1] = line end
    end
    writeBak(clients)
    os.execute("cp /tmp/clients_bak /etc/clients")
    for index, mac in ipairs(item.macs) do
        os.execute(string.format("ipset del block_device %s", mac))
    end
    return {code = 0}
end

function M.setQos(item) return {code = 0} end

function M.setTraffic(params)
    local c = uci.cursor()
    c:set('hiui', 'global', 'traffic', params.enable)
    c:commit('hiui')
    if fs.access('/etc/config/glconfig') then
        if c:get('glconfig', 'traffic_control', 'enable') == nil then
            c:set('glconfig', 'traffic_control', 'service')
        end
        c:set('glconfig', 'traffic_control', 'enable', params.enable)
        c:commit('glconfig')
        if params.enable == '1' then
            os.execute('gltraffic &')
        else
            os.execute('killall gltraffic')
        end
    end
end

function M.getTraffic(params)
    local c = uci.cursor()
    local result = {}
    local tmp = c:get('hiui', 'global', 'traffic')
    if tmp == "1" then
        result.enable = true
    else
        result.enable = false
    end
    return result
end

return M
