local _M = {}
_M._VERSION = '1.0'

local Mysql = require("respository.mysql.Mysql")
local ErrCode = require("common.ErrCode")
local Constant = require("common.Constant")
local Result = require("common.Result")
local Config = require("common.Config")
local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")

--------------------------------------------------------------------------------------
-- 查询有效的路由分组（包括路由规则）
-- 若路由分组下面没有一条有效的路由规则，那么路由分组也无效
-- 查询路由规则和路由分组状态都必须为ON的
--------------------------------------------------------------------------------------
function _M.queryAvailableRuleGroupsByCache()
    if ngx and ngx.shared then
        local cache = ngx.shared[Config.ROUTE_SHARED_DICT_KEY]
        if cache == nil then
            return {}
        end
        return StringUtil.toJSONObject(cache:get(Constant.AVAILABLE_RULE_GROUPS_KEY)) or {}
    end

    local rlt = _M.queryAvailableRuleGroups()
    return rlt.success and rlt.data or {}
end

function _M.queryAvailableRuleGroups()
    local routeRuleGroupRlt = Mysql.query([[select * from route_rule_group where status = 'ON']], Constant.RULE_GROUP_COLUMN_MAPPING)
    if not routeRuleGroupRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由分组失败')
    end

    local routeRuleRlt = Mysql.query([[select * from route_rule where status = 'ON']], Constant.RULE_COLUMN_MAPPING)
    if not routeRuleRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由规则失败')
    end

    local routeRuleGroup, routeRule = routeRuleGroupRlt.data, routeRuleRlt.data
    if not next(routeRuleGroup) or not next(routeRule) then
        return ErrCode.RULE_DATA_ERROR:detailErrorMsg('没有有效的路由分组数据信息，路由分组为空或者路由分组下面的分组规则为空')
    end

    local groupSet = {}
    for i = 1, #routeRuleGroup do
        local group = routeRuleGroup[i]
        group.rules = {}
        groupSet[group.groupId] = group
    end
    for i = 1, #routeRule do
        local rule = routeRule[i]
        local group = groupSet[rule.groupId]
        if group and group.rules then
            table.insert(group.rules, rule)
        end
    end

    -- 若分组下面没有有效的规则，那么分组也无效，需要删除
    local result = {}
    for _, group in pairs(groupSet) do
        if group and group.rules and next(group.rules) then
            table.insert(result, group)
        end
    end

    -- 优先级降序排序
    table.sort(result, function(left, right)
        return left.priority > right.priority
    end)
    for i = 1, #result do
        table.sort(result[i].rules, function(left, right)
            return left.priority > right.priority
        end)
    end

    -- 计算成功，那么存入cache
    if ngx and ngx.shared then
        local cache = ngx.shared[Config.ROUTE_SHARED_DICT_KEY]
        if cache == nil then
            return ErrCode.NGX_CACHE_ERROR
        end
        cache:set(Constant.AVAILABLE_RULE_GROUPS_KEY, StringUtil.toJSONString(result))
    end

    return Result:newSuccessResult(result)
end

--------------------------------------------------------------------------------------
-- 路由分组增删改查
--------------------------------------------------------------------------------------
function _M.listRuleGroups()
    local queryRlt = Mysql.query([[select * from route_rule_group]], Constant.RULE_GROUP_COLUMN_MAPPING)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由分组失败')
    end
    return queryRlt
end

function _M.ruleGroupSize()
    local queryRlt = Mysql.query([[select count(1) as num from route_rule_group]], true)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库查询路由分组总数失败')
    end
    return Result:newSuccessResult(queryRlt.data[1]['NUM'])
end

function _M.queryRuleGroup(groupId)
    local sqlQuery = [[
        select * from route_rule_group where group_id = %s
    ]]
    local queryRlt = Mysql.query(string.format(sqlQuery, groupId), Constant.RULE_GROUP_COLUMN_MAPPING)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由分组失败')
    end
    if not next(queryRlt.data) then
        return ErrCode.RULE_DATA_ERROR:detailErrorMsg('路由分组不存在')
    end
    return Result:newSuccessResult((queryRlt.data)[1])
end

function _M.addRuleGroup(ruleGroup)
    local sqlStr = [[
        insert into route_rule_group (app_name, priority, status, protocol, group_desc, create_time, update_time)
        values ('%s', %s, '%s', '%s', '%s', now(), now())
    ]]
    local insertRlt = Mysql.execute(string.format(sqlStr, ruleGroup.appName, ruleGroup.priority, ruleGroup.status, ruleGroup.protocol, ruleGroup.groupDesc))
    if not insertRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库插入路由分组失败')
    end
    return ErrCode.SUCCESS
end

function _M.updateRuleGroup(ruleGroup)
    local sqlStr = [[
        update route_rule_group
        set app_name = '%s',
        priority = %s,
        status = '%s',
        protocol = '%s',
        group_desc = '%s',
        update_time = now()
        where group_id = %s
    ]]
    local updateRlt = Mysql.execute(string.format(sqlStr, ruleGroup.appName, ruleGroup.priority, ruleGroup.status, ruleGroup.protocol, ruleGroup.groupDesc, ruleGroup.groupId))
    if not updateRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库更新路由分组失败')
    end
    return ErrCode.SUCCESS
end

function _M.deleteRuleGroup(groupId)
    local sqlStr = [[
        delete from route_rule_group
        where group_id = %s
    ]]
    local deleteRlt = Mysql.execute(string.format(sqlStr, groupId))
    if not deleteRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库删除路由分组失败')
    end
    return ErrCode.SUCCESS
end

--------------------------------------------------------------------------------------
-- 路由规则增删改查
--------------------------------------------------------------------------------------
function _M.listRules(groupId)
    local sqlQuery = [[
        select * from route_rule where group_id = %s
    ]]
    local queryRlt = Mysql.query(string.format(sqlQuery, groupId), Constant.RULE_GROUP_COLUMN_MAPPING)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由分组失败')
    end
    return queryRlt
end

function _M.ruleSize(groupId)
    local sqlQuery = [[
        select count(1) as num from route_rule where group_id = %s
    ]]
    local queryRlt = Mysql.query(string.format(sqlQuery, groupId), true)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库查询分组下面的规则总数失败')
    end
    return Result:newSuccessResult(queryRlt.data[1]['NUM'])
end

function _M.queryRule(ruleId)
    local sqlQuery = [[
        select * from route_rule where rule_id = %s
    ]]
    local queryRlt = Mysql.query(string.format(sqlQuery, ruleId), Constant.RULE_COLUMN_MAPPING)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取路由规则失败')
    end
    if not next(queryRlt.data) then
        return ErrCode.RULE_DATA_ERROR:detailErrorMsg('路由规则不存在')
    end
    return Result:newSuccessResult((queryRlt.data)[1])
end

function _M.addRule(rule)
    local sqlStr = [[
        insert into route_rule (group_id, rule_type, rule_str, cluster, priority, status, create_time, update_time)
        values (%s, '%s', '%s', '%s', %s, '%s', now(), now())
    ]]
    local insertRlt = Mysql.execute(string.format(sqlStr, rule.groupId, rule.ruleType, rule.ruleStr, rule.cluster, rule.priority, rule.status))
    if not insertRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库插入路由规则失败')
    end
    return ErrCode.SUCCESS
end

function _M.updateRule(rule)
    local sqlStr = [[
        update route_rule
        set rule_type = '%s',
        rule_str = '%s',
        cluster = '%s',
        priority = %s,
        status = '%s',
        update_time = now()
        where rule_id = %s
    ]]
    local updateRlt = Mysql.execute(string.format(sqlStr, rule.ruleType, rule.ruleStr, rule.cluster, rule.priority, rule.status, rule.ruleId))
    if not updateRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库更新路由规则失败')
    end
    return ErrCode.SUCCESS
end

function _M.deleteRule(ruleId)
    local sqlStr = [[
        delete from route_rule
        where rule_id = %s
    ]]
    local deleteRlt = Mysql.execute(string.format(sqlStr, ruleId))
    if not deleteRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库删除路由规则失败')
    end
    return ErrCode.SUCCESS
end

--------------------------------------------------------------------------------------
-- 查询有效的集群信息
--------------------------------------------------------------------------------------
function _M.queryAvailableClusterByCache()
    if ngx and ngx.shared then
        local cache = ngx.shared[Config.ROUTE_SHARED_DICT_KEY]
        if cache == nil then
            return {}
        end
        return StringUtil.toJSONObject(cache:get(Constant.AVAILABLE_CLUSTER_KEY)) or {}
    end

    local rlt = _M.queryAvailableRuleGroups()
    return rlt.success and rlt.data or {}
end

function _M.queryAvailableCluster()
    local clusterRlt = Mysql.query([[select * from route_cluster where status = 'ON']], Constant.CLUSTER_COLUMN_MAPPING)
    if not clusterRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取集群信息失败')
    end

    if not next(clusterRlt.data) then
        return ErrCode.RULE_DATA_ERROR:detailErrorMsg('没有有效的集群信息')
    end

    if clusterRlt.success then
        -- 计算成功，那么存入cache
        if ngx and ngx.shared then
            local cache = ngx.shared[Config.ROUTE_SHARED_DICT_KEY]
            if cache == nil then
                return ErrCode.NGX_CACHE_ERROR
            end
            cache:set(Constant.AVAILABLE_CLUSTER_KEY, StringUtil.toJSONString(clusterRlt.data))
        end
    end

    return clusterRlt
end

--------------------------------------------------------------------------------------
-- 集群增删查改
--------------------------------------------------------------------------------------
function _M.listClusters()
    local queryRlt = Mysql.query([[select * from route_cluster]], Constant.CLUSTER_COLUMN_MAPPING)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取集群信息失败')
    end
    return queryRlt
end

function _M.clusterSize()
    local queryRlt = Mysql.query([[select count(1) as num from route_cluster]], true)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库查询集群总数失败')
    end
    return Result:newSuccessResult(tonumber(queryRlt.data[1]['NUM']))
end

function _M.queryCluster(clusterId)
    local sqlQuery = [[
        select * from route_cluster where cluster_id= %s
    ]]
    local queryRlt = Mysql.query(string.format(sqlQuery, clusterId), Constant.CLUSTER_COLUMN_MAPPING)
    if not queryRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库读取集群信息失败')
    end
    if not next(queryRlt.data) then
        return ErrCode.RULE_DATA_ERROR:detailErrorMsg('集群不存在')
    end
    return Result:newSuccessResult(queryRlt.data[1])
end

function _M.addCluster(cluster)
    local sqlStr = [[
        insert into route_cluster (cluster, addresses, status, cluster_desc, create_time, update_time)
        values ('%s', '%s', '%s', '%s', now(), now())
    ]]
    local insertRlt = Mysql.execute(string.format(sqlStr, cluster.cluster, cluster.addresses, cluster.status, cluster.clusterDesc))
    if not insertRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库插入集群失败')
    end
    return ErrCode.SUCCESS
end

function _M.updateCluster(cluster)
    local sqlStr = [[
        update route_cluster
        set cluster = '%s',
        addresses = '%s',
        status = '%s',
        cluster_desc = '%s',
        update_time = now()
        where cluster_id = %s
    ]]
    local updateRlt = Mysql.execute(string.format(sqlStr, cluster.cluster, cluster.addresses, cluster.status, cluster.clusterDesc, cluster.clusterId))
    if not updateRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库更新集群失败')
    end
    return ErrCode.SUCCESS
end

function _M.deleteCluster(clusterId)
    local sqlStr = [[
        delete from route_cluster
        where cluster_id = %s
    ]]
    local deleteRlt = Mysql.execute(string.format(sqlStr, clusterId))
    if not deleteRlt.success then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库删除集群失败')
    end
    return ErrCode.SUCCESS
end

return _M