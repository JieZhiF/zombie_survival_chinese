-- ============================================================================
-- gib_player.lua - 玩家爆体碎块特效（客户端）
-- 负责：玩家被击杀爆碎瞬间播放爆体音效，并从每个骨骼位置喷射血柱与
--       飞溅血滴，血滴落地后留下血迹贴图并播放血肉撞击音效
-- ============================================================================

-- 预缓存爆体音效，避免首次播放时出现卡顿
util.PrecacheSound("physics/flesh/flesh_bloody_break.wav")

-- ==== CollideCallback - 血滴碰撞回调：终止粒子、留血迹并播放音效 ====
local function CollideCallback(oldparticle, hitpos, hitnormal)
	-- 已终止的粒子直接忽略，避免重复处理
	if oldparticle:GetDieTime() == 0 then return end
	oldparticle:SetDieTime(0)

	-- 碰撞点沿法线方向偏移，避免血迹贴图嵌入表面内部
	local pos = hitpos + hitnormal

	-- 1/3 概率播放血肉撞击音效（随机选取 4 种音效之一）
	if math.random(3) == 3 then
		sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", hitpos, 50, math.Rand(95, 105))
	end
	-- 在碰撞面留下血迹贴图
	util.Decal("Blood", pos, hitpos - hitnormal)
end

-- 全局重力常量，所有血滴共用
local vecGravity = Vector(0, 0, -500)
-- ==== Init - 特效初始化：从每个骨骼位置喷射血柱与血滴 ====
function EFFECT:Init(data)
	-- 被爆碎的玩家实体，无效则直接跳过
	local ent = data:GetEntity()
	if not ent:IsValid() then return end

	-- 播放爆体音效
	ent:EmitSound("physics/flesh/flesh_bloody_break.wav")

	-- 取实体位置、移动方向与向上向量，用于合成血滴喷射方向
	local basepos = ent:GetPos()
	local vel = ent:GetVelocity()
	local dir = vel:GetNormalized()
	local up = ent:GetUp()
	-- 喷射速度随实体移动速度翻倍，并限制在 512 ~ 2048 之间
	local speed = math.Clamp(vel:Length() * 2, 512, 2048)

	local emitter = ParticleEmitter(ent:LocalToWorld(ent:OBBCenter()))
	emitter:SetNearClip(24, 32)

	-- 遍历除根骨外的所有骨骼，从每块骨骼的位置喷射血液
	for boneid = 1, ent:GetBoneCount() - 1 do
		local pos = ent:GetBonePositionMatrixed(boneid)
		if pos and pos ~= basepos then
			-- 每根骨骼喷 1~3 条血柱：沿移动方向与上方合成的锥形高速喷出，落地触发回调
			for i=1, math.random(1, 3) do
				local heading = (VectorRand():GetNormalized() + up + dir * 2) / 4
				local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos + heading)
				particle:SetVelocity(speed * math.Rand(0.5, 1) * heading)
				particle:SetDieTime(math.Rand(3, 6))
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(200)
				particle:SetStartSize(math.Rand(3, 4))
				particle:SetEndSize(2)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-20, 20))
				particle:SetAirResistance(8)
				particle:SetGravity(vecGravity)
				particle:SetCollide(true)
				particle:SetLighting(true)
				particle:SetColor(255, 0, 0)
				particle:SetCollideCallback(CollideCallback)
			end

			-- 每根骨骼再喷 4 个短命血滴：沿移动方向快速飞溅后直接消散
			for i=1, 4 do
				local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
				particle:SetVelocity(math.Rand(0.5, 4) * (VectorRand():GetNormalized() + dir))
				particle:SetDieTime(math.Rand(0.75, 2))
				particle:SetStartAlpha(230)
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(4, 5))
				particle:SetEndSize(3)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-1, 1))
				particle:SetLighting(true)
				particle:SetColor(255, 0, 0)
			end
		end
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
