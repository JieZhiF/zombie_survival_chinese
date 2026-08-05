-- ============================================================================
-- cl_init.lua - 冷光精灵氛围实体（客户端）：冰蓝光效与风声音效
-- 负责：以半透明冰蓝光晕渲染拥有者，喷发漂浮光点粒子，提供动态光与风声
-- ============================================================================
INC_CLIENT()

-- 半透明渲染组
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 光晕尺寸上限/下限
ENT.GlowMax = 48
ENT.GlowMin = 26

-- 当前光晕尺寸（初始为最小值）
ENT.GlowSize = ENT.GlowMin
-- 粒子发射节流时间
ENT.NextEmit = 0

-- ==== Initialize - 初始化：创建风声音效 ====
function ENT:Initialize()
	self:DrawShadow(false)

	-- 创建持续风声音效（音量随移动速度变化）
	self.AmbientSound = CreateSound(self, "ambient/levels/canals/windmill_wind_loop1.wav")
end

-- ==== Think - 每帧按移动速度调整风声音量 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		-- 移动越快风声越大（速度 0~200 单位/秒之间线性变化）
		self.AmbientSound:PlayEx(0.8, 50 + 70 * math.min(1, owner:GetVelocity():Length() / 200))
	end
end

-- ==== OnRemove - 移除时停止音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- 发光光晕与白色覆盖材质
local matGlow = Material("sprites/light_glow02_add")
local matWhite = Material("models/shiny")
-- ==== DrawTranslucent - 半透明绘制：光晕染色、漂浮光点与动态光 ====
function ENT:DrawTranslucent()
	local pl = self:GetOwner()
	-- 拥有者无效，或为本地玩家且默认不绘制本地玩家时跳过
	if not pl:IsValid() or pl == MySelf and not pl:ShouldDrawLocalPlayer() then return end

	local pos = pl:GetPos()

	-- 拥有者处于出生保护时显示为暗绿色闪烁
	local spawnprotection = pl.SpawnProtection

	-- 白色覆盖材质 + 染色后绘制模型
	render.ModelMaterialOverride(matWhite)
	render.SuppressEngineLighting(true)
	if spawnprotection then
		-- 出生保护：暗绿色 + 闪烁透明度
		render.SetBlend(0.02 + (CurTime() + pl:EntIndex() * 0.2) % 0.05)
		render.SetColorModulation(0, 0.3, 0)
	else
		-- 正常：冰蓝色高亮
		render.SetBlend(0.9)
		render.SetColorModulation(0, 0.6, 1)
	end
	self:DrawModel()
	-- 恢复默认渲染状态
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride(nil)

	-- 绘制大型光晕贴花（颜色随出生保护切换）
	local col = spawnprotection and Color(0, 0.3 * 255, 0) or Color(0, 180, 255)

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, 64, 64, col)

	-- 按节流频率喷发漂浮光点粒子
	if CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 0.075

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(12, 16)

		-- 以拥有者运动反方向为基准，向锥形随机方向发射 6 颗光点
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

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end

	-- 提供白色动态点光源照亮周围
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
