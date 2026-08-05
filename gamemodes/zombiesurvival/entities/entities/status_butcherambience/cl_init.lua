-- ============================================================================
-- status_butcherambience/cl_init.lua - 屠夫环境音效状态（客户端）
-- 负责：为屠夫僵尸持续播放低吼环境音效；拥有者挥击时暂停，
--       非挥击时按随机波动调制音量与音高
-- ============================================================================
INC_CLIENT()

-- 渲染组：不参与任何渲染，该实体仅为音效载体
ENT.RenderGroup = RENDERGROUP_NONE

-- ==== Initialize - 初始化：关闭阴影并创建循环低吼音效 ====
function ENT:Initialize()
	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "npc/antlion_guard/growl_idle.wav")
	self.AmbientSound:PlayEx(0.55, 110)
end

-- ==== OnRemove - 移除时停止环境音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== Think - 音效状态刷新：挥击时静音，平时持续播放并调制音调 ====
function ENT:Think()
	owner = self:GetOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		-- 拥有者正在挥击武器时暂停低吼，避免与攻击音效重叠
		if wep:IsValid() and wep.IsSwinging and wep:IsSwinging() then
			self.AmbientSound:Stop()
		else
			-- 非挥击时恢复播放，音高在随机抖动叠加正弦波动的基础上变化
			self.AmbientSound:PlayEx(0.6, 100 + math.Rand(-30, 30) + math.sin(RealTime() * 4) * 20)
		end
	end
end

-- ==== Draw - 空实现：纯音效实体无需绘制模型 ====
function ENT:Draw()
end
