-- ============================================================================
-- projectile_strengthdart/cl_init.lua - 力量飞镖（客户端）
-- 负责：渲染飞镖外观（力量模式=红色，防御模式=蓝色），并在飞行时生成烟雾拖尾
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 创建客户端视觉模型：按模式着色并附加到飞镖本体 ====
function ENT:Initialize()
	-- 读取服务器同步的模式标记：false=力量模式（红），true=防御模式（蓝）
	local alt = self:GetDTBool(0)
	-- 使用小号医疗瓶模型作为飞镖外观
	local cmodel = ClientsideModel("models/healthvial.mdl")
	if cmodel:IsValid() then
		-- 偏移并旋转模型，使其贴合飞镖本体
		cmodel:SetPos(self:LocalToWorld(Vector(-4, 0, 0)))
		cmodel:SetAngles(self:LocalToWorldAngles(Angle(90, 0, 0)))
		-- 纯视觉模型：无碰撞、不移动，跟随飞镖本体
		cmodel:SetSolid(SOLID_NONE)
		cmodel:SetMoveType(MOVETYPE_NONE)
		cmodel:SetParent(self)
		-- 力量模式为红色，防御模式为蓝色
		cmodel:SetColor(Color(alt and 50 or 255, 50, alt and 255 or 50))
		cmodel:SetOwner(self)
		-- 缩放至 40% 并生成
		cmodel:SetModelScale(0.4, 0)
		cmodel:Spawn()

		-- 保存模型引用，供 Draw 阶段使用
		self.CModel = cmodel
	end
end

-- 覆盖材质：使用光滑材质配合颜色调制实现发光效果
local matOverride = Material("models/shiny")
-- ==== Draw - 绘制飞镖本体并生成飞行拖尾粒子 ====
function ENT:Draw()
	-- 按模式调制颜色：力量=偏红，防御=偏蓝
	local alt = self:GetDTBool(0)
	render.SetColorModulation(alt and 0.3 or 1, 0.4, alt and 1 or 0.4)
	render.ModelMaterialOverride(matOverride)

	self:DrawModel()

	-- 恢复默认渲染状态
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	-- 命中停止飞行后不再发射粒子；限制每 0.01 秒最多生成一次
	if self:GetMoveType() == MOVETYPE_NONE or CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.01

	local pos = self:GetPos()

	-- 创建粒子发射器，并设置近距离裁剪范围使粒子始终可见
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	-- 烟雾拖尾粒子：0.35 秒内淡出并缩小
	local particle = emitter:Add("particles/smokey", pos)
	particle:SetDieTime(0.35)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(0)
	-- 随机初始旋转与旋转速度，让拖尾更自然
	particle:SetRoll(math.Rand(0, 255))
	particle:SetRollDelta(math.Rand(-10, 10))
	-- 粒子颜色与模式一致（力量=红，防御=蓝）
	particle:SetColor(alt and 50 or 255, 50, alt and 255 or 50)

	-- 立即结束发射器并释放内存
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end
