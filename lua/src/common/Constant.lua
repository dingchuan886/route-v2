--[[
    常量
]]--

local ArrayUtil = require("util.ArrayUtil")

local _M = {
    _VERSION = '1.0',

    RULE_MAPPING = {

        IP_RANGE = require("rule.IpRangeRule"),

        PARAM_TAIL = require("rule.ParamTailRule"),

        WHITE_PARAM = require("rule.WhiteParamRule")
    },

    RULE_GROUP_COLUMN_MAPPING = {
        GROUP_ID = 'groupId',
        APP_NAME = 'appName',
        PRIORITY = 'priority',
        STATUS = 'status',
        PROTOCOL = 'protocol',
        GROUP_DESC = 'groupDesc',
        CREATE_TIME = 'createTime',
        UPDATE_TIME = 'updateTime'
    },

    RULE_COLUMN_MAPPING = {
        RULE_ID = 'ruleId',
        GROUP_ID = 'groupId',
        RULE_TYPE = 'ruleType',
        RULE_STR = 'ruleStr',
        CLUSTER = 'cluster',
        PRIORITY = 'priority',
        STATUS = 'status',
        CREATE_TIME = 'createTime',
        UPDATE_TIME = 'updateTime'
    },

    CLUSTER_COLUMN_MAPPING = {
        CLUSTER_ID = 'clusterId',
        CLUSTER = 'cluster',
        ADDRESSES = 'addresses',
        STATUS = 'status',
        CLUSTER_DESC = 'clusterDesc',
        CREATE_TIME = 'createTime',
        UPDATE_TIME = 'updateTime'
    },

    AVAILABLE_RULE_GROUPS_KEY = 'AVAILABLE_RULE_GROUPS',

    AVAILABLE_CLUSTER_KEY = 'AVAILABLE_CLUSTER_KEY',
}

_M.RULE_GROUP_COLUMN_REVERSE_MAPPING = ArrayUtil.reverse(_M.RULE_GROUP_COLUMN_MAPPING)
_M.RULE_COLUMN_REVERSE_MAPPING = ArrayUtil.reverse(_M.RULE_COLUMN_MAPPING)
_M.CLUSTER_COLUMN_REVERSE_MAPPING = ArrayUtil.reverse(_M.CLUSTER_COLUMN_MAPPING)

return _M