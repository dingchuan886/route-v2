--[[
    参数白名单规则
    成员变量：
        ruleType 规则类型
        ruleStr 规则逻辑串
        cluster 规则命中的集群
        priority 优先级
        effective 规则是否有效
        rule 解析出来的规则
]]--

local _M = {}
_M._VERSION = '1.0'

local mt = { __index = _M }

local StringUtil = require("util.StringUtil")
local Result = require("common.Result")
local ErrCode = require("common.ErrCode")
local BaseRule = require("rule.BaseRule")
local ArrayUtil = require("util.ArrayUtil")
local ClassUtil = require("util.ClassUtil")

function _M.new(self, ruleStr, cluster, priority)
    return BaseRule.build(self, 'WHITE_PARAM', ruleStr, cluster, priority, mt, _M)
end

function _M.clone(self, data)
    return ClassUtil.clone(self, data, _M)
end

function _M.checkMatched(self, context)
    if not self.effective then
        return ErrCode.RULE_UN_EFFECTIVE:detailErrorMsg('路由规则无效，判断路由失败')
    end

    local rule = self.rule
    local requestParams = context.requestParams

    if not next(requestParams) and StringUtil.isEmpty(requestParams[rule.paramKey]) then
        return ErrCode.CONTEXT_UNDEFINE_PARAM:detailErrorMsg('路由上下文中没有获取到参与判定的参数，判断路由失败')
    end

    local paramValue = requestParams[rule.paramKey]
    if not StringUtil.isEmpty(paramValue) and ArrayUtil.contain(rule.whitelist, paramValue) then
        return ErrCode.SUCCESS
    end

    return ErrCode.RULE_UN_HIT
end

--------------------------------------------------------------------------------------
-- 解析规则
-- @param rule
-- ruleStr的格式为：paramKey,white1,white2,white3......
-- @return 若格式正确，解析的result对象中data的格式为{ paramKey = paramKey, whitelist = {...}}
--------------------------------------------------------------------------------------
function _M.parse(ruleStr)
    if StringUtil.isEmpty(ruleStr) then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('规则字符串不能为空')
    end

    local strArray = StringUtil.split(ruleStr, ',')
    if not next(strArray) or #strArray < 2 or StringUtil.isEmpty(strArray[1])then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('参数白名单规则格式不正确')
    end

    -- 第2个开始，后面所有的都是白名单
    local whitelist = {}
    for i = 2, #strArray do
        local white = strArray[i]
        if StringUtil.isEmpty(white) then
            return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('参数末尾匹配规则格式不正确')
        end
        table.insert(whitelist, white)
    end

    return Result:newSuccessResult({ paramKey = strArray[1], whitelist = whitelist })
end

return _M