--[[
    路由上下文对象
]]--
local _M = {}
_M._VERSION = '1.0'

local mt = { __index = _M }

local IpUtil = require("util.IpUtil")
local NgxUtil = require("util.NgxUtil")

function _M.build(self)
    self = {}

    self.ip = NgxUtil.getIp()
    self.longIP = IpUtil.ip2Long(self.ip)
    self.requestUri = NgxUtil.getRequestUri()
    self.requestParams = NgxUtil.getRequestParams()

    return setmetatable(self, mt)
end

return _M