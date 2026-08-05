-- ============================================================================
-- prop_blocker/init.lua - 阻挡用静态道具（服务器）
-- 负责：生成固定不动的物理阻挡体，用于封堵路径/站位点
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 创建固定物理阻挡体 ====
function ENT:Initialize()
	-- 使用桥柱模型作为阻挡体外观
	self:SetModel("models/props_wasteland/medbridge_post01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		-- 禁用运动，使阻挡体完全固定（不可被推动）
		phys:EnableMotion(false)
		phys:Wake()
	end
end
