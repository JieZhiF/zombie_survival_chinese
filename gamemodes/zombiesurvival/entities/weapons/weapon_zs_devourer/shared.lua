-- ============================================================================
-- weapon_zs_devourer/shared.lua - 吞噬者（Devourer）僵尸（共享）
-- 负责：定义近战参数与右键钩爪技能（延迟 0.9 秒后抛出钩爪拉拽目标），
--       以及整套攻击/警戒音效；换弹键复用基底右键
-- ============================================================================
-- 继承通用僵尸近战武器基底
SWEP.Base = "weapon_zs_zombie"

-- 近战攻击距离（单位）
SWEP.MeleeReach = 52
-- 近战攻击判定间隔（秒）
SWEP.MeleeDelay = 0.36
-- 近战判定盒大小
SWEP.MeleeSize = 4.5
-- 近战单次伤害
SWEP.MeleeDamage = 24
-- 攻击时对持枪者的减速倍率（3 = 攻击时显著减速）
SWEP.SlowDownScale = 3
-- 近战伤害类型（劈砍）
SWEP.MeleeDamageType = DMG_SLASH
-- 近战动画延迟（秒）
SWEP.MeleeAnimationDelay = 0.05

-- 主攻击间隔（秒）
SWEP.Primary.Delay = 0.8

-- 视模型为僵尸手臂，世界模型用撬棍占位
SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

-- 钩爪出手时刻的 DT 同步字段（Float，DT 槽 1）
AccessorFuncDT(SWEP, "HookTime", "Float", 1)

-- ==== SecondaryAttack - 右键技能：钩爪攻击（蓄力 0.9 秒后由 Think 抛出） ====
function SWEP:SecondaryAttack()
	-- 与主攻击、副攻击共用冷却，未到时间直接返回
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() then return end

	-- 钩爪冷却 3.25 秒，期间主攻击锁定 Primary.Delay
	self:SetNextSecondaryFire(CurTime() + 3.25)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 记录挥击动画时间（0.7 秒后）
	self:SetSwingAnimTime(CurTime() + 0.7)

	-- 通知所有者执行换弹动作事件（供动画/音效系统联动）
	self:GetOwner():DoReloadEvent()

	-- 毒头蟹啃咬声（低沉音调）
	self:EmitSound("npc/headcrab_poison/ph_poisonbite3.wav", 75, 46)

	-- 预约 0.9 秒后抛出钩爪
	self:SetHookTime(CurTime() + 0.9)
end

-- ==== Think - 每帧逻辑：钩爪到点后播放动画并抛出 ====
function SWEP:Think()
	-- 钩爪时机到达：播放软体撞击声 + 副攻击动画，服务器端抛出钩爪实体
	if self:GetHookTime() > 0 and CurTime() >= self:GetHookTime() then
		self:SetHookTime(0)

		self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(2, 4)..".wav", 72, math.random(70, 83))
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		if SERVER then
			self:ThrowHook()
		end
	end

	-- 继续基底 Think
	return self.BaseClass.Think(self)
end

-- ==== Reload - 换弹键触发：使用基底右键（扑击）技能 ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== CheckMoaning - 检查呻吟（空实现：吞噬者不自动呻吟） ====
function SWEP:CheckMoaning()
end

-- ==== StopMoaningSound - 停止呻吟音效（空实现） ====
function SWEP:StopMoaningSound()
end

-- ==== StartMoaningSound - 开始呻吟音效（空实现） ====
function SWEP:StartMoaningSound()
end

-- ==== PlayHitSound - 命中音效（僵尸爪击） ====
function SWEP:PlayHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(3)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 挥空音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 攻击音效（空实现） ====
function SWEP:PlayAttackSound()
end

-- ==== PlayAlertSound - 警戒音效（蚂蚁狮守卫怒吼，高音调） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 75, 140)
end
-- 闲置吼叫复用警戒音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound

-- ==== SetSwingAnimTime - 写入挥击动画时间（DT 槽 3） ====
function SWEP:SetSwingAnimTime(time)
	self:SetDTFloat(3, time)
end

-- ==== GetSwingAnimTime - 读取挥击动画时间（DT 槽 3） ====
function SWEP:GetSwingAnimTime()
	return self:GetDTFloat(3)
end

-- ==== StartSwinging - 开始挥击：调用基底并延长挥击动画时间 ====
function SWEP:StartSwinging()
	self.BaseClass.StartSwinging(self)
	-- 挥击动画持续 1 秒
	self:SetSwingAnimTime(CurTime() + 1)
end
