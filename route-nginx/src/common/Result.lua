--[[
    包装结果对象
    成员变量：
        success: 成功状态
        errCode: 错误码
        errMsg: 错误信息
        data: 额外的填充结果
]]--

local _M = {}
_M._VERSION = '1.0'

local mt = { __index = _M }

local DEFAULT_SUCCESS = { success = true, errCode = 'SUCCESS', errMsg = '', data = {} }
local DEFAULT_ERROR = { success = false, errCode = 'ERROR', errMsg = '', data = {} }

function _M.newSuccessResult(self, data)
    if data == nil then
        return DEFAULT_SUCCESS
    end
    return setmetatable({ success = true, errCode = 'SUCCESS', errMsg = '', data = data or {} }, mt)
end

function _M.newErrorResult(self, errCode, errMsg)
    if errCode == nil and errMsg == nil then
        return DEFAULT_ERROR
    end
    return setmetatable({ success = false, errCode = errCode or 'ERROR', errMsg = errMsg or '', data = {} }, mt)
end

--------------------------------------------------------------------------------------
-- 允许在错误码的基础上面更改错误信息（填充更完善的错误信息）
--------------------------------------------------------------------------------------
function _M.detailErrorMsg(self, errMsg)
    return _M.newErrorResult(self, self.errCode, errMsg)
end

return _M