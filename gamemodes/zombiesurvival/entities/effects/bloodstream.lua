-- ============================================================================
-- bloodstream.lua - 血涌喷射特效（客户端）
-- 负责：沿打击方向喷射大量血滴，血滴受重力下坠并碰撞——碰撞时播放
--       血肉撞击音效、留下血迹贴图，并按概率二次喷溅小血滴，表现
--       伤口持续喷涌鲜血的视觉效果
-- ============================================================================

-- 预缓存血肉撞击音效，避免首次播放时卡顿
util.PrecacheSound("physics/flesh/flesh_bloody_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard2.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard3.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard4.wav")

-- ==== CollideCallbackSmall - 小血滴碰撞回调：碰撞即消失并留下血肉贴图 ====
local function CollideCallbackSmall(particle, hitpos, hitnormal)
	-- 已销毁的粒子不再重复处理
	if particle:GetDieTime() == 0 then return end
	particle:SetDieTime(0)

	-- 1/3 概率播放硬质撞击音并在碰撞面投射血肉贴图
	if math.random(3) == 3 then
		sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.Rand(95, 105))
		util.Decal("Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
	end
end

-- ==== CollideCallback - 主血滴碰撞回调：留下血迹并按概率二次喷溅小血滴 ====
local function CollideCallback(oldparticle, hitpos, hitnormal)
	-- 已销毁的粒子不再重复处理
	if oldparticle:GetDieTime() == 0 then return end
	oldparticle:SetDieTime(0)

	local pos = hitpos + hitnormal

	-- 1/3 概率播放随机血肉撞击音效
	if math.random(3) == 3 then
		sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", hitpos, 50, math.Rand(95, 105))
	end
	-- 碰撞点沿法线方向留下血迹贴图
	util.Decal("Blood", pos, hitpos - hitnormal)

	-- 随机 -4~4：仅正值才触发二次喷溅，负值/0 直接结束
	local num = math.random(-4, 4)
	if num < 1 then return end

	-- 二次喷溅的基础方向：沿碰撞法线高速冲出
	local nhitnormal = hitnormal * 90

	-- 在碰撞点二次喷溅 num 颗小血滴：沿法线带随机扩散喷出，受重力下落并碰撞
	local emitter = ParticleEmitter(pos)
	for i=1, num do
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		particle:SetLighting(true)
		particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(75, 150) + nhitnormal)
		particle:SetDieTime(3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(1.5, 2.5))
		particle:SetEndSize(1.5)
		particle:SetRoll(math.Rand(-25, 25))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetAirResistance(5)
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetCollide(true)
		particle:SetColor(255, 0, 0)
		particle:SetCollideCallback(CollideCallbackSmall)
	end
	-- 释放粒子发射器并回收内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- ==== Init - 特效初始化：沿打击方向喷射血滴 ====
function EFFECT:Init(data)
	-- 出生点抬高 10 单位，避免血滴生成时嵌在地面内部
	local pos = data:GetOrigin() + Vector(0, 0, 10)

	local dir = data:GetNormal()
	local force = data:GetScale()

	local emitter = ParticleEmitter(pos)
	-- 血滴数量由打击强度（Magnitude）决定：每颗沿主方向混合随机扩散后喷出
	for i=1, data:GetMagnitude() do
		-- 主方向占 3/4、随机扩散占 1/4，保证血滴大体朝打击方向飞散
		local heading = (VectorRand():GetNormalized() * 3 + dir) / 4
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos + heading)
		particle:SetVelocity(force * math.Rand(0.8, 1) * heading)
		particle:SetDieTime(math.Rand(3, 6))
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(3, 5))
		particle:SetEndSize(3)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))
		particle:SetAirResistance(5)
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetCollide(true)
		particle:SetLighting(true)
		particle:SetColor(255, 0, 0)
		particle:SetCollideCallback(CollideCallback)
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
