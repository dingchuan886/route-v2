local _M = {}

local Route = require("route.Route")
local LogUtil = require("util.LogUtil")
local StringUtil = require("util.StringUtil")

function _M.run()
    local rlt = Route.route("netpay-wxpay-open", "HTTP")
    LogUtil.debug('route rlt = ', StringUtil.toJSONString(rlt))
end

return _M