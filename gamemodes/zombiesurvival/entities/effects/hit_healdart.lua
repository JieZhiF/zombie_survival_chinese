-- ============================================================================
-- hit_healdart.lua - 治疗飞镖命中特效（客户端）
-- 负责：治疗飞镖命中目标时播放蒸汽释放与命中音效，并沿表面法线
--       方向喷射一团绿色治疗烟雾粒子，表示治疗能量生效
-- ============================================================================

-- ==== Init - 特效初始化：播放命中音效并喷射绿色烟雾 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local ent = data:GetEntity()

	-- 命中实体有效时由实体播放蒸汽音效，命中玩家额外播放命中音效
	if ent and ent:IsValid() then
		ent:EmitSound("ambient/machines/steam_release_2.wav", 70, 255)

		if ent:IsPlayer() then
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(2)..".wav", 70, 140)
		end
	else
		-- 未命中实体则在命中点直接播放音效
		sound.Play("ambient/machines/steam_release_2.wav", pos, 70, 255)
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 以法线为轴随机旋转方向，喷射 32 个绿色烟雾粒子
	for i=1, 32 do
		local ang = norm:Angle()
		ang:RotateAroundAxis(ang:Up(), math.Rand(0, 360))
		ang:RotateAroundAxis(ang:Right(), math.Rand(-80, 80))

		local particle = emitter:Add("particle/smokestack", pos)
		particle:SetVelocity(ang:Forward() * math.Rand(4, 32))
		particle:SetDieTime(math.Rand(0.75, 1.25))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(6)
		particle:SetColor(10, 255, 10)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-4, 4))
		particle:SetGravity(Vector(0, 0, -10))
		particle:SetAirResistance(100)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- 纯粒子特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

