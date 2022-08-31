local uci = require 'uci'

local M = {}

function M.get_users()
    local c = uci.cursor()
    local users = {}

    c:foreach('hiui', 'user', function(s)
        users[#users + 1] = {
            username = s.username,
            id = s['.name']
        }
    end)

    return { users = users }
end

function M.del_user(param)
    local c = uci.cursor()
    local id = param.id

    c:delete('hiui', id)
    c:commit('hiui')
end

function M.change_password(param)
    local c = uci.cursor()
    local password = param.password
    local id = param.id
    local username = c:get('hiui', id, 'username')
    c:set('hiui', id, 'password', ngx.md5(username .. ':' .. password))
    c:commit('hiui')
end

function M.add_user(param)
    local c = uci.cursor()
    local username = param.username
    local password = param.password
    local exist = false

    c:foreach('hiui', 'user', function(s)
        if s.username == username then
            exist = true
            return false
        end
    end)

    if exist then
        return { code = 1, errors = 'already exist' }
    end

    local sid = c:add('hiui', 'user')
    c:set('hiui', sid, 'username', username)
    c:set('hiui', sid, 'password', ngx.md5(username .. ':' .. password))
    c:commit('hiui')

    return { code = 0 }
end

return M
