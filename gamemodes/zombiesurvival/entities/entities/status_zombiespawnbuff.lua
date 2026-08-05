-- ============================================================================
-- status_zombiespawnbuff.lua - 僵尸出生保护状态（共享）
-- 负责：给予目标玩家出生保护（SpawnProtection 标记），保护期间为持续时长，
--       状态移除时清除保护；供僵尸在复活点出生时短暂免伤使用
-- ============================================================================
AddCSLuaFile()

-- 实体类型为动画实体，继承 status__base 状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- 状态持续时间（秒）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 状态开始时间（CurTime 时间戳）
AccessorFuncDT(ENT, "StartTime", "Float", 4)
-- ==== Initialize - 状态初始化：开启拥有者的出生保护 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 随机种子，供外观/特效差异使用
	self.Seed = math.Rand(0, 10)

	-- 直接开启拥有者的出生保护标记
	self:GetOwner().SpawnProtection = true
end

-- ==== PlayerSet - 状态附加到玩家：记录开始时间并开启保护 ====
function ENT:PlayerSet(pl)
	self:SetStartTime(CurTime())
	pl.SpawnProtection = true
end

-- ==== OnRemove - 状态移除：关闭拥有者的出生保护 ====
function ENT:OnRemove()
	self.BaseClass.OnRemove(self)

	self:GetOwner().SpawnProtection = false
end

-- ==== SetDie - 设置死亡/结束时间：0 立即结束，-1 永续，正数在现有基础上延长 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	elseif self.DieTime < CurTime() + fTime then
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end
  