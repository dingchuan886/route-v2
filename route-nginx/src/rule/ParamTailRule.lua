--[[
    参数尾部匹配规则
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
local ArrayUtil = require("util.ArrayUtil")
local BaseRule = require("rule.BaseRule")
local ClassUtil = require("util.ClassUtil")

function _M.new(self, ruleStr, cluster, priority)
    return BaseRule.build(self, 'PARAM_TAIL', ruleStr, cluster, priority, mt, _M)
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
    if not StringUtil.isEmpty(paramValue) and #paramValue >= rule.length then
        local tailValue = string.sub(paramValue, #paramValue - rule.length + 1)
        if ArrayUtil.contain(rule.tails, tailValue) then
            return ErrCode.SUCCESS
        end
    end

    return ErrCode.RULE_UN_HIT
end

--------------------------------------------------------------------------------------
-- 解析规则
-- @param rule
-- ruleStr的格式为：paramKey~length,tail1,tail2,tail3......
-- @return 若格式正确，解析的result对象中data的格式为{ paramKey = paramKey, length = $length, tails = {...}}
--------------------------------------------------------------------------------------
function _M.parse(ruleStr)
    if StringUtil.isEmpty(ruleStr) then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('规则字符串不能为空')
    end

    local strArray = StringUtil.split(ruleStr, ',')
    if not next(strArray) or #strArray < 2 then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('参数末尾匹配规则格式不正确')
    end

    -- 第1个分割出来的一定是paramKey~length
    local splitPos = StringUtil.indexOf(strArray[1], "~")
    if splitPos == -1 then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('参数末尾匹配规则格式不正确')
    end

    local paramKey = string.sub(strArray[1], 1, splitPos - 1)
    local length = tonumber(string.sub(strArray[1], splitPos + 1))
    if StringUtil.isEmpty(paramKey) or not length then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('参数末尾匹配规则格式不正确')
    end

    -- 第2个开始，后面所有的都是tail尾
    local tails = {}
    for i = 2, #strArray do
        local tail = strArray[i]
        if StringUtil.isEmpty(tail) or #tail ~= length then
            return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('参数末尾匹配规则格式不正确')
        end
        table.insert(tails, tail)
    end

    return Result:newSuccessResult({ paramKey = paramKey, length = length, tails = tails })
end

return _M
