local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local ParamTailRule = require("rule.ParamTailRule")
local RouteContext = require("route.RouteContext")

LogUtil.debug(StringUtil.toJSONString(ParamTailRule.parse('')))
LogUtil.debug(StringUtil.toJSONString(ParamTailRule.parse('mid~3,001,002,003')))

ngx = {
    __TEST__ = {
        ip = "192.168.1.3",
        requestUri = '/index',
        requestParams = {
            mid = "19890123",
            instMid = "INST-I03",
            sex = "男"
        }
    }
}

local context = RouteContext:build()

local rule1 = ParamTailRule:new('mid~3,001,002,003', 'beta1', 100)
local rule2 = ParamTailRule:new('instMid~3,I01,I02,I03', 'beta2', 200)

LogUtil.debug(StringUtil.toJSONString(rule1:checkMatched(context)))
LogUtil.debug(StringUtil.toJSONString(rule2:checkMatched(context)))