-- ============================================================================
-- hit_glass.lua - 玻璃破碎命中特效（客户端）
-- 负责：命中玻璃时播放玻璃碎裂与点燃音效，喷射旋转的玻璃碎片、
--       升腾的烟雾、环形扩散的烟尘和火焰云，最后在表面留下焦痕
-- ============================================================================

-- ==== Init - 特效初始化：分四组喷射破碎粒子并留焦痕 ====
function EFFECT:Init(data)
	-- 命中位置与破碎主方向（法线取反）
	local pos = data:GetOrigin()
	local norm = data:GetNormal() * -1

	local particle, dir, ang, heading, RandDarkness, Size

	-- 播放玻璃破碎音效（随机 3 种之一）与点燃音效
	sound.Play("physics/glass/glass_sheet_break"..math.random(3)..".wav", pos, 70, math.Rand(95, 105))
	sound.Play("ambient/fire/ignite.wav", pos, 80, math.Rand(80, 90))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 12~18 块玻璃碎片：沿破碎方向锥形飞出，带随机旋转并受重力下落、弹跳
	for i=1, math.random(12, 18) do
		Size = math.Rand(2, 4)
		RandDarkness = math.Rand(0.8, 1.0)
		dir = (norm * 2 + VectorRand()) / 3
		dir:Normalize()

		particle = emitter:Add("particles/balloon_bit", pos)
		particle:SetVelocity(dir * math.Rand(125, 200))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(3, 5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(100)
		particle:SetStartSize(Size)
		particle:SetEndSize(Size * 0.25)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetGravity(Vector(0, 0, -400))
		particle:SetColor(230 * RandDarkness, 230 * RandDarkness, 230 * RandDarkness)
		particle:SetCollide(true)
		particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
		particle:SetBounce(0.45)
	end

	-- 一个缓慢膨胀的大烟团，模拟破碎处升起的浓烟
	particle = emitter:Add("particle/smokestack", pos)
	particle:SetDieTime(5)
	particle:SetStartAlpha(225)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(150)
	particle:SetColor(30, 30, 30)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-2, 2))

	-- 13~16 个深色烟尘粒子沿破碎方向高速喷出并缓慢消散
	for i=1, math.random(13, 16) do
		particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand() * 90 + norm * 200)
		particle:SetDieTime(math.Rand(3.5, 5.25))
		particle:SetStartAlpha(225)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(70, 92))
		particle:SetColor(40, 40, 40)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetAirResistance(32)
	end

	-- 32 个烟尘粒子以破碎点为中心环形铺开，形成向外的烟圈
	ang = norm:Angle():Right():Angle()
	local step = 360 / 32
	for i=1, 360, step do
		ang:RotateAroundAxis(norm, step)
		heading = ang:Forward() * 128

		particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(heading)
		particle:SetGravity(heading * -0.25)
		particle:SetDieTime(math.Rand(2.4, 4.78))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(92)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetAirResistance(16)
		particle:SetColor(45, 45, 45)
	end

	-- 12 个火焰云粒子沿破碎方向喷射，模拟玻璃破碎引发的火光
	for i=1, 12 do
		particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetVelocity(norm * math.Rand(150, 190) + VectorRand():GetNormal() * math.Rand(180, 200))
		particle:SetDieTime(math.Rand(1.35, 1.6))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(0)
		particle:SetStartSize(48)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetAirResistance(100)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 在破碎表面留下烧焦痕迹贴图
	util.Decal("Scorch", pos + norm, pos - norm)
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
