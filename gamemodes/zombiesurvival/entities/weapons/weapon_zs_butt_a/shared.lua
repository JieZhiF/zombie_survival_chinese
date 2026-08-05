-- ============================================================================
-- weapon_zs_butt_a/shared.lua - 腐尸击打者（共享）：近战与钩爪攻击属性
-- 负责：近战伤害/攻击速度参数、右键投掷钩爪、音效与动画
-- ============================================================================
SWEP.Base = "weapon_zs_zombie" -- 基于僵尸武器母本

-- ---- 近战属性 ----
SWEP.MeleeReach = 52 -- 近战攻击距离
SWEP.MeleeDelay = 0.65 -- 近战攻击间隔
SWEP.MeleeSize = 4.5 -- 近战攻击范围半径
SWEP.MeleeDamage = 28 -- 近战伤害
SWEP.SlowDownScale = 3 -- 攻击时的减速倍率
SWEP.MeleeDamageType = DMG_SLASH -- 伤害类型：切割
SWEP.MeleeAnimationDelay = 0.05 -- 近战动画延迟

SWEP.Primary.Delay = 0.8 -- 主攻击间隔

SWEP.ViewModel = Model("models/weapons/v_pza.mdl") -- 第一人称模型
SWEP.WorldModel = "models/weapons/w_crowbar.mdl" -- 第三人称模型

-- 钩爪投掷时间（网络同步浮点）
AccessorFuncDT(SWEP, "HookTime", "Float", 1)

-- ==== SecondaryAttack - 右键投掷钩爪 ====
function SWEP:SecondaryAttack()
	-- 攻击冷却中则跳过
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() then return end

	-- 设置右键与左键的冷却时间
	self:SetNextSecondaryFire(CurTime() + 3.25)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:SetSwingAnimTime(CurTime() + 0.7)

	self:GetOwner():DoReloadEvent()

	self:EmitSound("npc/headcrab_poison/ph_poisonbite3.wav", 75, 46)

	-- 延迟 0.9 秒后真正抛出钩爪（配合动画）
	self:SetHookTime(CurTime() + 0.9)
end

-- ==== Think - 计时抛出钩爪并处理音效动画 ====
function SWEP:Think()
	-- 到达投掷时机
	if self:GetHookTime() > 0 and CurTime() >= self:GetHookTime() then
		self:SetHookTime(0)

		self:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(2, 4)..".wav", 72, math.random(70, 83))
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		if SERVER then
			self:ThrowHook()
		end
	end

	return self.BaseClass.Think(self)
end

-- ==== Reload - 重载时触发右键攻击 ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- 以下三个函数均覆写为空，禁用基类的呻吟音效
-- ==== CheckMoaning - 禁用基类的呻吟检测 ====
function SWEP:CheckMoaning()
end

-- ==== StopMoaningSound - 禁用基类的停止呻吟音效 ====
function SWEP:StopMoaningSound()
end

-- ==== StartMoaningSound - 禁用基类的开始呻吟音效 ====
function SWEP:StartMoaningSound()
end

-- ==== PlayHitSound - 命中音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(3)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 未命中音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 攻击音效（留空） ====
function SWEP:PlayAttackSound()
end

-- ==== PlayAlertSound - 警戒音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 75, 140)
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound -- 待机音效复用警戒音效

-- ==== SetSwingAnimTime - 设置挥击动画时间 ====
function SWEP:SetSwingAnimTime(time)
	self:SetDTFloat(3, time)
end

-- ==== GetSwingAnimTime - 获取挥击动画时间 ====
function SWEP:GetSwingAnimTime()
	return self:GetDTFloat(3)
end

-- ==== StartSwinging - 开始挥击 ====
function SWEP:StartSwinging()
	self.BaseClass.StartSwinging(self)
	self:SetSwingAnimTime(CurTime() + 1)
end
