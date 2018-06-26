local _M = {}

local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local RouteService = require("respository.RouteService")

function _M.run(args)
    LogUtil.debug(StringUtil.toJSONString(RouteService.queryAvailableRuleGroups()))
end

return _M