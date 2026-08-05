-- ============================================================================
-- init.lua - 混乱状态（服务器）：眩晕音效与持续时间管理
-- 负责：给被施加者叠加眩晕 DSP 音效，超时或完全浸水时解除
-- ============================================================================
INC_SERVER()

-- ==== PlayerSet - 状态附加：挂载眩晕 DSP 并初始化起止时间 ====
function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.Confusion = self
	pPlayer:SetDSP(7)

	-- 首次附加时记录开始时间
	if self:GetStartTime() == 0 then
		self:SetStartTime(CurTime())
	end

	-- 未指定结束时间时默认持续 10 秒
	if self:GetEndTime() == 0 then
		self:SetEndTime(CurTime() + 10)
	end
end

-- ==== Think - 每帧检测：到结束时间或已产生眼部特效且完全浸水时移除 ====
function ENT:Think()
	local owner = self:GetOwner()
	if CurTime() >= self:GetEndTime() or self.EyeEffect and owner:IsValid() and owner:WaterLevel() >= 3 then
		self:Remove()
	end
end

-- ==== OnRemove - 移除时：清除玩家混乱引用并还原 DSP ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner.Confusion == self then
		owner.Confusion = nil
		owner:SetDSP(0)
	end
end
