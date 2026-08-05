-- ============================================================================
-- cl_init.lua - 化学僵尸氛围状态（客户端）
-- 负责：化学僵尸身上持续播放呼吸音效，并绘制绿色发光体与冒烟粒子特效
-- ============================================================================
INC_CLIENT()

-- 渲染分组：作为半透明实体渲染
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 粒子发射节流计时（下次允许发射粒子的时间）
ENT.NextEmit = 0

-- ==== Initialize - 初始化客户端实体 ====
-- 关闭阴影、设置渲染包围盒，并创建循环呼吸音效开始播放
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 90))

	-- 创建并播放化学僵尸的呼吸循环音效
	self.AmbientSound = CreateSound(self, "npc/zombie_poison/pz_breathe_loop1.wav")
	self.AmbientSound:PlayEx(0.67, 100)
end

-- ==== OnRemove - 实体移除时停止音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 每帧维持呼吸音效播放 ====
-- 音量保持 0.67，音调随 RealTime 轻微浮动模拟呼吸起伏
function ENT:Think()
	self.AmbientSound:PlayEx(0.67, 100 + RealTime() % 1)
end

-- 发光粒子材质与颜色（绿色毒雾光晕）
local matGlow = Material("sprites/glow04_noz")
local colGlow = Color(0, 255, 0, 255)
-- ==== DrawTranslucent - 绘制半透明特效 ====
-- 在主人身体中心绘制绿色光晕，并按节流间隔发射上升烟雾粒子
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	-- 仅当主人有效且（主人不是自己或需要绘制本地玩家）时绘制
	if owner:IsValid() and (owner ~= MySelf or owner:ShouldDrawLocalPlayer()) then
		local pos = owner:LocalToWorld(owner:OBBCenter())
		render.SetMaterial(matGlow)
		render.DrawSprite(pos, math.Rand(64, 72), math.Rand(64, 72), colGlow)

		-- 粒子发射节流：每 0.15 秒发射一次
		if self.NextEmit <= CurTime() then
			self.NextEmit = CurTime() + 0.15

			local emitter = ParticleEmitter(pos)
			emitter:SetNearClip(32, 48)

			-- 配置烟雾粒子：跟随主人速度、上浮、碰撞反弹并淡出
			local particle = emitter:Add("particle/smokestack", pos)
			particle:SetVelocity(owner:GetVelocity() * 0.8)
			particle:SetDieTime(math.Rand(1, 1.35))
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 44))
			particle:SetEndSize(20)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(Vector(0, 0, 125))
			particle:SetCollide(true)
			particle:SetBounce(0.45)
			particle:SetAirResistance(12)
			particle:SetColor(0, 200, 0)

			-- 结束发射器并触发一次增量 GC（本模式性能惯例）
			emitter:Finish() emitter = nil collectgarbage("step", 64)
		end
	end
end
