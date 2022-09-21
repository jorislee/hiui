local M = {}
local uci = require("uci").cursor()

function M.speedStatus()
    local tmp = io.popen('wg', 'r')
    local status
    if tmp then status = tmp:read("*a") end
    local service = uci:get_all('wireguard')
    return {wg = status, service = service, code = 0}
end

return M
