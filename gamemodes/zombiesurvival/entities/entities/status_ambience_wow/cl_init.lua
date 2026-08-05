-- ============================================================================
-- status_ambience_wow - WOW 特殊武器的环境氛围状态实体（客户端）
-- 负责：为持有者叠加自发光轮廓、光晕粒子喷发与动态光源，并随移动播放悬停音效，营造 WOW 特效氛围
-- ============================================================================
INC_CLIENT()

-- 渲染组：透明实体
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 光晕精灵的绘制尺寸上限与下限
ENT.GlowMax = 48
ENT.GlowMin = 26

-- 当前光晕尺寸（从最小值开始）；粒子发射限频时间戳
ENT.GlowSize = ENT.GlowMin
ENT.NextEmit = 0

-- ==== Initialize - 关闭阴影并创建悬停引擎环境音 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "^thrusters/hover02.wav")
end

-- ==== Think - 按持有者移动速度调整引擎音调（速度越快音调越高，最高 200 速封顶） ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		self.AmbientSound:PlayEx(0.7, 20 + 15 * math.min(1, owner:GetVelocity():Length() / 200))
	end
end

-- ==== OnRemove - 停止环境音 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

local matGlow = Material("sprites/light_glow02_add")
local matWhite = Material("models/debug/debugwhite")
-- ==== DrawTranslucent - 自发光方式绘制模型并叠加光晕/粒子喷发/动态光源；出生保护期间呈绿色闪烁 ====
function ENT:DrawTranslucent()
	local pl = self:GetOwner()
	if not pl:IsValid() or pl == MySelf and not pl:ShouldDrawLocalPlayer() then return end

	local pos = pl:GetPos()

	local spawnprotection = pl.SpawnProtection

	-- 覆盖为纯白材质并抑制引擎光照实现自发光；出生保护期间降低透明度并调制绿色闪烁
	render.ModelMaterialOverride(matWhite)
	render.SuppressEngineLighting(true)
	if spawnprotection then
		render.SetBlend(0.02 + (CurTime() + pl:EntIndex() * 0.2) % 0.05)
		render.SetColorModulation(0, 0.3, 0)
	end
	self:DrawModel()
	if spawnprotection then
		-- 还原颜色调制与透明度
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
	end
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride(nil)

	-- 光晕颜色：出生保护期间为绿色，否则为白色
	local col = spawnprotection and Color(0, 0.3 * 255, 0) or Color(255, 255, 255)

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 64, 64, col)

	-- 限频 0.075 秒：沿运动反方向随机散射喷发 6 个光点粒子
	if CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 0.075

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(12, 16)

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
			particle:SetColor(col.r,col.g,col.b)
		end

		-- 释放粒子发射器并主动回收一次垃圾内存
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end

	-- 附加动态光源：白色点光持续照亮周围环境
	local dlight = DynamicLight(self:EntIndex())
	if dlight then
		dlight.Pos = pos
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 1
		dlight.Size = 150
		dlight.Decay = 300
		dlight.DieTime = CurTime() + 1
	end
end
