-- ============================================================================
-- cl_init.lua - 医疗飞镖投射物（客户端）：治疗药剂视觉
-- 负责：创建附着的药剂模型，命中前后变色提示，并持续喷发绿色粒子
-- ============================================================================
INC_CLIENT()

-- 粒子发射节流时间（控制喷发频率）
ENT.NextEmit = 0

-- ==== Initialize - 初始化：创建随本体移动的药剂模型 ====
function ENT:Initialize()
	-- 创建小号治疗药剂模型（纯视觉，无碰撞，随投射物移动）
	local cmodel = ClientsideModel("models/healthvial.mdl")
	if cmodel:IsValid() then
		cmodel:SetPos(self:LocalToWorld(Vector(-4, 0, 0)))
		cmodel:SetAngles(self:LocalToWorldAngles(Angle(90, 0, 0)))
		cmodel:SetSolid(SOLID_NONE)
		cmodel:SetMoveType(MOVETYPE_NONE)
		cmodel:SetParent(self)
		cmodel:SetOwner(self)
		cmodel:SetModelScale(0.4, 0)
		cmodel:Spawn()

		self.CModel = cmodel
	end
end

-- ==== OnRemove - 移除时清理附属的药剂模型 ====
function ENT:OnRemove()
	if self.CModel and self.CModel:IsValid() then
		self.CModel:Remove()
	end
end

-- 材质覆盖（反光材质，配合染色实现发光效果）
local matOverride = Material("models/shiny")
-- ==== Draw - 绘制：按命中状态染色并喷发治疗粒子 ====
function ENT:Draw()
	-- 命中前纯绿；命中后绿色随时间衰减（提示治疗已完成）
	local hittime = self:GetHitTime()
	if hittime == 0 then
		render.SetColorModulation(0, 1, 0)
	else
		render.SetColorModulation(0, 1 - math.Clamp(CurTime() - hittime, 0, 1), 0)
	end
	render.ModelMaterialOverride(matOverride)

	self:DrawModel()

	-- 恢复默认渲染状态
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	-- 飞镖停止移动后不再喷发粒子
	if self:GetMoveType() == MOVETYPE_NONE or CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.01

	local pos = self:GetPos()

	-- 喷发绿色烟雾粒子
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(0.35)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(30, 255, 30)

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
