local M = {}

local C = require 'hiui.internal.network'

for k, v in pairs(C) do
    M[k] = v
end

return M
