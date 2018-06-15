local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local WhiteParamRule = require("rule.WhiteParamRule")
local RouteContext = require("route.RouteContext")

LogUtil.debug(StringUtil.toJSONString(WhiteParamRule.parse('')))
LogUtil.debug(StringUtil.toJSONString(WhiteParamRule.parse('mid,0123,002,003')))

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

local rule1 = WhiteParamRule:new('mid,19890123,002,003', 'beta1', 100)
local rule2 = WhiteParamRule:new('instMid~3,I01,INST-I03,I03', 'beta2', 200)

LogUtil.debug(StringUtil.toJSONString(rule1:checkMatched(context)))
LogUtil.debug(StringUtil.toJSONString(rule2:checkMatched(context)))

local CJson = require("cjson")
local rule3 = WhiteParamRule:clone(CJson.decode(CJson.encode(rule1)))
LogUtil.debug(StringUtil.toJSONString(rule3))
LogUtil.debug(StringUtil.toJSONString(rule3:checkMatched(context)))