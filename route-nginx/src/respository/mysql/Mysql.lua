local _M = {}
_M._VERSION = '1.0'

local Mysql = require("resty.mysql")
local ErrCode = require("common.ErrCode")
local Config = require("common.Config")
local LogUtil = require("util.LogUtil")
local ClassUtil = require("util.ClassUtil")
local Result = require("common.Result")
local DebugUtil = require("util.DebugUtil")
local StringUtil = require("util.StringUtil")

local function closeMysql(db)
    if not db then
        db:close()
    end
end

local function prepare(sql)
    local db, err = Mysql:new()
    if not db then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库初始化失败')
    end

    -- 1s超时时间
    db:set_timeout(Config.MYSQL_TIMEOUT)

    local ok, errMsg, errCode, sqlstate = db:connect(Config.MYSQL_PROS)
    if not ok then
        closeMysql(db)
        return ErrCode.DB_ERROR:detailErrorMsg('数据库连接失败,errCode=' .. tostring(errCode) .. ',errMsg=' .. tostring(errMsg) .. ',sqlstate=' .. tostring(sqlstate))
    end

    local res, errMsg, errCode, sqlstate = db:query(sql)
    if not res then
        closeMysql(db)
        return ErrCode.DB_ERROR:detailErrorMsg('数据库操作失败,errCode=' .. tostring(errCode) .. ',errMsg=' .. tostring(errMsg) .. ',sqlstate=' .. tostring(sqlstate))
    end

    local ok, errMsg = db:set_keepalive(10000, 100)
    if not ok then
        closeMysql(db)
        LogUtil.warn('设置数据库连接池保持时间失败，错误信息:' .. tostring(errMsg))
    end

    return Result:newSuccessResult(res)
end

function _M.execute(sql)
    local prepare = prepare(sql)
    DebugUtil.debugInvoke(function()
        LogUtil.debug("mysql-prepare:", StringUtil.toJSONString(prepare))
    end)

    if not prepare.success then
        return prepare
    end

    return ErrCode.SUCCESS
end

function _M.query(sql, option)
    local prepare = prepare(sql)
    DebugUtil.debugInvoke(function()
        LogUtil.debug("mysql-prepare:", StringUtil.toJSONString(prepare))
    end)

    if not prepare.success then
        return prepare
    end

    -- 结果需要做映射
    return Result:newSuccessResult(ClassUtil.mappingArray(prepare.data, option))
end

return _M