local StringUtil = require("util.StringUtil")
local Config = require("common.Config")
local NgxUtil = require("util.NgxUtil")
local ArrayUtil = require("util.ArrayUtil")
local LogUtil = require("util.LogUtil")

local uri = NgxUtil.getRequestUri()
local method = NgxUtil.getRequestMethod()
local params = NgxUtil.getRequestParams()
LogUtil.info("request uri = ", uri, ", method = ", method, ", params = ", StringUtil.toJSONString(params))

if StringUtil.indexOf(uri, Config.ADMIN_PREFIX) ~= 1 then
    -- 不是以prefix为前缀，那么直接返回404
    NgxUtil.exit(404)
    return
end

-- 测试环境，跨域请求delete/put会options先做试探，因此直接返回200
if method == 'OPTIONS' then
    NgxUtil.exit(200)
    return
end

if method ~= 'GET' and method ~= 'POST' and method ~= 'PUT' and method ~= 'DELETE' and method ~= 'PATCH' then
    -- 不支持的方法
    NgxUtil.exit(405)
    return
end

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
    4. 将规则、集群信息刷入缓存，提高性能
        PATCH /ruleGroups 重新刷新规则缓存
        PATCH /clusters 刷新集群缓存

]]--
local uri = string.sub(uri, #Config.ADMIN_PREFIX + 1)

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


