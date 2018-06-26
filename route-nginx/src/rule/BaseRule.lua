local _M = {}
_M._VERSION = '1.0'

function _M.build(self, ruleType, ruleStr, cluster, priority, mt, func)
    self = {
        ruleType = ruleType,
        ruleStr = ruleStr,
        cluster = cluster,
        priority = priority,
        effective = false,
        rule = {}
    }

    if type(priority) ~= 'number' or priority < 0 then
        return setmetatable(self, mt)
    end

    local result = func.parse(ruleStr)
    if not result.success then
        return setmetatable(self, mt)
    end

    self.effective = true
    self.rule = result.data
    return setmetatable(self, mt)
end

return _M