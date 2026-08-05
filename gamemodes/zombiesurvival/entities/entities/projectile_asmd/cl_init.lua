-- ============================================================================
-- projectile_asmd/cl_init.lua - ASMD 能量弹投射物（客户端）
-- 负责：飞行中持续生成紫色能量尾迹光点并叠加光晕；
--       移除时播放弹跳音并爆发三层消散粒子
-- ============================================================================
INC_CLIENT()

-- 光晕与光点材质
local matGlow = Material("effects/splashwake1")
local matGlow2 = Material("sprites/glow04_noz")
local vector_origin = vector_origin

-- ==== Draw - 绘制：尾迹光点粒子，飞行中叠加能量光晕 ====
function ENT:Draw()
	local pos = self:GetPos()

	-- 每帧发射 3 个短寿命紫色光点作为尾迹
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	for i=0, 2 do
		particle = emitter:Add(matGlow2, pos)
		particle:SetVelocity(VectorRand() * 25)
		particle:SetDieTime(0.1)
		particle:SetStartAlpha(125)
		particle:SetEndAlpha(0)
		particle:SetStartSize(20)
		particle:SetEndSize(0)
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetColor(155, 100, 255)
	end
	-- 释放发射器并主动触发一步 GC
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 飞行中（有速度时）绘制多层光晕表现能量球
	if self:GetVelocity() ~= vector_origin then
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, 55, 55, Color(100, 100, 255, 100))
		render.SetMaterial(matGlow2)
		render.DrawSprite(pos, 65, 65, Color(155, 100, 255, 100))
		render.DrawSprite(pos, 45, 45, Color(255, 255, 255, 255))
	end
end

-- ==== OnRemove - 移除时：播放能量弹跳音并爆发三层消散粒子 ====
function ENT:OnRemove()
	local pos = self:GetPos()

	sound.Play("weapons/physcannon/energy_bounce1.wav", pos, 75, math.random(75, 80))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 第一层：20 个紫色能量碎片向外飞散
	for i=0, 19 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 25)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(125)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(3, 4))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(150, 125, 255)
	end
	-- 第二层：6 个大型光晕膨胀消散
	for i=0,5 do
		particle = emitter:Add(matGlow2, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(35, 40))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(225, 205, 255)
	end
	-- 第三层：45 个细长电光条向外飞射
	for i=1, 45 do
		particle = emitter:Add("effects/splash2", pos)
		particle:SetDieTime(0.6)
		particle:SetColor(100, 65, 255)
		particle:SetStartAlpha(125)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(0)
		particle:SetStartLength(1)
		particle:SetEndLength(5)
		particle:SetVelocity(VectorRand():GetNormal() * 50)
	end
	-- 释放发射器并主动触发一步 GC
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
