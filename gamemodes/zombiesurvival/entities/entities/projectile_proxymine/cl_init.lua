-- ============================================================================
-- cl_init.lua - 感应地雷投射物（客户端）：附属模型与武装/引爆灯光提示
-- 负责：挂载缩小的小型断路器模型，并用红/绿发光点提示引爆与武装状态
-- ============================================================================
INC_CLIENT()

-- 同时绘制不透明与半透明部分
ENT.RenderGroup = RENDERGROUP_BOTH

-- ==== Initialize - 初始化：创建缩小的断路器附属模型并吸附到地雷上 ====
function ENT:Initialize()
	self.CreateTime = CurTime()

	local cmodel = ClientsideModel("models/props_c17/substation_circuitbreaker01a.mdl")
	if cmodel:IsValid() then
		cmodel:SetPos(self:LocalToWorld(Vector(0, 0, 7)))
		cmodel:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 0)))
		cmodel:SetColor(Color(255, 205, 175, 255))
		cmodel:SetSolid(SOLID_NONE)
		cmodel:SetMoveType(MOVETYPE_NONE)
		cmodel:SetParent(self)
		cmodel:SetOwner(self)
		cmodel:SetModelScale(0.02, 0)
		cmodel:Spawn()

		self.CModel = cmodel
	end
end

-- ==== OnRemove - 移除时：清理附属模型 ====
function ENT:OnRemove()
	if self.CModel and self.CModel:IsValid() then
		self.CModel:Remove()
	end
end

-- ==== Draw - 不透明绘制：正常绘制模型 ====
function ENT:Draw()
	self:DrawModel()
end

-- 发光粒子材质（状态指示灯）
local matGlow = Material("sprites/glow04_noz")
-- ==== DrawTranslucent - 半透明绘制：按状态显示红/绿脉冲光点 ====
function ENT:DrawTranslucent()
	local lightpos = self:GetPos() + self:GetUp() * 9

	-- 已锁定目标：红色闪烁光点，频率和大小由时间驱动
	if self:GetExplodeTime() ~= 0 then
		local size = (CurTime() * 8.5 % 1) * 24
		render.SetMaterial(matGlow)
		render.DrawSprite(lightpos, size, size, Color(255, 50, 50, size * 5))
		render.DrawSprite(lightpos, size / 2, size / 2, Color(255, 50, 50, size * 15))
	elseif self.CreateTime + self.ArmTime < CurTime() then
		-- 已武装待命：绿色呼吸光点
		local size = 4 + (CurTime() * 2 % 1) * 6
		render.SetMaterial(matGlow)
		render.DrawSprite(lightpos, size, size, Color(50, 255, 50, size * 5))
		render.DrawSprite(lightpos, size / 2, size / 2, Color(50, 255, 50, size * 15))
	end
end
