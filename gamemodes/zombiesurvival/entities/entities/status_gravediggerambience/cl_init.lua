-- ============================================================================
-- status_gravediggerambience - 掘墓人（Gravedigger）环境音效状态实体（客户端）
-- 负责：为持有者持续播放低沉的喉音环境音效，并在实体移除时停止
-- ============================================================================
INC_CLIENT()

-- 渲染分组：不渲染任何模型
ENT.RenderGroup = RENDERGROUP_NONE

-- ==== Initialize - 创建并立即播放环境音效（低音量、高音调） ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "npc/fast_zombie/gurgle_loop1.wav")
	self.AmbientSound:PlayEx(0.55, 110)
end

-- ==== OnRemove - 实体移除时停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 持有者存活时循环播放音效，音调随随机量与正弦波动轻微起伏 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		self.AmbientSound:PlayEx(0.6, 50 + math.Rand(-15, 15) + math.sin(RealTime() * 4) * 10)
	end
end

-- ==== Draw - 本实体不绘制任何内容 ====
function ENT:Draw()
end
