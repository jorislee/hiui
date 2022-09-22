local cjson = require 'cjson'
local rpc = require 'hiui.rpc'
local fs = require 'hiui.fs'
local uci = require 'uci'

local M = {}

function M.get_locale()
    local c = uci.cursor()
    local locale = c:get('hiui', 'global', 'locale')

    return {locale = locale}
end

function M.get_theme()
    local c = uci.cursor()
    local theme = c:get('hiui', 'global', 'theme')

    return {theme = theme}
end

function M.get_menus(param, session)
    local menus = {}

    for file in fs.dir('/usr/share/hiui/menu.d') do
        if file:match('^%w.*%.json$') then
            local data = fs.readfile('/usr/share/hiui/menu.d/' .. file)
            local menu = cjson.decode(data)
            for name, info in pairs(menu) do
                repeat
                    if name == '/wireless' and
                        not fs.access('/etc/config/wireless') then
                        break
                    end
                    if rpc.acl_match(session, menu, 'menu') then
                        menus[name] = info
                    end
                until true
            end
        end
    end

    return {menus = menus}
end

return M
