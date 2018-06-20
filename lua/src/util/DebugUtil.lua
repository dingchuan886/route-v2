local _M = {}
_M._VERSION = '1.0'

local Config = require("common.Config")

function _M.debugInvoke(func)
    if Config.DEBUG then
        func()
    end
end

return _M