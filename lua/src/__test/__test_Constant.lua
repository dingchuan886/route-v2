local Constant = require("common.Constant")
local LogUtil = require("util.LogUtil")
local StringUtil = require("util.StringUtil")

LogUtil.debug(StringUtil.toJSONString(Constant.RULE_COLUMN_REVERSE_MAPPING))
LogUtil.debug(StringUtil.toJSONString(Constant.RULE_GROUP_COLUMN_REVERSE_MAPPING))

local mapping = require("common.Constant").RULE_GROUP_COLUMN_REVERSE_MAPPING
LogUtil.debug(StringUtil.toJSONString(mapping == Constant.RULE_GROUP_COLUMN_REVERSE_MAPPING))