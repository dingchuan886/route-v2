--[[
    常量
]]--

local _M = {
    _VERSION = '1.0',

    RULE_MAPPING = {

        IP_RANGE = require("rule.IpRangeRule"),

        PARAM_TAIL = require("rule.ParamTailRule"),

        WHITE_PARAM = require("rule.WhiteParamRule")
    }

}

return _M