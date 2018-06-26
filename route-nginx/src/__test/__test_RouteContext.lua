local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local RouteContext = require("route.RouteContext")

local context1 = RouteContext:build()

ngx = {
    __TEST__ = {
        ip = "192.168.1.1",
        requestUri = '/index',
        requestParams = {
            mid = "19890123",
            sex = "男"
        }
    }
}

local context2 = RouteContext:build()

LogUtil.debug(StringUtil.toJSONString(context1))
LogUtil.debug(StringUtil.toJSONString(context2))