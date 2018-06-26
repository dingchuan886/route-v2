local _M = {}

local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local Mysql = require("respository.mysql.Mysql")

-- 没有办法在本地执行的单元测试按照此格式编写，可以直接通过nginx配置url来执行
function _M.run()
    LogUtil.debug(StringUtil.toJSONString(Mysql.query([[
        show tables
    ]])))

    LogUtil.debug(StringUtil.toJSONString(Mysql.query([[
        show tables
    ]], true)))

    LogUtil.debug(StringUtil.toJSONString(Mysql.query([[
        show tables
    ]], { TABLES_IN_ROUTE_V2 = "table" })))

    LogUtil.debug(StringUtil.toJSONString(Mysql.query([[
        show tables
    ]], { tables_in_route_v2 = "table" })))
end

return _M