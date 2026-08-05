-- ============================================================================
-- status_dimvision/shared.lua - 暗视状态（共享）
-- 负责：定义暗视（DimVision）状态：客户端注册屏幕特效钩子使画面变暗，
--       并记录时长/开始时间；支持按拥有者的时长修正系数调整持续时间
-- ============================================================================
-- 动画实体类型，继承通用状态基类 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- 标记：短暂状态（不随状态列表显示/叠加，直接瞬态生效）
ENT.Ephemeral = true

-- 状态持续时间与开始时间的网络同步字段（客户端可读）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：注册屏幕特效钩子并登记到拥有者 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 暗视状态不需要阴影
	self:DrawShadow(false)

	if CLIENT then
		-- 注册屏幕空间特效钩子：在客户端逐帧应用变暗效果
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)
	end

	-- 将自身登记到拥有者，供其他系统查询暗视状态
	self:GetOwner().DimVision = self
end

-- ==== OnRemove - 移除时解除钩子并清理拥有者上的登记 ====
function ENT:OnRemove()
	self.BaseClass.OnRemove(self)

	self:GetOwner().DimVision = nil
end

-- ==== PlayerSet - 附加到玩家时记录开始时间并按系数调整时长 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())

	-- 若拥有者定义了暗视时长修正系数，则按系数缩放持续时间与死亡时间
	local owner = self:GetOwner()
	if owner:IsValid() and owner.VisionAlterDurationMul then
		local newdur = self:GetDuration() * owner.VisionAlterDurationMul
		self.DieTime = CurTime() + newdur
		self:SetDuration(newdur)
	end
end
