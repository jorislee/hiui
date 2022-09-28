local fs = require 'hiui.fs'
local uci = require 'uci'

local M = {}

function M.get_cpu_time()
    local result = {}

    for line in io.lines('/proc/stat') do
        local cpu = line:match('^(cpu%d?)')
        if cpu then
            local times = {}
            for field in line:gmatch('%S+') do
                if not field:match('cpu') then
                    times[#times + 1] = tonumber(field)
                end
            end
            result[cpu] = times
        end
    end

    return {times = result}
end

function M.sysupgrade(param)
    ngx.timer.at(0.5, function()
        local arg = param.keep and '' or '-n'
        os.execute('sysupgrade ' .. arg .. ' /tmp/firmware.bin')
    end)
end

function M.create_backup(param)
    local path = param.path
    os.execute('sysupgrade -b ' .. path)
end

function M.list_backup(param)
    local path = param.path

    local f = io.popen('tar -tzf ' .. path)
    if not f then return end

    local files = f:read('*a')

    f:close()

    return {files = files}
end

function M.restore_backup(param)
    os.execute('sysupgrade -r ' .. param.path)

    ngx.timer.at(0.5, function() os.execute('reboot') end)
end

function M.reset()
    ngx.timer.at(0.5, function() os.execute('firstboot -y && reboot') end)
end

function M.getVersionAndSN()
    local c = uci.cursor()
    local f =
        io.popen("awk '/hiui-ui/ {getline;print $2}' /usr/lib/opkg/status")
    local version
    if f then
        version = f:read('*a')
        f:close()
    end
    local sn = c:get("rtty", "general", "id")
    return {code = 0, sn = sn, version = version, date = os.time()}
end

return M
