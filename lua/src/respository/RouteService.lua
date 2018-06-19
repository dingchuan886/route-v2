local _M = {}
_M._VERSION = '1.0'

local Mysql = require("respository.mysql.Mysql")
local ErrCode = require("common.ErrCode")
local Constant = require("common.Constant")

function _M.queryAvailableRuleGroups()
    local sqlSelectRouteRuleGroup, sqlSelectRouteRule = [[
        select * from route_rule_group where status = 'ON'
    ]], [[
        select * from route_rule where status = 'ON'
    ]]

    local routeRuleGroupRlt = Mysql.query(sqlSelectRouteRuleGroup, Constant.RULE_GROUP_COLUMN_MAPPING)
    if not routeRuleGroupRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由分组数据失败')
    end

    local routeRuleRlt = Mysql.query(sqlSelectRouteRule, Constant.RULE_COLUMN_MAPPING)
    if not routeRuleRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由规则数据失败')
    end

    local result = {}
    for i = 1, #routeRuleGroupRlt do
        local group = routeRuleGroupRlt[i]
        result[group.groupId] = group
    end
    for i = 1, #routeRuleRlt do
        local rule = routeRuleRlt[i]
        local group = result[rule.groupId]
        if group then
            if group.rules then
                table.insert(group.rules, rule)
            else
                group.rules = { rule }
            end
        end
    end
    return result
end

return _M