local _M = {}
_M._VERSION = '1.0'

local Config = require("common.Config")

local function log(...)
    if ngx and ngx.log then
        ngx.log(table.concat({ ... }))
        return
    end

    local logs = { ... }
    for i = 1, #logs do
        print(logs[i])
    end
end

function _M.debug(...)
    if Config.LOG_LEVEL <= 3 then
        return
    end

    log(' [ DEBUG ] \t', ...)
end

function _M.info(...)
    if Config.LOG_LEVEL <= 2 then
        return
    end

    log(' [ INFO ] \t', ...)
end

function _M.warn(...)
    if Config.LOG_LEVEL <= 1 then
        return
    end

    log(' [ WARN ] \t', ...)
end

function _M.error(...)
    if Config.LOG_LEVEL <= 0 then
        return
    end

    log(' [ ERROR ] \t', ...)
end

return _M