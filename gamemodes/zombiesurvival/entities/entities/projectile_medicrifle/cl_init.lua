-- ============================================================================
-- cl_init.lua - 医疗步枪子弹投射物（客户端）：双模式药剂外观
-- 负责：按强化模式标记创建红色/绿色药剂模型，并喷发对应颜色的粒子
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：按模式创建附着的药剂模型 ====
function ENT:Initialize()
	-- GetDTBool(0) 为"活力强化"分支标记：true 为强化模式（伤害弹），false 为治疗模式
	local alt = self:GetDTBool(0)
	local cmodel = ClientsideModel("models/healthvial.mdl")
	if cmodel:IsValid() then
		cmodel:SetPos(self:LocalToWorld(Vector(-4, 0, 0)))
		cmodel:SetAngles(self:LocalToWorldAngles(Angle(90, 0, 0)))
		cmodel:SetSolid(SOLID_NONE)
		cmodel:SetMoveType(MOVETYPE_NONE)
		cmodel:SetColor(Color(alt and 255 or 75, 75, alt and 75 or 255))
		cmodel:SetParent(self)
		cmodel:SetOwner(self)
		cmodel:SetModelScale(0.4, 0)
		cmodel:Spawn()

		self.CModel = cmodel
	end
end

-- 材质覆盖（反光材质，配合染色实现发光效果）
local matOverride = Material("models/shiny")
-- ==== Draw - 绘制：按模式染色并喷发对应颜色粒子 ====
function ENT:Draw()
	local alt = self:GetDTBool(0)
	-- 强化模式偏红，治疗模式偏蓝
	render.SetColorModulation(alt and 1 or 0.3, 0.4, alt and 0.3 or 1)
	render.ModelMaterialOverride(matOverride)

	self:DrawModel()

	-- 恢复默认渲染状态
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	-- 子弹停止移动后不再喷发粒子
	if self:GetMoveType() == MOVETYPE_NONE or CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.01

	local pos = self:GetPos()

	-- 喷发反向飘散的烟雾粒子
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particles/smokey", pos)
	particle:SetVelocity(self:GetVelocity() * -0.1 + VectorRand() * 30)
	particle:SetDieTime(0.35)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(2)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(alt and 255 or 90, 140, alt and 90 or 255)

	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
