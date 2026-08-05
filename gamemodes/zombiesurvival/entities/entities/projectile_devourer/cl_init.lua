-- ============================================================================
-- cl_init.lua - 吞噬者投射物（客户端）：骨刺染色、拖拽光束与血雾粒子
-- 负责：渲染骨刺与手部之间的拖拽光束，飞行时喷发血雾粒子并播放音效
-- ============================================================================
INC_CLIENT()

-- 下次喷发粒子的时间
ENT.NextEmit = 0

-- 拖拽光束与发光点材质
local matTrail = Material("cable/rope")
local matGlow = Material("sprites/light_glow02_add")

-- ==== Initialize - 初始化：创建环境音效并记录生成时间 ====
function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "npc/strider/strider_skewer1.wav")
	self.Created = CurTime()
end

-- ==== Think - 每帧更新：持续播放音效，音调随存在时间升高 ====
function ENT:Think()
	self.AmbientSound:PlayEx(1, 50 + math.min(1, CurTime() - self.Created) * 30)

	self:NextThink(CurTime())
	return true
end

-- ==== OnRemove - 移除时：停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- 本体染色材质与光束/发光点配色（暗红色）
local matWhite = Material("models/shiny")
local colGlow = Color(125, 10, 10, 120)
local colBeam = Color(75, 0, 0, 255)
-- ==== Draw - 绘制：染色骨刺、手部到骨刺的光束与飞行血雾 ====
function ENT:Draw()
	-- 以白色高光材质覆盖后染成暗红橙色绘制本体
	render.ModelMaterialOverride(matWhite)
	render.SetColorModulation(1, 0.5, 0.3)

	-- 已吸附到目标时，把骨刺模型下移 48 单位配合绘制位置
	local hooked = self:GetParent():IsValid()

	if hooked then
		self:SetLocalPos(Vector(0, 0, -48))
	end

	self:DrawModel()

	if hooked then
		self:SetLocalPos(vector_origin)
	end

	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride(nil)

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local handpos
	local hookpos = self:WorldSpaceCenter()

	if hooked then
		hookpos.z = hookpos.z - 48
	end

	-- 获取持有者右手骨骼位置作为光束起点（自身视角下无手部模型时退回身体中心）
	local boneid = (owner ~= LocalPlayer() or owner:ShouldDrawLocalPlayer()) and owner:LookupBone("ValveBiped.Bip01_R_Hand")
	if boneid and boneid > 0 then
		local p, a = owner:GetBonePositionMatrixed(boneid)
		handpos = p
	else
		handpos = owner:WorldSpaceCenter()
	end

	-- 扩展渲染边界，保证光束两端都不被视锥剔除
	self:SetRenderBoundsWS(handpos, hookpos, 128)

	-- 绘制手部到骨刺的暗红拖拽光束
	render.SetMaterial(matTrail)
	render.DrawBeam(handpos, hookpos, 3, 4, 0, colBeam)

	-- 光束两端点亮红色发光点
	render.SetMaterial(matGlow)
	render.DrawSprite(hookpos, 35, 35, colGlow)
	render.DrawSprite(handpos, 35, 35, colGlow)

	-- 飞行中每 0.06 秒喷发 3 个血雾粒子
	if CurTime() >= self.NextEmit and self:GetVelocity():LengthSqr() >= 256 then
		self.NextEmit = CurTime() + 0.06

		local emitter = ParticleEmitter(hookpos)
		emitter:SetNearClip(16, 24)

		for i = 1, 3 do
			local particle = emitter:Add("!sprite_bloodspray"..math.random(8), hookpos)
			particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(12, 22))
			particle:SetDieTime(2)
			particle:SetStartAlpha(230)
			particle:SetEndAlpha(0)
			particle:SetStartSize(5)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-25, 25))
			particle:SetGravity(Vector(0, 0, -100))
			particle:SetColor(150, 0, 0)
		end

		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end
