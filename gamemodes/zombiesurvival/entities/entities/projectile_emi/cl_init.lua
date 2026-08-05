-- ============================================================================
-- projectile_emi/cl_init.lua - 电磁脉冲投射物（客户端）
-- 负责：EMP 弹的视觉表现——循环能量音效（音调随距离变化）、白色发光
--       球体渲染与向后飘散的等离子粒子尾迹
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流时间戳（限频控制）
ENT.NextEmit = 0

-- 半透明渲染组（发光球体需要混合绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Initialize - 初始化：投射物碰撞组与循环音效 ====
function ENT:Initialize()
	-- 不投射阴影、启用自定义碰撞检查并归类为投射物碰撞组
	self:DrawShadow(false)
	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	-- 创建能量力场循环音效
	self.AmbientSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
end

-- ==== Think - 音效更新：音量与音调随与观察者的距离变化 ====
function ENT:Think()
	-- 距离越近音调越高（230 减去距离×0.12，下限 60）
	self.AmbientSound:PlayEx(0.2, math.max(60, 230 - EyePos():Distance(self:GetPos()) * 0.12))
end

-- ==== OnRemove - 清理：停止循环音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/light_glow02_add")
local matWhite = Material("models/debug/debugwhite")

-- ==== Draw - 渲染：白色发光球体与向后飘散的等离子粒子 ====
function ENT:Draw()
	-- 用白色材质绘制模型并抑制引擎光照，模拟自发光球体
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(0.8, 0.8, 0.8)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride(nil)

	local pos = self:GetPos()

	-- 在球体位置绘制大号发光光晕
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 34, 34)

	render.SetColorModulation(1, 1, 1)

	-- 按 0.075 秒间隔限频生成尾迹粒子
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.075

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	-- 粒子沿速度反方向（向后）随机散开，形成等离子尾迹
	local base_ang = (self:GetVelocity() * -1):Angle()
	local ang = Angle()
	for i=1, 2 do
		ang:Set(base_ang)
		ang:RotateAroundAxis(ang:Right(), math.Rand(-30, 30))
		ang:RotateAroundAxis(ang:Up(), math.Rand(-30, 30))

		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(2)
		particle:SetVelocity(ang:Forward() * math.Rand(12, 14))
		particle:SetColor(210, 210, 210)
		particle:SetAirResistance(24)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(2, 4))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
