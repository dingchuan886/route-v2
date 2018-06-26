local _M = {}

local Route = require("route.Route")
local LogUtil = require("util.LogUtil")

function _M.run()
    local routeRlt = Route.route("test", "HTTP")
    if routeRlt.success then
        local balancer = require("ngx.balancer")
        local ok, err = balancer.set_current_peer(routeRlt.data.ip, routeRlt.data.port)
        LogUtil.debug("ok:", ok, ",err:", err)
    end
end

return _M