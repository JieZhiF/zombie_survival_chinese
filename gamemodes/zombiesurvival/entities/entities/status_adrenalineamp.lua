-- ============================================================================
-- status_adrenalineamp.lua - 肾上腺素增幅状态（共享/服务端）
-- 负责：附加到玩家时提升移动速度（速度值可为负实现减速），并支持设定持续时间
-- ============================================================================
AddCSLuaFile()

-- 基于 anim 实体类型，继承状态类基座 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- 瞬时状态（不常驻在玩家状态栏，随效果结束立即移除）
ENT.Ephemeral = true

-- 网络化数据访问器：持续时间（DT 浮点槽 0）与开始时间（DT 浮点槽 4）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 状态附加到玩家时记录开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

if SERVER then
	-- ==== SetDie - 设置状态持续时间（服务端）====
	-- 0/空 = 无限期，-1 = 极长时间，正数 = 按时长到期并同步 Duration
	function ENT:SetDie(fTime)
		if fTime == 0 or not fTime then
			self.DieTime = 0
		elseif fTime == -1 then
			self.DieTime = 999999999
		else
			self.DieTime = CurTime() + fTime
			self:SetDuration(fTime)
		end
	end
end

-- ==== Initialize - 初始化并挂接移动钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	hook.Add("Move", self, self.Move)
end

-- ==== Move - 移动钩子：修正主人的移动速度 ====
-- 在原有速度基础上叠加本状态的加成值（每秒单位）
function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	move:SetMaxSpeed(move:GetMaxSpeed() + self:GetSpeed())
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end

-- ==== SetSpeed - 写入速度加成（DT 浮点槽 1，下限 -15）====
function ENT:SetSpeed(speed)
	self:SetDTFloat(1, math.max(-15, speed))
end

-- ==== GetSpeed - 读取速度加成（DT 浮点槽 1）====
function ENT:GetSpeed()
	return self:GetDTFloat(1)
end
