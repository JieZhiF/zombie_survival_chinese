-- ============================================================================
-- death_wraith.lua - 幽灵死亡特效（客户端）
-- 负责：复制幽灵尸体模型作为残影，在 1 秒内模型随剩余时间逐渐压暗、
--       淡出并以正弦脉冲方式缩放，表现幽灵躯体消散融化的过程
-- ============================================================================

-- ==== Init - 特效初始化：复制目标模型并启动 1 秒寿命 ====
function EFFECT:Init(data)
	local ent = data:GetEntity()
	-- 目标实体有效时复制其模型作为消散残影，并开始 1 秒倒计时；无效则立即消亡
	if ent:IsValid() then
		self.DieTime = CurTime() + 1

		self.Entity:SetModel(ent:GetModel())
		self.Entity:SetPos(data:GetOrigin())
		self.Entity:SetAngles(data:GetNormal():Angle())
	else
		self.DieTime = 0
	end
end

-- ==== Think - 特效思考：在寿命结束前持续返回 true 保持渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- ==== Render - 特效渲染：残影随时间压暗、淡出并脉冲缩放 ====
function EFFECT:Render()
	-- delta 为剩余寿命（秒，1 → 0），统一驱动亮度、透明度与缩放
	local delta = self.DieTime - CurTime()

	-- 亮度随剩余时间衰减（从约 120 逐渐变黑），透明度同步淡出
	local brightness = delta * 120
	self.Entity:SetColor(Color(brightness, brightness, brightness, delta * 220))
	-- 正弦脉冲缩放：围绕 1 倍上下波动，振幅随剩余时间收缩，模拟幽灵挣扎消散
	local size = 1 + math.sin(delta * 20) * (delta + 0.25)
	self.Entity:SetModelScale(size, 0)
	self.Entity:DrawModel()
end
