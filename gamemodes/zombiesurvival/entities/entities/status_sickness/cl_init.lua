-- ============================================================================
-- status_sickness/cl_init.lua - 疾病状态（客户端）
-- 负责：仅对本地玩家播放高音调心跳音效营造患病氛围，
--       状态移除时停止音效
-- ============================================================================
INC_CLIENT()

-- ==== OnInitialize - 附加初始化：对本地玩家播放心跳音效 ====
function ENT:OnInitialize()
	local owner = self:GetOwner()
	-- 仅本地玩家听到患病心跳声
	if owner ~= MySelf then return end

	-- 循环播放 222Hz 音调的心跳声
	self.AmbientSound = CreateSound(self, "player/heartbeat1.wav")
	self.AmbientSound:PlayEx(1, 222)
end

-- ==== OnRemove - 移除：停止本地玩家的心跳音效 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner == MySelf then
		self.AmbientSound:Stop()
	end

	self.BaseClass.OnRemove(self)
end
