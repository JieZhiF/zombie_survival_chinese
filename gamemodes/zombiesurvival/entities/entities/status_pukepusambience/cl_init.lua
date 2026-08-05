-- ============================================================================
-- status_pukepusambience - 呕吐怪环境音效状态实体（客户端）
-- 负责：持续播放毒物呼吸环境音，持有者挥砍武器时暂停
-- ============================================================================
INC_CLIENT()

-- 渲染组：不渲染任何内容（纯音效状态实体）
ENT.RenderGroup = RENDERGROUP_NONE

-- ==== Initialize - 关闭阴影并创建循环播放的毒物呼吸音 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "npc/zombie_poison/pz_breathe_loop2.wav")
	self.AmbientSound:PlayEx(0.75, 65)
end

-- ==== OnRemove - 停止环境音 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 持有者挥砍武器时暂停呼吸音，否则以正弦起伏的音调持续播放 ====
function ENT:Think()
	owner = self:GetOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		if wep:IsValid() and wep.IsSwinging and wep:IsSwinging() then
			self.AmbientSound:Stop()
		else
			-- 非挥砍状态：维持呼吸音播放，音调随时间正弦起伏
			self.AmbientSound:PlayEx(0.75, 65 + math.sin(RealTime()))
		end
	end
end

-- ==== Draw - 空实现（纯音效状态，无需绘制） ====
function ENT:Draw()
end
