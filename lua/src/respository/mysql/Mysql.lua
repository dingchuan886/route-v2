local _M = {}
_M._VERSION = '1.0'

local Mysql = require("resty.mysql")
local Result = require("common.Result")
local ErrCode = require("common.ErrCode")
local Config = require("common.Config")
local LogUtil = require("util.LogUtil")

function _M.query(sql, option)
    local db, err = Mysql:new()
    if not db then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库初始化失败')
    end

    -- 1s超时时间
    db:set_timeout(Config.MYSQL_TIMEOUT)

    local ok, errMsg, errCode, sqlstate = db:connect(Config.MYSQL_PROS)
    if not ok then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库连接失败,errCode=' .. tostring(errCode) .. ',errMsg=' .. tostring(errMsg) .. ',sqlstate=' .. tostring(sqlstate))
    end

    local res, errMsg, errCode, sqlstate = db:query(sql)
    if not res then
        return ErrCode.DB_ERROR:detailErrorMsg('数据库操作失败,errCode=' .. tostring(errCode) .. ',errMsg=' .. tostring(errMsg) .. ',sqlstate=' .. tostring(sqlstate))
    end

    local ok, errMsg = db:set_keepalive(10000, 100)
    if not ok then
        LogUtil.warn('设置数据库连接池保持时间失败，错误信息:' .. tostring(errMsg))
    else
        db:close()
    end
end

return _M