-- ============================================================================
-- cl_init.lua - 幽光球投射物（客户端）：自发光渲染与粒子尾迹
-- 负责：绘制高亮发光的球体模型、能量光环，并随时间生成拖尾粒子
-- ============================================================================
INC_CLIENT()

-- 下次生成拖尾粒子的时间（限制粒子频率）
ENT.NextEmit = 0

-- 半透明渲染组（叠加混合发光效果）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Initialize - 初始化：创建能量场循环音效 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
end

-- ==== Think - 每帧更新能量场音效：音量固定、音高随距离升高 ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.7, math.max(120, 230 - EyePos():Distance(self:GetPos()) * 0.12))
end

-- ==== OnRemove - 移除时停止循环音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- 发光精灵材质（叠加混合）与纯白模型材质
local matGlow = Material("sprites/light_glow02_add")
local matWhite = Material("models/debug/debugwhite")
-- ==== Draw - 绘制发光球体与能量光环 ====
function ENT:Draw()
	-- 用纯白材质覆盖模型并关闭引擎光照，使球体呈现自发光效果
	render.ModelMaterialOverride(matWhite)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride(nil)

	local pos = self:GetPos()

	-- 在球心绘制 64x64 的叠加发光精灵作为光环
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 64, 64)

	-- 每 0.075 秒生成一批粒子（朝向飞行反方向散开形成尾迹）
	if CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.075

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(12, 16)

	-- 以飞行反方向为基准轴，在 ±30 度锥形内生成 6 枚粒子
	local base_ang = (self:GetVelocity() * -1):Angle()
	local ang = Angle()
	for i=1, 6 do
		ang:Set(base_ang)
		ang:RotateAroundAxis(ang:Right(), math.Rand(-30, 30))
		ang:RotateAroundAxis(ang:Up(), math.Rand(-30, 30))

		local particle = emitter:Add("sprites/glow04_noz", pos)
		particle:SetDieTime(2)
		particle:SetVelocity(ang:Forward() * math.Rand(32, 64))
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
