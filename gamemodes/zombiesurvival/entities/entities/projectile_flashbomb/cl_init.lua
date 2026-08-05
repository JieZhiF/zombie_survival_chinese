-- ============================================================================
-- cl_init.lua - 闪光弹投射物（客户端）：倒计时音效与爆炸前发光提示
-- 负责：临近爆炸时播放越来越急促的提示音，爆炸前瞬间点亮发光点
-- ============================================================================
INC_CLIENT()

-- 下次播放提示音的时间（用于控制音效节奏）
ENT.NextTickSound = 0
-- 上次播放提示音的时间（用于判断是否处于"即将爆炸"状态）
ENT.LastTickSound = 0

-- ==== Initialize - 初始化：记录死亡（爆炸）时间 ====
function ENT:Initialize()
	self.DieTime = CurTime() + self.LifeTime
end

-- ==== Think - 每帧检测：按剩余寿命的百分比加速播放提示音 ====
function ENT:Think()
	local curtime = CurTime()

	if curtime >= self.NextTickSound then
		local delta = self.DieTime - curtime

		-- 剩余时间越少，播放间隔越短、音调越高（间隔不小于 0.15 秒）
		self.NextTickSound = curtime + math.max(0.15, delta * 0.25)
		self.LastTickSound = curtime
		self:EmitSound("npc/roller/mine/rmine_blip1.wav", 75, math.Clamp((1 - delta / self.LifeTime) * 220, 150, 220))
	end
end

-- 发光粒子材质（爆炸前亮点）
local matGlow = Material("sprites/glow04_noz")
-- ==== DrawTranslucent - 半透明绘制：仅在播放提示音后 0.05 秒内点亮青色光点 ====
function ENT:DrawTranslucent()
	self:DrawModel()

	if math.abs(self.LastTickSound - CurTime()) >= 0.05 then return end

	render.SetMaterial(matGlow)
	render.DrawSprite(self:LocalToWorld(Vector(0, 0, 4)), 12, 12, COLOR_CYAN)
end
