-- ============================================================================
-- cl_init.lua - 霜影控制实体（客户端）：半透明遮罩模型与持续音效
-- 负责：以半透明方式渲染母体模型，播放能量场音效，并登记到持有者
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组（始终半透明绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Initialize - 初始化：设置半透明材质、播放音效并登记到持有者 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModelScale(self:GetModelScale(), 0)
	self:SetMaterial("models/spawn_effect2")

	-- 循环播放能量场音效（音量 0.5，音调 60）
	self.AmbientSound = CreateSound(self, ")weapons/physcannon/superphys_hold_loop.wav")
	self.AmbientSound:PlayEx(0.5, 60)

	-- 把自身登记到持有者，供其他逻辑查询"当前霜影控制"
	self:GetOwner().ShadeControl = self
end

-- ==== OnRemove - 移除时：停止音效并清理持有者引用 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()

	local owner = self:GetOwner()
	if owner.ShadeControl == self then
		owner.ShadeControl = nil
	end
end

-- ==== DrawTranslucent - 半透明绘制：以 50% 透明度绘制模型 ====
function ENT:DrawTranslucent()
	render.SetBlend(0.5)
	self:DrawModel()
	render.SetBlend(1)
end
