local _M = {}
_M._VERSION = '1.0'

local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")
local RouteContext = require("route.RouteContext")
local RouteService = require("respository.RouteService")
local RuleGroup = require("rule.RuleGroup")
local ErrCode = require("common.ErrCode")
local DebugUtil = require("util.DebugUtil")
local Result = require("common.Result")
local os = require("os")

--------------------------------------------------------------------------------------
-- 路由判断，计算出需要走的cluster
--------------------------------------------------------------------------------------
local function routeCluster(appName, protocol)
    local context = RouteContext:build()
    DebugUtil.debugInvoke(function()
        LogUtil.debug("route context = ", StringUtil.toJSONString(context))
    end)

    local ruleGroupsRlt = RouteService.queryAvailableRuleGroups()
    if not ruleGroupsRlt.success then
        return ruleGroupsRlt
    end

    DebugUtil.debugInvoke(function()
        LogUtil.debug("ruleGroupsRlt = ", StringUtil.toJSONString(ruleGroupsRlt))
    end)

    local availableRuleGroups = {}
    for i = 1, #ruleGroupsRlt.data do
        local ruleGroup = ruleGroupsRlt.data[i]
        if ruleGroup.appName == appName and ruleGroup.protocol == protocol then
            table.insert(availableRuleGroups, ruleGroup)
        end
    end

    DebugUtil.debugInvoke(function()
        LogUtil.debug("availableRuleGroups = ", StringUtil.toJSONString(availableRuleGroups))
    end)

    if not next(availableRuleGroups) then
        return ErrCode.RULE_DATA_ERROR:detailErrorMsg('没有有效的路由分组数据信息')
    end

    -- 按照优先级排序
    table.sort(availableRuleGroups, function(left, right)
        return left.priority > right.priority
    end)

    local cluster
    for i = 1, #availableRuleGroups do
        local ruleGroup = RuleGroup:create(availableRuleGroups[i])
        local rlt = ruleGroup:getCluster(context)
        if rlt.success then
            -- 命中路由
            cluster = rlt.data.cluster

            DebugUtil.debugInvoke(function()
                LogUtil.debug("route cluster = ", StringUtil.toJSONString(rlt))
            end)

            return Result:newSuccessResult(cluster)
        end
    end

    return ErrCode.RULE_UN_HIT
end

--------------------------------------------------------------------------------------
-- 根据集群获取对应的IP+端口
--------------------------------------------------------------------------------------
local function getAddressByCluster(cluster)
    local clusterRlt = RouteService.queryAvailableCluster()
    if not clusterRlt.success then
        return clusterRlt
    end

    DebugUtil.debugInvoke(function()
        LogUtil.debug("route cluster = ", StringUtil.toJSONString(clusterRlt))
    end)

    local hitCluster
    for i = 1, #clusterRlt.data do
        if clusterRlt.data[i].cluster == cluster then
            hitCluster = clusterRlt.data[i]
            break
        end
    end

    if hitCluster == nil then
        return ErrCode.CLUSTER_UN_HIT:detailErrorMsg('路由命中的集群没有找到相匹配的地址信息（IP+端口）')
    end

    local addresses = hitCluster.addresses
    local addressArray = StringUtil.split(addresses, ",")
    if not next(addressArray) then
        return ErrCode.CLUSTER_UN_HIT:detailErrorMsg('路由命中的集群地址信息格式不正确')
    end

    local addressAllow = {}
    for i = 1, #addressArray do
        local address = addressArray[i]
        local index = StringUtil.indexOf(address, ":")
        if index ~= -1 then
            local ip = string.sub(address, 1, index - 1)
            local port = tostring(string.sub(address, index + 1))
            if StringUtil.isEmpty(ip) or not port then
                LogUtil.warn("路由命中的集群信息中存在无效地址信息")
            else
                table.insert(addressAllow, { ip = ip, port = port })
            end
        else
            LogUtil.warn("路由命中的集群信息中存在无效地址信息")
        end
    end

    if not next(addressAllow) then
        return ErrCode.CLUSTER_UN_HIT:detailErrorMsg('路由命中的集群信息中都是无效的地址信息')
    end

    DebugUtil.debugInvoke(function()
        LogUtil.debug("route addressAllow = ", StringUtil.toJSONString(addressAllow))
    end)

    if #addressAllow == 1 then
        return Result:newSuccessResult(addressAllow[1])
    end

    -- 设置随机数种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))

    return Result:newSuccessResult(addressAllow[math.random(1, #addressAllow)])
end

--------------------------------------------------------------------------------------
-- 路由判断入口，返回的是IP+端口
--------------------------------------------------------------------------------------
function _M.route(appName, protocol)
    local routeClusterRlt = routeCluster(appName, protocol)
    if not routeClusterRlt.success then
        return routeClusterRlt
    end

    return getAddressByCluster(routeClusterRlt.data)
end

return _M