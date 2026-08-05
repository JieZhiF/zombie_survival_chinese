-- ============================================================================
-- status_bonemeshambience - 骨网（Bonemesh）环境音效状态实体（客户端）
-- 负责：为持有者播放低吼环境音效；持有者挥舞武器时暂停，其余时间以正弦波动音调循环播放
-- ============================================================================
INC_CLIENT()

-- 渲染分组：不渲染任何模型
ENT.RenderGroup = RENDERGROUP_NONE

-- ==== Initialize - 创建并立即播放环境音效 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "npc/antlion_guard/growl_idle.wav")
	self.AmbientSound:PlayEx(0.55, 150)
end

-- ==== OnRemove - 实体移除时停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 持有者挥砍武器时停止音效，否则以正弦波动音调持续播放 ====
function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		if wep:IsValid() and wep.IsSwinging and wep:IsSwinging() then
			self.AmbientSound:Stop()
		else
			self.AmbientSound:PlayEx(0.55, 150 + math.sin(RealTime()))
		end
	end
end

-- ==== Draw - 本实体不绘制任何内容 ====
function ENT:Draw()
end
