local _M = {}
_M._VERSION = '1.0'

local RouteService = require("respository.RouteService")
local ErrCode = require("common.ErrCode")
local Config = require("common.Config")

_M.invokers = {
    method = "GET",
    uri = "(/ruleGroups/(%d+)/rules)",
    invoke = function(method, uri, params, args)
        return RouteService.listRules(args[1])
    end
}, {
    method = "POST",
    uri = "/rules",
    invoke = function(method, uri, params, args)
        local sizeRlt = RouteService.ruleSize(params['groupId'])
        if not sizeRlt.success then
            return ErrCode.RULE_DATA_ERROR:detailErrorMsg('查询分组下规则总数失败，无法确认是否超过规则总数限制，插入失败')
        elseif sizeRlt.data > Config.RULE_MAX then
            return ErrCode.RULE_DATA_ERROR:detailErrorMsg('添加规则失败，集群下规则总数限制大小为' .. Config.RULE_MAX)
        end
        return RouteService.addRule(params)
    end
}, {
    method = "GET",
    uri = "(/rules/(%d+))",
    invoke = function(method, uri, params, args)
        return RouteService.queryRule(args[1])
    end
}, {
    method = "PUT",
    uri = "(/rules/(%d+))",
    invoke = function(method, uri, params, args)
        if args[1] ~= params.ruleId then
            return ErrCode.BAD_REQUEST:detailErrorMsg('请求参数中的规则信息与uri的规则信息不匹配，异常请求')
        end
        return RouteService.updateRule(params)
    end
}, {
    method = "DELETE",
    uri = "(/rules/(%d+))",
    invoke = function(method, uri, params, args)
        return RouteService.deleteRule(args[1])
    end
}

return _M