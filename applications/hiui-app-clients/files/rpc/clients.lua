local M = {}
local split = require "hiui.split"
local fs = require 'hiui.fs'
local json = require 'cjson'

function M.getClients()
    if not fs.access('/tmp/tertf/tertfinfo') then
        local f, err = io.open('/tmp/tertf/', 'r')
        if not f then return nil, err end
        local line = f:read("*l")
        local clients = {}
        while line do
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
            line = f:read("*l")
        end
        return {clients = clients}
    else
        local socket = require("socket")
        local _f, err = io.popen(
                            "basename /tmp/gl_token* |awk -F'_' '{print $3}'")
        if not _f then return nil, err end
        local token = _f:read()
        _f:close()
        local request_body = {}
        local response_body = {}
        socket.http.request {
            url = "http://127.0.0.1/cgi-bin/api/client/list",
            method = "GET",
            headers = {["Authorization"] = token},
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body)
        }
        local result = json.decode(table.concat(response_body))
        return {result = result}
    end

end

function M.delClient(item)
    if not fs.access('/tmp/tertf/tertfinfo') then
        os.execute("sed -i '/%s/d' /etc/clients" % item.mac)
        return {code = 0}
    else
        local socket = require("socket")
        local _f, err = io.popen(
                            "basename /tmp/gl_token* |awk -F'_' '{print $3}'")
        if not _f then return nil, err end
        local token = _f:read()
        _f:close()
        local request_body = item
        local response_body = {}
        socket.http.request {
            url = "http://127.0.0.1/cgi-bin/api/client/offline_client/del",
            method = "POST",
            headers = {["Authorization"] = token},
            source = ltn12.source.string(request_body),
            sink = ltn12.sink.table(response_body)
        }
        local result = json.decode(table.concat(response_body))
        return {result = result}
    end
end

function M.addBlocked(item)
    os.execute("ipset add block_device %s" % item.mac)
    return {code = 0}
end

function M.delBlocked(item)
    os.execute("ipset del block_device %s" % item.mac)
    return {code = 0}
end

function M.setQos(item)
    os.execute("ehco %s" % item.mac)
    return {code = 0}
end

function M.traffic(params)
    if params.action == 'start' then
        print('start')
    elseif params.action == 'stop' then
        print('stop')
    end
end

return M
