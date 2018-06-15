local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local RouteContext = require("route.RouteContext")
local RuleGroup = require("rule.RuleGroup")

local group = RuleGroup:new(1, 'HTTP', 100)
local r1 = group:add({
    ruleType = 'IP_RANGE',
    groupId = 1,
    ruleStr = '192.168.1.1~192.168.1.9',
    cluster = 'beta1',
    priority = 1
})
LogUtil.debug(StringUtil.toJSONString(r1))

local r2 = group:add({
    ruleType = 'PARAM_TAIL',
    groupId = 1,
    ruleStr = 'mid~3,001,002,003',
    cluster = 'beta2',
    priority = 2
})
LogUtil.debug(StringUtil.toJSONString(r2))

local r3 = group:add({
    ruleType = 'WHITE_PARAM',
    groupId = 1,
    ruleStr = 'instMid,I01,INST-I03,I03',
    cluster = 'beta3',
    priority = 3
})
LogUtil.debug(StringUtil.toJSONString(r3))

LogUtil.debug(StringUtil.toJSONString(group))

ngx = {
    __TEST__ = {
        ip = "172.168.1.3",
        requestUri = '/index',
        requestParams = {
            mid = "19890123",
            sex = "男",
            instMid = "INST-I03"
        }
    }
}

local context = RouteContext:build()

local ret1 = group:getCluster(context)
LogUtil.debug(StringUtil.toJSONString(ret1))


local CJson = require("cjson")
local group2 = RuleGroup:clone(CJson.decode(CJson.encode(group)))
LogUtil.debug(StringUtil.toJSONString(group2))
LogUtil.debug(StringUtil.toJSONString(group2:getCluster(context)))