local Result = require("common.Result")
local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")

LogUtil.debug(StringUtil.toJSONString(Result:newSuccessResult({ a = "1", b = "2" })))
LogUtil.debug(StringUtil.toJSONString(Result:newErrorResult("ERR_CODE", "ERR_MSG")))

LogUtil.debug(StringUtil.toJSONString(Result:newErrorResult()))
LogUtil.debug(StringUtil.toJSONString(Result:newSuccessResult()))

local r1 = Result:newErrorResult()
local r2 = Result:newErrorResult()
local r3 = Result:newSuccessResult()
local r4 = Result:newSuccessResult()
LogUtil.debug(r1, r2)
LogUtil.debug(r3, r4)