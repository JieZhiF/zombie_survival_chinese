-- ============================================================================
-- env_shadecontrol/cl_init.lua - 暗影控制实体（客户端）
-- 负责：暗影形态的视觉表现——关闭阴影、略微放大模型并播放循环音效，
--       以折射材质覆盖模型绘制出暗影能量质感；移除时清理拥有者引用
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：模型缩放、循环音效并绑定拥有者引用 ====
function ENT:Initialize()
	-- 不投射阴影并轻微放大模型，突出暗影形态
	self:DrawShadow(false)
	self:SetModelScale(1.03, 0)

	-- 创建并播放暗影能量循环音效
	self.AmbientSound = CreateSound(self, ")weapons/physcannon/superphys_hold_loop.wav")
	self.AmbientSound:PlayEx(0.5, 60)

	-- 在拥有者身上记录控制实体引用（供技能/武器逻辑查询）
	self:GetOwner().ShadeControl = self
end

-- ==== OnRemove - 清理：停止音效并清除拥有者引用 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()

	local owner = self:GetOwner()
	-- 仅当引用仍指向自身时清空，避免误删其他控制实体
	if owner.ShadeControl == self then
		owner.ShadeControl = nil
	end
end

local matRefract = Material("models/spawn_effect")

-- ==== Draw - 折射渲染：用折射材质覆盖模型绘制出暗影能量效果 ====
function ENT:Draw()
	-- 需要像素着色器 2.0 支持（依赖折射纹理更新）
	if not render.SupportsPixelShaders_2_0() then return end

	render.UpdateRefractTexture()

	-- 设置折射强度
	matRefract:SetFloat("$refractamount", 0.02)

	-- 覆盖为折射材质后绘制模型，再还原默认材质
	render.ModelMaterialOverride(matRefract)
	self:DrawModel()
	render.ModelMaterialOverride(0)
end
