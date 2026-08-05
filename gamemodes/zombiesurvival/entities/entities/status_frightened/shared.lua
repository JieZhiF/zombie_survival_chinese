-- ============================================================================
-- status_frightened/shared.lua - 恐惧状态（共享定义）
-- 负责：定义恐惧状态实体：附加到玩家时记录开始时间，
--       并按拥有者的恐惧时长倍率调整实际持续时间
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

-- 临时状态：结束后立即移除，不持久保存
ENT.Ephemeral = true

-- 网络化属性：状态持续时间（秒）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 网络化属性：状态开始时间戳
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 附加到玩家时：记录开始时间并按倍率修正持续时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())

	local owner = self:GetOwner()
	if owner:IsValid() and owner.FrightDurationMul then
		-- 按拥有者的恐惧时长倍率缩放剩余持续时间
		local newdur = self:GetDuration() * owner.FrightDurationMul
		self.DieTime = CurTime() + newdur
		self:SetDuration(newdur)
	end
end
