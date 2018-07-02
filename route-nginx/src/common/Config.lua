--[[
    全局配置
]]--

local _M = {
    _VERSION = '1.0',

    -- 全局开关
    ROUTE_SWITCH = true,

    -- DEBUG模式
    DEBUG = true,

    -- 日志级别
    -- DEBUG=4,INFO=3,WARN=2,ERR=1,关闭日志=0
    LOG_LEVEL = 4,

    -- 分组大小限制
    RULE_GROUP_MAX = 30,

    -- 每个组下面大小限制
    RULE_MAX = 10,

    -- 集群大小限制
    CLUSTER_MAX = 20,

    -- 数据库连接字符串
    MYSQL_PROS = {
        host = "172.30.251.33",
        port = 3306,
        database = "route_v2",
        user = "root",
        password = "CDE#4rfv",
        charset = "utf8",
        max_packet_size = 1024 * 1024
    },

    -- 数据库超时时间
    MYSQL_TIMEOUT = 100000,

    -- ADMIN服务前缀网关
    ADMIN_PREFIX = '/route/admin',

    -- 共享内存名称
    ROUTE_SHARED_DICT_KEY = 'routeSharedCache',
}

return _M