local _M = {}
_M._VERSION = '1.0'

local mt = { __index = _M }

local ErrCode = require("common.ErrCode")
local Constant = require("common.Constant")
local Result = require("common.Result")
local ClassUtil = require("util.ClassUtil")

function _M.new(self, groupId, protocol, priority)
    return setmetatable({ groupId = groupId, protocol = protocol, priority = priority, rules = {} }, mt)
end

function _M.clone(self, data)
    self = ClassUtil.clone({}, data, _M)
    local rules = {}
    for i = 1, #self.rules do
        local rule = self.rules[i]
        -- 克隆内部的规则对象
        rule = ClassUtil.clone({}, self.rules[i], Constant.RULE_MAPPING[rule.ruleType])
        table.insert(rules, rule)
    end
    self.rules = rules
    return self
end

function _M.create(self, ruleGroupDO)
    local result = _M.new(self, ruleGroupDO.groupId, ruleGroupDO.protocol, ruleGroupDO.priority)
    for i = 1, #ruleGroupDO.rules do
        _M.add(result, ruleGroupDO.rules[i])
    end
    return _M
end

function _M.getCluster(self, context)
    if not next(self.rules) then
        return ErrCode.RULE_GROUP_UN_EFFECTIVE:detailErrorMsg('路由分组下面没有任何有效的路由规则')
    end

    for i = 1, #self.rules do
        local rule = self.rules[i]
        local ret = rule:checkMatched(context)
        if ret.success then
            return Result:newSuccessResult({ cluster = rule.cluster, rule = rule })
        end
    end

    return ErrCode.RULE_UN_HIT
end

function _M.add(self, ruleDO)
    if not next(ruleDO) then
        return ErrCode.RULE_UN_EFFECTIVE:detailErrorMsg('路由规则不能为空')
    end

    if ruleDO.groupId ~= self.groupId then
        return ErrCode.RULE_UN_EFFECTIVE:detailErrorMsg('路由规则不属于该分组')
    end

    local RULE_TYPE = Constant.RULE_MAPPING[ruleDO.ruleType]
    if not RULE_TYPE then
        return ErrCode.RULE_UN_EFFECTIVE:detailErrorMsg('路由规则类型不存在，无效规则')
    end

    local rule = RULE_TYPE:new(ruleDO.ruleStr, ruleDO.cluster, ruleDO.priority)
    if not rule.effective then
        return ErrCode.RULE_UN_EFFECTIVE
    end

    table.insert(self.rules, rule)
    return ErrCode.SUCCESS
end

return _M