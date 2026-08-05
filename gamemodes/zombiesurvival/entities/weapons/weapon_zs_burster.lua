-- ============================================================================
-- weapon_zs_burster.lua - 爆裂者（僵尸自爆武器）
-- 负责：实现蓄力自爆机制——按住左键开始蓄力并加速冲锋，蓄满后立即自爆
--       （击杀自己触发爆炸伤害），换弹键可提前引爆
-- ============================================================================
-- 全端加载（服务端 + 客户端）
AddCSLuaFile()

-- 继承自僵尸基础武器
SWEP.Base = "weapon_zs_zombie"

-- 蓄满自爆所需时间（秒）
SWEP.ChargeTime = 2.1

-- ==== PrimaryAttack - 左键开始蓄力 ====
-- 首次按下记录蓄力开始时间与视角快照，并播放蓄力音效；持续按住期间不断触发
function SWEP:PrimaryAttack()
	if self:GetChargeStart() == 0 then
		self:SetChargeStart(CurTime())

		-- 记录蓄力开始时的视角（供冲锋方向使用）
		self.m_ViewAngles = self:GetOwner():EyeAngles()

		-- 首次预测时播放高音调蓄力音效
		if IsFirstTimePredicted() then
			self:EmitSound(")ambient/levels/labs/teleport_mechanism_windup5.wav", 80, 185, 0.75)
		end
	end
end

-- ==== SecondaryAttack - 右键（无功能占位） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹键触发父类副攻击（提前引爆） ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== Think - 每帧检查蓄力进度：蓄满即自爆 ====
function SWEP:Think()
	-- 蓄力达到 100% 时自爆（击杀自己，由死亡逻辑触发爆炸）
	if self:GetCharge() >= 1 then
		self:GetOwner():Kill()
	end

	-- 持续调度下一帧 Think
	self:NextThink(CurTime())
	return true
end

-- ==== IsMoaning - 蓄力期间不发出呻吟声 ====
function SWEP:IsMoaning()
	return false
end

-- ==== Move - 蓄力期间提高移动速度（冲锋） ====
-- 蓄力进度越高速度加成越大，最高 +70%
function SWEP:Move(mv)
	local charge = self:GetCharge()
	if charge > 0 then
		local mul = 1 + charge * 0.7
		mv:SetMaxSpeed(mv:GetMaxSpeed() * mul)
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * mul)
	end
end

-- ==== SetChargeStart - 写入蓄力开始时间（DT 0 号位，服务端/客户端同步） ====
function SWEP:SetChargeStart(time)
	self:SetDTFloat(0, time)
end

-- ==== GetChargeStart - 读取蓄力开始时间 ====
function SWEP:GetChargeStart()
	return self:GetDTFloat(0)
end

-- ==== GetCharge - 计算当前蓄力进度（0~1） ====
-- 未开始蓄力返回 0；按已蓄时间占蓄力总时长的比例钳制在 0~1
function SWEP:GetCharge()
	if self:GetChargeStart() == 0 then return 0 end

	return math.Clamp((CurTime() - self:GetChargeStart()) / self.ChargeTime, 0, 1)
end
