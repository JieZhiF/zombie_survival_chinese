-- ============================================================================
-- status_frightened/cl_init.lua - 恐惧状态（客户端）
-- 负责：仅对本地玩家生效：开启惊吓 DSP 音效滤镜，
--       并循环播放呼吸与心跳声营造恐惧氛围
-- ============================================================================
INC_CLIENT()

-- ==== OnInitialize - 初始化：本地玩家开启 DSP 滤镜并播放呼吸/心跳声 ====
function ENT:OnInitialize()
	local owner = self:GetOwner()
	if owner ~= MySelf then return end

	owner:SetDSP(31, false)
	self.AmbientSound = CreateSound(self, "player/breathe1.wav")
	self.AmbientSound:Play()
	self.AmbientSound2 = CreateSound(self, "player/heartbeat1.wav")
	self.AmbientSound2:Play()
end

-- ==== OnRemove - 移除时停止音效并恢复默认 DSP，再调用基类清理 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner == MySelf then
		self.AmbientSound:Stop()
		self.AmbientSound2:Stop()
		owner:SetDSP(0, false)
	end

	self.BaseClass.OnRemove(self)
end
