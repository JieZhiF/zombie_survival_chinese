-- ============================================================================
-- projectile_biorifle/cl_init.lua - 生物步枪投射物（客户端）
-- 负责：弹体的小型化缩放与发光外观渲染（随类型变色），
--       移除时在命中位置播放烟雾与光点粒子特效
-- ============================================================================
INC_CLIENT()

-- 下次粒子发射时间（保留字段）
ENT.NextEmit = 0
-- 随机种子，用于外观动画相位
ENT.Seed = 0

-- ==== Initialize - 初始化：缩小弹体模型、关闭阴影、生成随机种子 ====
function ENT:Initialize()
	self:SetModelScale(0.2, 0)
	self:DrawShadow(false)

	self.Seed = math.Rand(0, 10)
end

-- 发光与烟雾材质
local matGlow = Material("effects/splash2")
local matSplay = Material("particles/smokey")
-- ==== Draw - 渲染：按弹体类型（DT 5）变色，叠加半透明模型与双层光晕 ====
function ENT:Draw()
	-- 0=毒液(绿) 1=火焰(橙) 其他=冰冻(蓝)
	local type = self:GetDTInt(5)
	local c = type == 0 and Color(120, 205, 60, 70) or type == 1 and Color(205, 120, 60, 70) or Color(70, 195, 235, 70)
	self:SetColor(c)
	-- 半透明绘制模型本体
	render.SetBlend(0.7)
	self:DrawModel()
	render.SetBlend(1)

	-- 以正弦波动制造光晕脉动效果
	local pos = self:GetPos()
	local add = math.sin((CurTime() + self.Seed) * 3) * 2

	render.SetMaterial(matSplay)
	render.DrawSprite(pos, 12 - add, 18 + add, c)
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 18 + add, 18 - add, c)
end

-- ==== OnRemove - 移除特效：在当前位置播发烟尘与光点粒子 ====
function ENT:OnRemove()
	local pos = self:GetPos()
	-- 按弹体类型选取粒子颜色
	local type = self:GetDTInt(5)
	local c = type == 0 and Color(120, 205, 60) or type == 1 and Color(205, 120, 60) or Color(70, 195, 235)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 向外飞散的烟雾粒子
	for i=1, 12 do
		particle = emitter:Add("particles/smokey", pos)
		particle:SetDieTime(0.4)
		particle:SetColor(c.r, c.g, c.b)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(3)
		particle:SetEndSize(0)
		particle:SetCollide(true)
		particle:SetGravity(Vector(0, 0, -300))
		particle:SetVelocity(VectorRand():GetNormal() * 120)
	end
	-- 短暂闪烁的光点粒子
	for i=0,5 do
		particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(25)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(27, 29))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(c.r, c.g, c.b)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
