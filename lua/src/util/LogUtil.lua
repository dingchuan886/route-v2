local _M = {}
_M._VERSION = '1.0'

local Config = require("common.Config")

local ERR = ngx and ngx.ERR or '[ERROR]'
local INFO = ngx and ngx.INFO or '[INFO]'
local WARN = ngx and ngx.WARN or '[WARN]'
local DEBUG = ngx and ngx.DEBUG or '[DEBUG]'

local function log(level, ...)
    if ngx and ngx.log then
        ngx.log(level, table.concat({ ... }, ' '))
        return
    end

    local logs = {level,  ... }
    for i = 1, #logs do
        print(logs[i])
    end
end

function _M.debug(...)
    if Config.LOG_LEVEL <= 3 then
        return
    end

    log(DEBUG, ...)
end

function _M.info(...)
    if Config.LOG_LEVEL <= 2 then
        return
    end

    log(INFO, ...)
end

function _M.warn(...)
    if Config.LOG_LEVEL <= 1 then
        return
    end

    log(WARN, ...)
end

function _M.error(...)
    if Config.LOG_LEVEL <= 0 then
        return
    end

    log(ERR, ...)
end

return _M