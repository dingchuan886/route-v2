local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local IpRangeRule = require("rule.IpRangeRule")
local RouteContext = require("route.RouteContext")

LogUtil.debug(StringUtil.toJSONString(IpRangeRule.parse('')))
LogUtil.debug(StringUtil.toJSONString(IpRangeRule.parse('172.168.1.1~2896691465')))

ngx = {
    __TEST__ = {
        ip = "192.168.1.3",
        requestUri = '/index',
        requestParams = {
            mid = "19890123",
            sex = "男"
        }
    }
}

local context = RouteContext:build()

local rule1 = IpRangeRule:new('172.168.1.1~2896691465', 'beta1', 100)
local rule2 = IpRangeRule:new('192.168.1.1~192.168.1.9', 'beta2', 200)

LogUtil.debug(StringUtil.toJSONString(rule1:checkMatched(context)))
LogUtil.debug(StringUtil.toJSONString(rule2:checkMatched(context)))