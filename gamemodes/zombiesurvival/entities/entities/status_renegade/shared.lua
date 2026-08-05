-- ============================================================================
-- status_renegade/shared.lua - 叛徒状态（共享）
-- 负责：定义叛徒状态实体（由 Renegade 步枪/M82A3 三次爆头击杀触发，
--       持续 17 秒）；服务器端注册伤害钩子，记录状态起止时间
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型，继承通用状态基类 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- 状态持续时间与开始时间的网络同步字段（客户端可读）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 状态附加到玩家身上时记录开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

-- ==== Initialize - 初始化状态实体并注册服务器伤害钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		-- 注册伤害钩子：叛徒状态下由拥有者造成的伤害免除恐惧值减免
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)

		-- 初始化伤害层数计数（预留字段）
		self:SetDTInt(1, 0)
	end
end
