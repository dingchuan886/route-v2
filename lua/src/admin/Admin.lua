local StringUtil = require("util.StringUtil")
local Config = require("common.Config")
local NgxUtil = require("util.NgxUtil")
local ArrayUtil = require("util.ArrayUtil")
local LogUtil = require("util.LogUtil")
local DebugUtil = require("util.DebugUtil")

local uri = NgxUtil.getRequestUri()
if StringUtil.indexOf(uri, Config.ADMIN_PREFIX) ~= 1 then
    -- 不是以prefix为前缀，那么直接返回404
    NgxUtil.exit(404)
    return
end

local uri = string.sub(uri, #Config.ADMIN_PREFIX + 1)
DebugUtil.debugInvoke(function()
    LogUtil.debug("request uri = " .. uri)
end)

local method = NgxUtil.getRequestMethod()
DebugUtil.debugInvoke(function()
    LogUtil.debug("request uri = " .. method)
end)

if method ~= 'GET' and method ~= 'POST' and method ~= 'PUT' and method ~= 'DELETE' then
    -- 不支持的方法
    NgxUtil.exit(405)
    return
end

local params = NgxUtil.getRequestParams()
DebugUtil.debugInvoke(function()
    LogUtil.debug("request params = " .. StringUtil.toJSONString(params))
end)

--[[
    uri格式大致符合restful规范，包括下面几类:
    1. 规则分组管理
        GET /ruleGroups 列出所有规则分组
        POST /ruleGroups 新建一个规则分组
        GET /ruleGroups/ID 获取某个指定的规则分组
        PUT /ruleGroups/ID 更新某个指定的规则分组
        DELETE /ruleGroups/ID 删除某个指定的规则分组
    2. 规则管理
        GET /ruleGroups/ID/rules 列出某规则分组下面所有规则
        POST /rules 新建一个规则
        GET /rules/ID 获取某个指定的规则
        PUT /rules/ID 更新某个指定的规则
        DELETE /rules/ID 删除某个指定的规则
    3. 集群管理
        GET /clusters 列出所有集群
        POST /clusters 新建一个集群
        GET /clusters/ID 获取某个指定的集群
        PUT /clusters/ID 更新某个指定的集群
        DELETE /clusters/ID 删除某个指定的集群
]]--
-- 合并三个数组
local invokers = ArrayUtil.mergeAll({
    require("admin.RuleGroupsAdmin").invokers,
    require("admin.RuleAdmin").invokers,
    require("admin.ClusterAdmin").invokers
})
for i = 1, #invokers do
    local invoker = invokers[i]
    if invoker.method == method then
        -- uri里面最多支持2个参数
        for url, arg1, arg2 in string.gmatch(uri, invoker.uri) do
            if url == uri then
                -- 证明完全匹配上，那么执行响应invoke方法，返回的是json报文
                local rlt = invoker.invoke(method, url, params, { arg1, arg2 })
                NgxUtil.exitRlt(200, rlt)
                return
            end
        end
    end
end

-- 如果执行到此处，证明没有找到合适的invoke，那么请求404
NgxUtil.exit(404)
return


