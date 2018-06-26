local StringUtil = require("util.StringUtil")
local LogUtil = require("util.LogUtil")

local ruleGroups = StringUtil.toJSONObject( [[
    [{"updateTime":"2018-06-21 11:29:28","createTime":"2018-06-21 11:29:30","rules":[{"updateTime":"2018-06-21 12:50:03","createTime":"2018-06-21 12:50:01","status":"ON","ruleId":4,"cluster":"beta","groupId":4,"ruleStr":"172.27.49.203~172.27.49.209","priority":3,"ruleType":"IP_RANGE"},{"updateTime":"2018-06-21 17:17:42","createTime":"2018-06-21 17:17:40","status":"ON","ruleId":5,"cluster":"beta2","groupId":4,"ruleStr":"mid,123,456,6789","priority":100,"ruleType":"WHITE_PARAM"},{"updateTime":"2018-06-21 17:18:31","createTime":"2018-06-21 17:18:30","status":"ON","ruleId":6,"cluster":"beta1","groupId":4,"ruleStr":"mid~1~2,4","priority":10,"ruleType":"PARAM_TAIL"},{"updateTime":"2018-06-21 17:19:02","createTime":"2018-06-21 17:19:01","status":"ON","ruleId":7,"cluster":"beta2","groupId":4,"ruleStr":"instMid~1~1,2,3,4","priority":20,"ruleType":"PARAM_TAIL"}],"status":"ON","protocol":"HTTP","appName":"test","groupId":4,"groupDesc":null,"priority":1}]
]])

-- 优先级降序排序
table.sort(ruleGroups, function(left, right)
    return left.priority > right.priority
end)
for i = 1, #ruleGroups do
    table.sort(ruleGroups[i].rules, function(left, right)
        return left.priority > right.priority
    end)
end

LogUtil.debug(StringUtil.toJSONString(ruleGroups))


