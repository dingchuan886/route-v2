local _M = {}
_M._VERSION = '1.0'

--------------------------------------------------------------------------------------
-- 获取ngx的IP
-- @param ngx ngx对象
-- 注意：使用该方法要能够正常获取到请求方的IP，需要在代理上面配置
-- proxy_set_header X-Real-IP $remote_addr;
-- proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
--------------------------------------------------------------------------------------
function _M.getNgxIp()
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
function _M.getNgxRequestUri()
    if not ngx then
        return ''
    end

    if ngx.__TEST__ then
        return ngx.__TEST__.requestUri
    end

    return ngx.var.request_uri
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

return _M