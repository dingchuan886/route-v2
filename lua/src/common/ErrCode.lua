--[[
    错误码
]]--

local Result = require("common.Result")

local _M = {
    _VERSION = '1.0',

    SUCCESS = Result:newSuccessResult(),

    RULE_FORMAT_ERROR = Result:newErrorResult('RULE_FORMAT_ERROR', '规则格式错误'),

    RULE_UN_EFFECTIVE = Result:newErrorResult('RULE_UN_EFFECTIVE', '路由规则无效'),

    CONTEXT_UNDEFINE_PARAM = Result:newErrorResult('CONTEXT_UNDEFINE_PARAM', '路由上下文获取参数无效'),

    RULE_GROUP_UN_EFFECTIVE = Result:newErrorResult('RULE_GROUP_UN_EFFECTIVE', '路由分组无效'),

    RULE_UN_HIT = Result:newErrorResult('RULE_UN_HIT', '没有命中路由规则'),

    CLUSTER_UN_HIT = Result:newErrorResult('CLUSTER_UN_HIT', '集群相关信息没有找到'),

    DB_ERROR = Result:newErrorResult('DB_ERROR', '数据库操作失败'),

    RULE_DATA_ERROR = Result:newErrorResult('RULE_DATA_ERROR', '路由规则数据有问题'),

    BAD_REQUEST = Result:newErrorResult('BAD_REQUEST', '请求参数错误')
}

return _M