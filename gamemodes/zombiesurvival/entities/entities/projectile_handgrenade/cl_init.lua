-- ============================================================================
-- projectile_handgrenade/cl_init.lua - 手雷投射物（客户端）
-- 负责：缩小模型并渲染为黄色发光外观（投掷飞行阶段的提示色）；
--       移除（爆炸）时播放四层爆炸粒子特效：高速火花、火焰余烬、
--       大光球核心与溅射火花
-- ============================================================================

-- 客户端加载入口（INC_CLIENT 系列约定写法）
INC_CLIENT()

-- 发光点材质
local matGlow = Material("sprites/light_glow02_add")

-- ==== Initialize - 客户端初始化 ====
function ENT:Initialize()
	-- 缩小模型至 1/5
	self:SetModelScale(0.2, 0)
	-- 黄色着色，与服务器端爆炸后的红色区分
	self:SetColor(Color(255, 255, 100))
	-- 飞行中的手雷不绘制阴影（避免视觉干扰）
	self:DrawShadow(false)
end

-- ==== OnRemove - 移除时播放爆炸特效 ====
-- 以爆炸点为中心分四层粒子模拟手雷爆炸
function ENT:OnRemove()
	local pos = self:GetPos()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local particle
	-- 第一层：26 个向四周高速飞散的橙色火花
	for i=0, 25 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 275)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(7, 9))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(245, 155, 30)
	end
	-- 第二层：16 个火焰余烬，受重力下坠、可碰撞反弹
	for i=1, 16 do
		particle = emitter:Add("effects/fire_embers"..math.random(1, 3), pos)
		particle:SetVelocity(VectorRand():GetNormal() * 250)
		particle:SetDieTime(math.Rand(1.25, 1.5))
		particle:SetStartAlpha(130)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(15, 19))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetAirResistance(50)
		particle:SetCollide(true)
		particle:SetBounce(0.3)
		particle:SetGravity(Vector(0,0,-400))
	end
	-- 第三层：6 个缓慢膨胀的大光球（爆炸核心闪光）
	for i=0,5 do
		particle = emitter:Add(matGlow, pos)
		particle:SetVelocity(VectorRand() * 5)
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(127, 129))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(245, 175, 60)
	end
	-- 第四层：75 个细长溅射火花（冲击波效果）
	for i=1, 75 do
		particle = emitter:Add("effects/splash2", pos)
		particle:SetDieTime(0.6)
		particle:SetColor(255, 130, 0)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(5)
		particle:SetEndSize(0)
		particle:SetStartLength(1)
		particle:SetEndLength(15)
		particle:SetVelocity(VectorRand():GetNormal() * 200)
	end
	-- 结束发射并触发垃圾回收，避免粒子对象堆积
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
