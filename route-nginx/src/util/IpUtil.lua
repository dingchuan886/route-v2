local _M = {}
_M._VERSION = '1.0'

local StringUtil = require("util.StringUtil")

function _M.ip2Long(ip)
    if ip == nil then
        return -1
    end

    local ipArray = StringUtil.split(ip, ".")
    if ipArray == nil or #ipArray ~= 4 then
        return -1
    end

    local result = 0
    local power = 3
    for _, segment in pairs(ipArray) do
        local segmentInt = tonumber(segment)
        if not segmentInt then
            return -1
        end
        result = result + segmentInt * math.pow(256, power)
        power = power - 1
    end
    return result
end

return _M