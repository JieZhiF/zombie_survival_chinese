-- ============================================================================
-- status_frostshadeambience/cl_init.lua - 寒霜之影环境状态（客户端）
-- 负责：播放风声音效，并围绕携带者渲染白色光晕与飘散烟雾粒子
-- ============================================================================

INC_CLIENT()

-- 该实体在渲染时归入半透明渲染组（配合 DrawTranslucent 使用）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 烟雾粒子的生成节流时间戳
ENT.NextEmit = 0

-- ==== Initialize - 初始化 ====
-- 关闭阴影、设置渲染包围盒，创建风声循环音效并绑定到玩家
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 90))

	-- 循环播放风声，营造寒冷氛围
	self.AmbientSound = CreateSound(self, "ambient/levels/canals/windmill_wind_loop1.wav")
	self.AmbientSound:PlayEx(0.6, 100)

	-- 记录到玩家字段，供其他系统查询该状态是否存在
	self:GetOwner().status_frostshadeambience = self
end

-- ==== OnRemove - 移除时 ====
-- 停止风声，防止音效残留
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- 白色光晕材质与颜色
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(255, 255, 255, 150)

-- ==== DrawTranslucent - 半透明绘制 ====
-- 在携带者身上绘制白色光晕，并周期性喷出随玩家移动的烟雾粒子
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	-- 出生保护期间不显示效果
	if owner.SpawnProtection then return end
	-- 仅当玩家可见（非第一人称本地视角且未被遮挡）时绘制
	if owner:IsValid() and (owner ~= MySelf or owner:ShouldDrawLocalPlayer()) then
		-- 以玩家包围盒中心为锚点绘制闪烁的白色光晕
		local pos = owner:LocalToWorld(owner:OBBCenter())
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, math.Rand(64, 72), math.Rand(64, 72), colGlow)

		-- 每 0.25 秒生成一个上升烟雾粒子
		if self.NextEmit <= CurTime() then
			self.NextEmit = CurTime() + 0.25

			local emitter = ParticleEmitter(pos)
			emitter:SetNearClip(32, 48)

			local particle = emitter:Add("particle/smokestack", pos)
			particle:SetVelocity(owner:GetVelocity() * 0.8)
			particle:SetDieTime(math.Rand(1, 1.35))
			particle:SetStartAlpha(130)
			particle:SetEndAlpha(0)
			particle:SetStartSize(10)
			particle:SetEndSize(math.Rand(25,50))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-5, 5))
			particle:SetGravity(Vector(0, 0, 90))
			particle:SetCollide(true)
			particle:SetBounce(0.45)
			particle:SetAirResistance(12)
			particle:SetColor(255, 255, 255)

			-- 结束发射器并手动触发垃圾回收释放资源
			emitter:Finish() emitter = nil collectgarbage("step", 64)
		end
	end
end
