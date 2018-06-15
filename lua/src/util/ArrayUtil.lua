local _M = {}
_M._VERSION = '1.0'

--------------------------------------------------------------------------------------
-- 判断数组是否包含某元素
--------------------------------------------------------------------------------------
function _M.contain(array, element)
    if type(array) ~= 'table' then
        return false
    end
    for i = 1, #array do
        if element == array[i] then
            return true
        end
    end
    return false
end

return _M