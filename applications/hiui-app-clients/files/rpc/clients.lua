local M = {}
local split = require "hiui.split"
local fs = require 'hiui.fs'
local json = require 'cjson'
local uci = require 'uci'

local function glinetApi(item, url)
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local _f, err = io.popen("basename /tmp/gl_token* |awk -F'_' '{print $3}'")
    if not _f then return nil, err end
    local token = _f:read()
    _f:close()
    local request_body = item
    local response_body = {}
    http.request({
        url = url,
        method = "POST",
        headers = {["Authorization"] = token},
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    })
    local result = json.decode(table.concat(response_body))
    return {result = result}
end

function M.getClients()
    if fs.access('/etc/clients') then
        local clients = {}
        for line in io.lines("/etc/clients", "r") do
            local item = {}
            local tmp = split(line, '%s', false)
            item.mac = tmp[1]
            item.ip = tmp[#item + 1]
            item.name = tmp[#item + 1]
            item.iface = tmp[#item + 1]
            item.online = tmp[#item + 1]
            item.alive = tmp[#item + 1]
            item.blocked = tmp[#item + 1]
            item.up = tmp[#item + 1]
            item.down = tmp[#item + 1]
            item.total = tmp[#item + 1]
            item.item.table.insert(clients, item)
        end
        return {clients = clients}

    else
        return {code = 404}
    end

end

function M.delClient(item)
    if not fs.access('/tmp/tertf/tertfinfo') then
        os.execute("sed -i '/%s/d' /etc/clients" % item.mac)
        return {code = 0}
    else
        return glinetApi(item,
                         "http://127.0.0.1/cgi-bin/api/client/offline_client/del")
    end
end

function M.addBlocked(item)
    local clients = {}
    for line in io.lines("/etc/clients", "r") do
        if string.find(line, item.mac) then
            local client = split(line, '%s', false)
            client[7] = 1
            clients[#clients + 1] = client
        end
    end
    local tmp = io.open("/etc/clients", "w")
    io.output(tmp)
    for index, value in ipairs(clients) do
        local line = string.format("%s  %s  %s  %s  %s  %s  %s  %s\n", value[1],
                                   value[2], value[3], value[4], value[5],
                                   value[6], value[7], value[8], value[9],
                                   value[10])
        io.write(line)
    end
    io.close(tmp)

    os.execute("ipset add block_device %s" % item.mac)

    return {code = 0}
end

function M.delBlocked(item)
    local clients = {}
    for line in io.lines("/etc/clients", "r") do
        if string.find(line, item.mac) then
            local client = split(line, '%s', false)
            client[7] = 0
            clients[#clients + 1] = client
        end
    end
    local tmp = io.open("/etc/clients", "w")
    io.output(tmp)
    for index, value in ipairs(clients) do
        local line = string.format("%s  %s  %s  %s  %s  %s  %s  %s\n", value[1],
                                   value[2], value[3], value[4], value[5],
                                   value[6], value[7], value[8], value[9],
                                   value[10])
        io.write(line)
    end
    io.close(tmp)
    os.execute("ipset del block_device %s" % item.mac)
    return {code = 0}
end

function M.setQos(item)
    if fs.access('/www/cgi-bin/api') then
        return glinetApi(item, "/cgi-bin/api/client/qos/set")
    end
    return {code = 0}
end

function M.setTraffic(params)
    local c = uci.cursor()
    if fs.access('/www/cgi-bin/api') then
        c:set('hiui', 'global', 'traffic', params.enable)
        c:commit('hiui')
        return glinetApi(params, "/cgi-bin/api/client/qos/set")
    end
end

function M.getTraffic(params)
    local c = uci.cursor()
    local result = {}
    local tmp = c:get('hiui', 'global', 'traffic')
    if tmp then
        result.enable = tmp
    else
        result.enable = false
    end
    return result
end

return M
