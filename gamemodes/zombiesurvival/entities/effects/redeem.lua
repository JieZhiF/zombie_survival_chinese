-- ============================================================================
-- redeem.lua - 救赎/复活光效（客户端）
-- 负责：播放白色闪光音效，并在特效点周围的小球体内喷射 150~200 颗
--       上飘光点粒子——光点缓慢上升、旋转并收缩消失，表现被救赎者
--       周身绽放的圣洁光芒
-- ============================================================================

-- ==== Init - 特效初始化：播放白光音效并喷发上飘光点 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()

	-- 播放白色闪光音效，强化救赎瞬间的视听冲击
	sound.Play("ambient/energy/whiteflash.wav", pos)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 在特效点周围随机喷发 150~200 颗光点，数量随机避免每次效果千篇一律
	for x=1, math.random(150, 200) do
		-- 生成点取球体内随机方向（半径 24~64），并整体下移一段距离作为上飘起点
		local vecRan = VectorRand():GetNormalized()
		vecRan = vecRan * math.Rand(24, 64)
		vecRan.z = math.Rand(-32, -1)

		local particle = emitter:Add("sprites/light_glow02_add", pos + vecRan)
		-- 光点向上缓慢飘升，寿命结束前尺寸缩至 0 形成收缩消散
		particle:SetVelocity(Vector(0, 0, math.Rand(16, 64)))
		particle:SetDieTime(math.Rand(1.2, 2))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(7, 8))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-32, 32))
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

-- 预缓存白闪音效，避免首次播放时卡顿
util.PrecacheSound("ambient/energy/whiteflash.wav")
