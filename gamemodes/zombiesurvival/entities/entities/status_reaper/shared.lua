-- ============================================================================
-- status_reaper/shared.lua - 死神状态（共享）
-- 负责：定义死神状态实体（人类击杀僵尸后获得，持续 14 秒，每击杀刷新
--       并提升层数）；服务器端注册伤害与击杀钩子，记录状态起止时间
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

-- ==== Initialize - 初始化状态实体并注册服务器钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		-- 注册伤害钩子（叠层增伤）与击杀僵尸钩子（刷新状态）
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
		hook.Add("HumanKilledZombie", self, self.HumanKilledZombie)

		-- 初始化伤害层数计数（每层 +8% 伤害）
		self:SetDTInt(1, 0)
	end
end
