-- ============================================================================
-- gore_blast.lua - 血腥爆发特效（客户端）
-- 负责：分三层喷射血雾、高速血珠与爆散血云——高速血珠碰撞后触发回调
--       留下血迹贴图；最后在爆炸点泼洒大量血迹，表现血肉横飞的暴力打击
-- ============================================================================

-- ==== CollideCallback - 血珠碰撞回调：碰撞即销毁并在表面留下血迹贴图 ====
local function CollideCallback(oldparticle, hitpos, hitnormal)
	-- 已销毁的粒子不再重复处理
	if oldparticle:GetDieTime() == 0 then return end
	oldparticle:SetDieTime(0)

	local pos = hitpos + hitnormal

	-- 在碰撞点沿法线方向投射血迹贴图
	util.Decal("Blood", pos, hitpos - hitnormal)
end

-- ==== Init - 特效初始化：分三层喷射血液粒子并泼洒血迹 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = Vector(0, 0, 1)

	local emitter = ParticleEmitter(pos)

	-- 第一层：15 个血雾团向上飞溅，受重力下坠并接受光照，模拟喷出的血柱
	for i=1, 15 do
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(norm * 275 + VectorRand() * 100)
		particle:SetGravity(Vector(0,0,-450))
		particle:SetDieTime(math.Rand(1.5, 2.5))
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(15, 18))
		particle:SetEndSize(math.Rand(20, 24))
		particle:SetRoll(math.random(360))
		particle:SetRollDelta(math.random(-2, 2))
		particle:SetColor(255, 0, 0)
		particle:SetLighting(true)
	end

	-- 第二层：64 个高速血珠向四周飞溅，拖尾长度随时间增长，碰撞后留下血迹
	for i=1, 64 do
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(VectorRand():GetNormalized() * 600)
		particle:SetDieTime(math.Rand(0.18, 0.24))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(12, 18))
		particle:SetEndSize(math.Rand(8, 12))
		particle:SetRoll(math.random(360))
		particle:SetRollDelta(math.random(-8, 8))
		particle:SetStartLength(12)
		particle:SetEndLength(42)
		particle:SetColor(255, 0, 0)
		particle:SetCollide(true)
		particle:SetCollideCallback(CollideCallback)
	end

	-- 第三层：3 个缓慢扩张的血云，模拟爆炸瞬间扬起的浓密血雾
	for i=1, 3 do
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetVelocity(norm * 34)
		particle:SetDieTime(math.Rand(0.3, 0.35))
		particle:SetStartAlpha(math.random(220, 250))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(24, 26))
		particle:SetEndSize(math.Rand(145, 148))
		particle:SetRoll(math.random(360))
		particle:SetRollDelta(math.random(-5, 5))
		particle:SetColor(255, 0, 0)
		particle:SetLighting(true)
	end

	-- 单独一个持续时间较长的大血团，缓慢翻滚扩张作为爆炸余波
	local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
	particle:SetVelocity(norm * 34)
	particle:SetDieTime(math.Rand(1.5, 2))
	particle:SetStartAlpha(220)
	particle:SetEndAlpha(0)
	particle:SetStartSize(math.Rand(28, 32))
	particle:SetEndSize(math.Rand(56, 64))
	particle:SetRoll(math.random(360))
	particle:SetColor(255, 0, 0)
	particle:SetLighting(true)

	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 在爆炸点泼洒 16~22 个血迹喷溅，形成地面上真实的血腥残留
	util.Blood(pos, math.random(16, 22), Vector(0,0,1), 300)
end

-- ==== Think - 特效思考：一次性爆发特效，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由粒子系统自动绘制 ====
function EFFECT:Render()
end
