local _M = {}
_M._VERSION = '1.0'

local RouteService = require("respository.RouteService")
local ErrCode = require("common.ErrCode")
local Config = require("common.Config")
local Constant = require("common.Constant")
local StringUtil = require("util.StringUtil")

local function checkRuleStr(params)
    if StringUtil.isEmpty(params.ruleType) then
        return ErrCode.BAD_REQUEST:detailErrorMsg('规则类型ruleType非法')
    end

    local ruleType = Constant.RULE_MAPPING[params.ruleType]
    if ruleType == nil then
        return ErrCode.BAD_REQUEST:detailErrorMsg('规则类型ruleType非法')
    end

    local parseRlt = ruleType.parse(params.ruleStr)
    if not parseRlt.success then
        return ErrCode.BAD_REQUEST:detailErrorMsg('规则逻辑字符串格式不正确')
    end

    return ErrCode.SUCCESS
end

_M.invokers = {
    {
        method = "GET",
        uri = "(/ruleGroups/(%d+)/rules)",
        invoke = function(method, uri, params, args)
            local checkRlt = RouteService.queryRuleGroup(args[1])
            if not checkRlt.success then
                return checkRlt
            end

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

            -- 校验规则字符串是否有效
            local checkRlt = checkRuleStr(params)
            if not checkRlt.success then
                return checkRlt
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

            -- 校验规则字符串是否有效
            local checkRlt = checkRuleStr(params)
            if not checkRlt.success then
                return checkRlt
            end

            local checkRlt = RouteService.queryRule(args[1])
            if not checkRlt.success then
                return checkRlt
            end

            return RouteService.updateRule(params)
        end
    }, {
        method = "DELETE",
        uri = "(/rules/(%d+))",
        invoke = function(method, uri, params, args)
            local checkRlt = RouteService.queryRule(args[1])
            if not checkRlt.success then
                return checkRlt
            end

            return RouteService.deleteRule(args[1])
        end
    }
}

return _M