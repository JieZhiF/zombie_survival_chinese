-- ============================================================================
-- cl_init.lua - 快速僵尸喘息环境音效（客户端）
-- 负责：为携带快速僵尸攻击姿态的玩家持续播放呼吸声，攻击动作时静音，随移速调节音量
-- ============================================================================
INC_CLIENT()

-- 不参与任何渲染分组（纯音效实体，无需绘制）
ENT.RenderGroup = RENDERGROUP_NONE

-- ==== Initialize - 初始化：创建并播放循环呼吸音效 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "npc/fast_zombie/breathe_loop1.wav")
	-- 以 0.55 音量、100 音高开始循环播放
	self.AmbientSound:PlayEx(0.55, 100)
end

-- ==== OnRemove - 移除时停止音效，防止残留 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 每帧更新：根据攻击动作与移动速度调节呼吸音 ====
function ENT:Think()
	owner = self:GetOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		-- 玩家正在挥击/咆哮/攀爬/扑击时静音，否则按速度与正弦波动调节音量
		if wep:IsValid() and (wep.IsSwinging and wep:IsSwinging() or wep.IsRoaring and wep:IsRoaring() or wep.IsClimbing and wep:IsClimbing() or wep.IsPouncing and wep:IsPouncing()) then
			self.AmbientSound:Stop()
		else
			self.AmbientSound:PlayEx(0.55, math.min(60 + owner:GetVelocity():Length2D() * 0.15, 100) + math.sin(RealTime()))
		end
	end
end

-- ==== Draw - 空绘制：本实体不渲染任何模型 ====
function ENT:Draw()
end
