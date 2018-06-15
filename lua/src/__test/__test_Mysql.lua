local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local IpRangeRule = require("rule.IpRangeRule")
local RouteContext = require("route.RouteContext")
local Mysql = require("respository.mysql.Mysql")

LogUtil.debug(StringUtil.toJSONString(Mysql.query([[
    show tables
]])))