-- ============================================================================
-- explosion_wispdeath.lua - 灵体死亡爆炸特效（客户端）
-- 负责：灵体死亡瞬间播放能量音效、触发屏幕震动与白光闪烁（含视野
--       朝向/距离/阵营修正），并在死亡点持续喷射白色火花，绘制
--       随时间扩张的折射环与白色光晕，直到寿命结束
-- ============================================================================

-- 特效基准寿命（秒）
EFFECT.LifeTime = 7

-- 下一次喷射火花的时刻（控制火花发射频率）
EFFECT.NextEmit = 0

-- ==== Init - 特效初始化：记录位置、播放音效并触发视觉冲击 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal() * -1

	-- 爆炸位置沿法线略作偏移，避免贴进表面
	pos = pos + normal

	self.Pos = pos
	self.Normal = normal
	self.DieTime = CurTime() + self.LifeTime

	-- 播放低沉的能量爆鸣音
	sound.Play("weapons/physcannon/energy_sing_explosion2.wav", pos, 75, math.Rand(25, 35))

	-- 触发小范围屏幕震动
	util.ScreenShake(pos, 5, 5, 1, 300)

	-- 创建随特效存活的白色动态光源，照亮爆炸点周围
	local dlight = DynamicLight(0)
	if dlight then
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 8
		dlight.Size = 500
		dlight.Decay = 2000
		dlight.DieTime = CurTime() + self.LifeTime
	end

	-- 根据玩家与爆炸点的距离/视野夹角计算白光强度，距离近且面向爆炸时更强
	if MySelf:IsValid() then
		local eyepos = MySelf:EyePos()
		local dist = eyepos:Distance(pos)
		if dist < 400 and WorldVisible(eyepos, pos) then
			local power = 1 - dist / 800

			local dir = pos - eyepos
			dir:Normalize()
			power = power - (1 - math.max(0, EyeVector():Dot(dir))) / 3

			-- 僵尸阵营的白光强度削弱为三分之一
			if MySelf:Team() ~= TEAM_HUMAN then
				power = power / 3
			end

			-- 视线不完全可见时再打折扣
			if not TrueVisible(eyepos, pos) then
				power = power * 0.66
			end

			-- 人类玩家保留最低白光强度，避免完全无反馈
			if MySelf:Team() ~= TEAM_UNDEAD then
				power = math.max(power, 0.4)
			end

			-- 强度足够时触发眩晕 DSP 音效滤镜
			if power > 0.5 then
				MySelf:SetDSP(36)
			end

			-- 白光强度受玩家自身视觉修改器加成
			local visionaltermul = MySelf.VisionAlterDurationMul or 1
			util.WhiteOut(power * 8 * visionaltermul, 2 * visionaltermul)
		end
	end
end

-- ==== Think - 存活至死亡时间 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- 折射环、光晕材质与光晕颜色
local matRefract = Material("refract_ring")
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(255, 255, 255)
-- ==== Render - 持续喷射火花并绘制扩张的折射环与光晕 ====
function EFFECT:Render()
	local pos = self.Pos
	-- 剩余寿命比例，控制尺寸与透明度
	local delta = (self.DieTime - CurTime()) / self.LifeTime
	-- 基准尺寸随寿命快速扩张
	local basesize = 64
	basesize = basesize + basesize ^ (1.5 - delta)

	-- 每 0.05 秒发射一颗白色火花，形成持续喷射的效果
	if CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 0.05

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)

		local heading = VectorRand()
		heading:Normalize()

		local particle = emitter:Add("effects/spark", pos + heading * 8)
		particle:SetVelocity(420 * heading)
		particle:SetDieTime(math.Rand(0.5, 0.85))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(3, 4))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(250)

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end

	-- 折射量随寿命波动衰减，绘制双面折射环表现能量扭曲
	matRefract:SetFloat("$refractamount", (0.75 + math.abs(math.sin(CurTime() * 5)) * math.pi * 0.25) * delta)
	render.SetMaterial(matRefract)
	render.UpdateRefractTexture()
	render.DrawSprite(pos, basesize, basesize)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, color_white, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, color_white, 0)

	-- 外层再绘制一层更大的白色光晕
	basesize = basesize * 1.25

	colGlow.a = delta * 255
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, basesize, basesize, colGlow)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
	render.DrawQuadEasy(pos, self.Normal, basesize, basesize, colGlow, 0)
end
