local _M = {}
_M._VERSION = '1.0'

local CJson = require("cjson")

function _M.indexOf(str, s)
    if type(str) ~= 'string' or type(s) ~= 'string' then
        return -1
    end
    local pos = string.find(str, s, 1, true)
    if pos then
        return pos
    end
    return -1
end

function _M.split(str, delimiter)
    if type(delimiter) ~= "string" or string.len(delimiter) <= 0 then
        return
    end

    local start = 1
    local result = {}
    while true do
        local pos = string.find(str, delimiter, start, true)
        if not pos then
            break
        end

        table.insert(result, string.sub(str, start, pos - 1))
        start = pos + string.len(delimiter)
    end
    table.insert(result, string.sub(str, start))

    return result
end

function _M.isEmpty(str)
    return str == nil or type(str) ~= "string" or str == ""
end

function _M.trim(str)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function _M.toJSONString(obj)
    if type(obj) ~= 'table' then
        return tostring(obj)
    end
    return CJson.encode(obj)
end

function _M.toJSONObject(str)
    if str == nil then
        return nil
    end
    return CJson.decode(str)
end

return _M