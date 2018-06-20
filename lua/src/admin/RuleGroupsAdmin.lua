local _M = {}
_M._VERSION = '1.0'

local RouteService = require("respository.RouteService")
local ErrCode = require("common.ErrCode")
local Config = require("common.Config")

_M.invokers = {
    method = "GET",
    uri = "/ruleGroups",
    invoke = function(method, uri, params, args)
        return RouteService.listRuleGroups()
    end
}, {
    method = 'POST',
    uri = "/ruleGroups",
    invoke = function(method, uri, params, args)
        local sizeRlt = RouteService.ruleGroupSize()
        if not sizeRlt.success then
            return ErrCode.RULE_DATA_ERROR:detailErrorMsg('查询规则分组总数失败，无法确认是否超过规则分组总数限制，插入失败')
        elseif sizeRlt.data > Config.RULE_GROUP_MAX then
            return ErrCode.RULE_DATA_ERROR:detailErrorMsg('添加规则分组失败，规则分组总数限制大小为' .. Config.RULE_GROUP_MAX)
        end
        return RouteService.addRuleGroup(params)
    end
}, {
    method = 'GET',
    uri = "(/ruleGroups/(%d+))",
    invoke = function(method, uri, params, args)
        return RouteService.queryRuleGroup(args[1])
    end
}, {
    method = 'PUT',
    uri = "(/ruleGroups/(%d+))",
    invoke = function(method, uri, params, args)
        if args[1] ~= params.groupId then
            return ErrCode.BAD_REQUEST:detailErrorMsg('请求参数中的分组信息与uri的分组信息不匹配，异常请求')
        end
        return RouteService.updateRuleGroup(params)
    end
}, {
    method = 'DELETE',
    uri = "(/ruleGroups/(%d+))",
    invoke = function(method, uri, params, args)
        return RouteService.deleteRuleGroup(args[1])
    end
}

return _M