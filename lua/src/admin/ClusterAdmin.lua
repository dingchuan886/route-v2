local _M = {}
_M._VERSION = '1.0'

local RouteService = require("respository.RouteService")
local ErrCode = require("common.ErrCode")
local Config = require("common.Config")

_M.invokers = {
    method = "GET",
    uri = "/clusters",
    invoke = function(method, uri, params, args)
        return RouteService.listClusters()
    end
}, {
    method = 'POST',
    uri = "/clusters",
    invoke = function(method, uri, params, args)
        local sizeRlt = RouteService.clusterSize()
        if not sizeRlt.success then
            return ErrCode.RULE_DATA_ERROR:detailErrorMsg('查询集群总数失败，无法确认是否超过集群总数限制，插入失败')
        elseif sizeRlt.data > Config.CLUSTER_MAX then
            return ErrCode.RULE_DATA_ERROR:detailErrorMsg('添加集群失败，集群总数限制大小为' .. Config.CLUSTER_MAX)
        end
        return RouteService.addCluster(params)
    end
}, {
    method = 'GET',
    uri = "(/clusters/(%d+))",
    invoke = function(method, uri, params, args)
        return RouteService.queryCluster(args[1])
    end
}, {
    method = 'PUT',
    uri = "(/clusters/(%d+))",
    invoke = function(method, uri, params, args)
        if args[1] ~= params.clusterId then
            return ErrCode.BAD_REQUEST:detailErrorMsg('请求参数中的分组信息与uri的分组信息不匹配，异常请求')
        end
        return RouteService.updateCluster(params)
    end
}, {
    method = 'DELETE',
    uri = "(/clusters/(%d+))",
    invoke = function(method, uri, params, args)
        return RouteService.deleteCluster(args[1])
    end
}

return _M