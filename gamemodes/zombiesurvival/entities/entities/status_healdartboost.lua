-- ============================================================================
-- status_healdartboost.lua - 治疗镖加速状态（共享）
-- 负责：治疗镖命中后附加的增益状态，持续期间使携带者移动速度 +50
-- ============================================================================
AddCSLuaFile()

-- 实体类型：动画实体，基于状态基类 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- 状态持续时间（网络同步浮点）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 状态开始时间（网络同步浮点，用于剩余时间计算）
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 附加到玩家时记录当前时间为开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end

if SERVER then
	-- ==== SetDie - 服务器端设定状态结束时间（0=立即，-1=无限，否则为当前时间+时长） ====
	function ENT:SetDie(fTime)
		if fTime == 0 or not fTime then
			-- 立即结束
			self.DieTime = 0
		elseif fTime == -1 then
			-- 无限持续（近似永久）
			self.DieTime = 999999999
		else
			-- 正常计时：记录结束时间并同步剩余时长到客户端
			self.DieTime = CurTime() + fTime
			self:SetDuration(fTime)
		end
	end
end

-- ==== Initialize - 初始化：调用基类并注册移动加速 hook ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 注册 Move hook（以实体自身为回调），每帧调整携带者移动速度
	hook.Add("Move", self, self.Move)
end

-- ==== Move - 移动修正：仅对携带者生效，将最大移动速度提升 50 ====
function ENT:Move(pl, move)
	-- 只影响本状态的携带者
	if pl ~= self:GetOwner() then return end

	-- 抬高服务器端最大移动速度，并同步客户端预测速度（避免回拉）
	move:SetMaxSpeed(move:GetMaxSpeed() + 50)
	move:SetMaxClientSpeed(move:GetMaxSpeed())
end
