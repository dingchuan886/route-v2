local _M = {}
_M._VERSION = '1.0'

local LogUtil = require("util.LogUtil")
local StringUtil = require("util.StringUtil")
local DebugUtil = require("util.DebugUtil")

--------------------------------------------------------------------------------------
-- 获取ngx的IP
-- @param ngx ngx对象
-- 注意：使用该方法要能够正常获取到请求方的IP，需要在代理上面配置
-- proxy_set_header X-Real-IP $remote_addr;
-- proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
--------------------------------------------------------------------------------------
function _M.getIp()
    if not ngx then
        return -1
    end

    if ngx.__TEST__ then
        return ngx.__TEST__.ip
    end

    local headers = ngx.req.get_headers()
    return headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
end

--------------------------------------------------------------------------------------
-- 获取ngx的request_uri
--------------------------------------------------------------------------------------
function _M.getRequestUri()
    if not ngx then
        return ''
    end

    if ngx.__TEST__ then
        return ngx.__TEST__.requestUri
    end

    return ngx.var.request_uri
end

--------------------------------------------------------------------------------------
-- 获取ngx的method
--------------------------------------------------------------------------------------
function _M.getRequestMethod()
    if not ngx then
        return ''
    end

    if ngx.__TEST__ then
        return ngx.__TEST__.requestMethod
    end

    return string.upper(ngx.var.request_method)
end

--------------------------------------------------------------------------------------
-- 获取ngx请求中的request参数
-- @param ngx ngx对象
-- @return
--------------------------------------------------------------------------------------
function _M.getRequestParams()
    if not ngx then
        return {}
    end

    if ngx and ngx.__TEST__ then
        return ngx.__TEST__.requestParams or {}
    end

    local requestMethod = ngx.var.request_method
    if "GET" == requestMethod then
        return ngx.req.get_uri_args()
    elseif "POST" == requestMethod then
        ngx.req.read_body()
        return ngx.req.get_post_args()
    end

    return {}
end

function _M.exit(status)
    if not ngx or ngx.__TEST__ then
        LogUtil.debug("response status = " .. status)
        return
    end

    ngx.exit(status)
end

function _M.exitRlt(status, rlt)
    if not ngx or ngx.__TEST__ then
        LogUtil.debug("response status = " .. status .. ", rlt = " .. StringUtil.toJSONString(rlt))
        return
    end

    DebugUtil.debugInvoke(function()
        LogUtil.debug("response status = " .. status .. ", rlt = " .. StringUtil.toJSONString(rlt))
    end)

    ngx.say(StringUtil.toJSONString(rlt))
    ngx.exit(200)
    return
end

return _M