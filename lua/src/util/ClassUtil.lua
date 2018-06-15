local _M = {}
_M._VERSION = '1.0'

--------------------------------------------------------------------------------------
-- 克隆对象
-- 解决问题：当某lua对象序列化反序列化后，对象会失去调用方法的能力，只有数据部分，调用此方法，允许反序列化的对象允许调用方法
--------------------------------------------------------------------------------------
function _M.clone(self, data, func)
    if type(self) ~= 'table'
            or type(func) ~= 'table' then
        return data
    end

    self = {}
    for k, v in pairs(data) do
        self[k] = v
    end
    return setmetatable(self, { __index = func })
end

--------------------------------------------------------------------------------------
-- 映射对象数据
-- 1）option为boolean类型时候，option=true 表示key大写，false表示小写
-- 2）option为映射表
--------------------------------------------------------------------------------------
function _M.mapping(origin, option)
    if type(origin) ~= 'table' then
        return origin
    end

    local result = {}

    -- option=nil时候不做处理，直接拷贝
    if option == nil then
        for k, v in pairs(origin) do
            if type(k) ~= 'table' and type(v) ~= 'table' then
                result[k] = v
            end
        end
    end

    -- boolean类型时候大小写处理
    if type(option) == 'boolean' then
        for k, v in pairs(origin) do
            if type(k) ~= 'table' and type(v) ~= 'table' then
                result[option and string.upper(k) or string.lower(k)] = v
            end
        end
    end

    -- table类型时候，做映射处理
    if type(option) == 'table' then
        -- 做映射时候，忽略大小写
        local mappings = _M.mapping(option, true)
        for k, v in pairs(origin) do
            if type(k) ~= 'table' and type(v) ~= 'table' then
                local mapping = mappings[string.upper(k)]
                if mapping ~= nil and type(mapping) ~= 'table' then
                    result[mapping] = v
                end
            end
        end
    end

    return result
end

return _M