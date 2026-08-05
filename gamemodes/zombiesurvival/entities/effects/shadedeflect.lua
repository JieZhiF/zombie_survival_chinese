-- ============================================================================
-- shadedeflect.lua - 暗影弹开特效（客户端）
-- 负责：暗影护盾弹开投射物时生成一个透明的橙色折射球体模型，
--       跟随目标实体移动，并在命中点喷射蓝色能量粒子、播放跳弹音效
-- ============================================================================

-- 预缓存折射球体模型，避免首次生成时卡顿
util.PrecacheModel("models/props/cs_italy/orange.mdl")

-- 特效总时长（秒）：决定折射强度衰减速度
EFFECT.LifeTime = 2

-- ==== Init - 特效初始化：设置球体模型并喷射能量粒子 ====
function EFFECT:Init(data)
	-- 弹开发生的位置与球体朝向
	local pos = data:GetOrigin()
	local angles = data:GetAngles()

	-- 目标实体及其身上的偏移点（弹开动画的发生部位）
	self.Offset = data:GetStart()
	self.Ent = data:GetEntity()

	-- 播放跳弹音效（随机 5 种之一，高音调模拟弹开）
	sound.Play("weapons/fx/rics/ric"..math.random(5)..".wav", pos, 68, math.Rand(150, 170))

	-- 特效实体复用为折射球体：固定不动、放大 2 倍并按传入角度摆放
	self.Entity:SetModel("models/props/cs_italy/orange.mdl")
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetModelScale(2, 0)
	self.Entity:SetAngles(angles)

	-- 目标有效时：在偏移点喷射 2 个蓝色能量粒子，向上弹跳消散
	if self.Ent:IsValid() then
		local offset = self.Ent:LocalToWorld(self.Offset)

		local emitter = ParticleEmitter(offset)
		emitter:SetNearClip(24, 32)

		for i=1, 2 do
			local particle = emitter:Add("sprites/glow04_noz", offset)
			particle:SetDieTime(1)
			particle:SetColor(90,130,255)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(15)
			particle:SetVelocity((angles:Up() + VectorRand()):GetNormal() * 300)
			particle:SetGravity(VectorRand() * 20 + Vector(0, 0, -400))
			particle:SetCollide(true)
			particle:SetBounce(0.75)
			particle:SetAirResistance(12)
		end
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end

	self.DieTime = CurTime() + self.LifeTime
end

-- ==== Think - 特效存活判定：未到消亡时刻则继续渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 折射材质：让球体呈现玻璃般的扭曲效果
local matRefract = Material("models/spawn_effect")
-- ==== Render - 逐帧渲染：跟随目标并绘制折射球体 ====
function EFFECT:Render()
	local ent = self.Ent
	-- 目标存活时球体持续跟随其偏移点位置
	if ent:IsValid() then
		self:SetPos(ent:LocalToWorld(self.Offset))
	end

	-- 折射强度随剩余寿命的平方衰减，2 秒内逐渐透明
	render.UpdateRefractTexture()
	matRefract:SetFloat("$refractamount", math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1) ^ 2 * 0.05)

	-- 用折射材质覆盖绘制球体模型，之后恢复原材质
	render.ModelMaterialOverride(matRefract)

	self.Entity:DrawModel()

	render.ModelMaterialOverride(0)
end
