-- ============================================================================
-- weapon_shattered.lua - 武器碎裂特效（客户端）
-- 负责：播放玻璃破碎音效，并喷射大量淡蓝色玻璃碎片粒子——碎片随机
--       飞散、带三轴自旋、受重力下坠并可碰撞反弹，表现武器被击碎崩解
-- ============================================================================

-- ==== Init - 特效初始化：播放碎裂音效并喷射玻璃碎片粒子 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()
	-- 若提供了目标实体，立即播放玻璃碎裂音效
	if ent:IsValid() then
		ent:EmitSound("physics/glass/glass_sheet_break3.wav")
	end

	-- 粒子发射器：设置近裁剪距离以优化碎片渲染深度
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(8, 16)

	-- 循环复用的方向、尺寸与亮度变量
	local dir, size, brightness
	-- 碎片受重力下坠
	local gravity = Vector(0, 0, -400)

	-- 喷射 30 个玻璃碎片：随机方向飞出、大小与色泽随机，带旋转与反弹
	for i=1, 30 do
		dir = VectorRand()
		dir:Normalize()
		size = math.Rand(1, 5)
		brightness = math.Rand(0.8, 1.0)

		local particle = emitter:Add("particles/balloon_bit", pos + dir)
		particle:SetVelocity(dir * math.Rand(48, 90))
		particle:SetDieTime(math.Rand(3, 5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(100)
		particle:SetStartSize(size)
		particle:SetEndSize(size / 4)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetGravity(gravity)
		-- 淡蓝色玻璃色泽，亮度随机微调
		particle:SetColor(230 * brightness, 240 * brightness, 255 * brightness)
		particle:SetCollide(true)
		-- 三轴随机自旋，模拟碎片翻滚
		particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
		particle:SetBounce(0.9)
	end

	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Think - 特效思考：一次性爆发特效，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由粒子系统自动绘制 ====
function EFFECT:Render()
end
