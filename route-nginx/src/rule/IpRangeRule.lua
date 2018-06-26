--[[
    IP区间路由规则
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
local IpUtil = require("util.IpUtil")
local Result = require("common.Result")
local ErrCode = require("common.ErrCode")
local BaseRule = require("rule.BaseRule")
local ClassUtil = require("util.ClassUtil")

function _M.new(self, ruleStr, cluster, priority)
    return BaseRule.build(self, 'IP_RANGE', ruleStr, cluster, priority, mt, _M)
end

function _M.clone(self, data)
    return ClassUtil.clone(self, data, _M)
end

function _M.checkMatched(self, context)
    if not self.effective then
        return ErrCode.RULE_UN_EFFECTIVE:detailErrorMsg('路由规则无效，判断路由失败')
    end

    if not context.longIP or context.longIP < 0 then
        return ErrCode.CONTEXT_UNDEFINE_PARAM:detailErrorMsg('路由上下文中获取IP非法，判断路由失败')
    end

    if self.rule.from <= context.longIP and context.longIP <= self.rule.to then
        return ErrCode.SUCCESS
    end

    return ErrCode.RULE_UN_HIT
end

--------------------------------------------------------------------------------------
-- 解析规则
-- @param rule
-- ruleStr的格式为：ip1~ip2，其中ip可以为数字格式，也可以为地址格式
-- @return 若格式正确，解析的result对象中data的格式为{ from = $from, to = $to}
--------------------------------------------------------------------------------------
function _M.parse(ruleStr)
    if StringUtil.isEmpty(ruleStr) then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('规则字符串不能为空')
    end

    local splitPos = StringUtil.indexOf(ruleStr, "~")
    if splitPos == -1 then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('IP区间规则格式不正确')
    end

    local fromStr = string.sub(ruleStr, 1, splitPos - 1)
    local toStr = string.sub(ruleStr, splitPos + 1)

    local from, to
    if StringUtil.indexOf(fromStr, '.') > 0 then
        from = IpUtil.ip2Long(fromStr)
    else
        from = tonumber(fromStr)
    end
    if StringUtil.indexOf(toStr, '.') > 0 then
        to = IpUtil.ip2Long(toStr)
    else
        to = tonumber(toStr)
    end

    if not from or not to or from == -1 or to == -1 or from > to then
        return ErrCode.RULE_FORMAT_ERROR:detailErrorMsg('IP区间规则格式不正确')
    end

    return Result:newSuccessResult({ from = from, to = to })
end

return _M