-- ============================================================================
-- cl_init.lua - 灭绝者氛围音效（客户端）：低频蜂鸣
-- 负责：为拥有者（灭绝者僵尸）循环播放低频蜂鸣音效，音调随时间波动
-- ============================================================================
INC_CLIENT()

-- 不参与渲染（纯音效实体）
ENT.RenderGroup = RENDERGROUP_NONE

-- ==== Initialize - 初始化：创建并播放氛围音效 ====
function ENT:Initialize()
	self:DrawShadow(false)

	-- 创建低频蜂鸣循环音效（初始音量 0.55，音调 110）
	self.AmbientSound = CreateSound(self, "npc/antlion_guard/confused1.wav")
	self.AmbientSound:PlayEx(0.55, 110)
end

-- ==== OnRemove - 移除时停止音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 每帧微调音量与音调（正弦波动） ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.5, 70 + math.sin(RealTime() * 3) * 10)
end

-- ==== Draw - 不绘制任何内容 ====
function ENT:Draw()
end
