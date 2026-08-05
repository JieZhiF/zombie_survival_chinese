-- ============================================================================
-- prop_messagebeacon/cl_init.lua - 信息信标（客户端）
-- 负责：缩放信标模型至 1/3 大小，并提供消息 ID 的客户端写入接口
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 缩小模型显示 ====
function ENT:Initialize()
	self:SetModelScale(0.333, 0)
end

-- ==== SetMessageID - 设置展示的消息 ID（DT 同步到客户端） ====
function ENT:SetMessageID(id)
	self:SetDTInt(0, id)
end
