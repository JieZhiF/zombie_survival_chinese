-- ============================================================================
-- projectile_arrow_sli/cl_init.lua - 滑膛箭投射物（客户端）
-- 负责：箭矢的自定义着色渲染（强化箭变色）、按飞行方向对齐模型与十字
--       形拖尾光效，以及移除时的粒子迸散效果
-- ============================================================================
INC_CLIENT()

-- 白色材质用于模型染色（配合 render.SetColorModulation 着色）
local matWhite = Material("models/debug/debugwhite")
-- 发光精灵材质用于飞行拖尾光效
local matGlow = Material("sprites/light_glow02_add")

-- ==== Draw - 自定义渲染：染色模型、按飞行方向对齐并绘制拖尾光 ====
function ENT:Draw()
	-- alt/alt2 分别标记箭矢的两种强化阶段（普通强化/蓄力强化）
	local alt = self:GetDTBool(0)
	local alt2 = self:GetDTBool(1)

	-- 将模型覆盖为白色材质并按强化状态着色：普通箭偏绿、强化箭偏蓝紫
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(alt2 and 0.2 or 0.8, 0.7, (alt or alt2) and 1 or 0.3)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	-- 飞行速度足够快时：模型朝向改为速度方向，并绘制十字形光晕拖尾
	if self:GetVelocity():LengthSqr() > 100 then
		self:SetAngles(self:GetVelocity():Angle())

		render.SetMaterial(matGlow)

		-- 拖尾颜色随强化状态变化（强化后偏蓝）
		local glowcol = Color(alt2 and 50 or 140, 120, (alt or alt2) and 100 or 50, 75)

		-- 两个互相垂直的细长光晕构成十字形尾迹
		render.DrawSprite(self:GetPos(), 15, 3, glowcol)
		render.DrawSprite(self:GetPos(), 3, 15, glowcol)
	end
end

-- ==== Initialize - 客户端初始化（为空，仅为保持实体接口完整） ====
function ENT:Initialize()
end

-- ==== Think - 客户端逐帧逻辑（为空，仅为保持实体接口完整） ====
function ENT:Think()
end

-- ==== OnRemove - 移除时在箭矢位置迸散一圈发光粒子 ====
function ENT:OnRemove()
	local pos = self:GetPos()
	local alt = self:GetDTBool(0)
	local alt2 = self:GetDTBool(1)

	-- 创建粒子发射器并向四周随机迸散发光粒子
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=0,30 do
		local particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 45)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(160)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 6))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		-- 粒子颜色随强化状态变化
		particle:SetColor(alt and 200 or 150, 165, (alt or alt2) and 205 or 90)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
