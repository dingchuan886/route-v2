--[[
    全局配置
]]--

local _M = {
    _VERSION = '1.0',

    -- 日志级别
    -- DEBUG=4,INFO=3,WARN=2,ERR=1,关闭日志=0
    LOG_LEVEL = 4,

    -- 数据库连接字符串
    MYSQL_PROS = {
        host = "192.168.195.128",
        port = 3306,
        database = "route",
        user = "root",
        password = "root",
        charset = "utf8",
        max_packet_size = 1024 * 1024
    },

    -- 数据库超时时间
    MYSQL_TIMEOUT = 1000,

}

return _M