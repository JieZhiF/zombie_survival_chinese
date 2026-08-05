-- ============================================================================
-- weapon_zs_poisonzombie/shared.lua - 毒液僵尸的武器（近战利爪 + 远程毒液喷射）
-- 负责：定义毒液僵尸近战属性、右键蓄力吐毒流程及各种战斗音效
-- ============================================================================
DEFINE_BASECLASS("weapon_zs_zombie")

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_poisonzombie")

-- 近战攻击距离、间隔、判定半径、伤害、伤害类型与动画延迟
SWEP.MeleeReach = 48
SWEP.MeleeDelay = 0.9
SWEP.MeleeSize = 4.5
SWEP.MeleeDamage = 30
SWEP.MeleeDamageType = DMG_SLASH
SWEP.MeleeAnimationDelay = 0.35

-- 主攻击（挥爪）间隔与副攻击（吐毒）间隔
SWEP.Primary.Delay = 1.6
SWEP.Secondary.Delay = 4

-- 吐毒延迟：按下右键到毒液真正喷出的间隔；毒液投射物飞行速度
SWEP.PoisonThrowDelay = 1
SWEP.PoisonThrowSpeed = 380

-- 第一人称手臂模型与（无掉落物）世界模型
SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
SWEP.WorldModel = ""

-- ==== Think - 处理吐毒动画与毒液喷出时机，喷出时减速自身并短暂提升腿部伤害上限 ====
function SWEP:Think()
	BaseClass.Think(self)

	local time = CurTime()

	-- 到吐毒动画时间：播放身体碎裂声与副攻击动画
	if self.NextThrowAnim and time >= self.NextThrowAnim and IsFirstTimePredicted() then
		self.NextThrowAnim = nil

		self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.random(70, 83))
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		self.IdleAnimation = time + self:SequenceDuration()
	end

	if self.NextThrow then
		-- 到毒液喷出时间：记录远程攻击时间、恢复移速、短暂提升腿部伤害上限并执行抛毒
		if time >= self.NextThrow and IsFirstTimePredicted() then
			self.NextThrow = nil

			local owner = self:GetOwner()

			owner.LastRangedAttack = CurTime()

			owner:ResetSpeed()
			owner:RawCapLegDamage(CurTime() + 1.5)

			self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.random(70, 80))

			if SERVER then
				self:DoThrow()
			end
		end

		-- 等待期间保持 Think 每帧执行
		self:NextThink(time)
		return true
	end
end

-- ==== PrimaryAttack - 挥爪攻击（吐毒准备期间不打断） ====
function SWEP:PrimaryAttack()
	if not self.NextThrow then
		BaseClass.PrimaryAttack(self)
	end
end

-- ==== SecondaryAttack - 右键蓄力吐毒：减速自身、播放动画、设置冷却并安排吐毒计时 ====
function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end

	local time = CurTime()
	if time < self:GetNextPrimaryFire() or time < self:GetNextSecondaryFire() then return end

	local owner = self:GetOwner()

	owner:DoAnimationEvent(ACT_RANGE_ATTACK2)
	owner:SetSpeed(60)

	self:EmitSound("NPC_PoisonZombie.Throw")

	self:SetNextSecondaryFire(time + self.Secondary.Delay)
	self:SetNextPrimaryFire(time + self.Primary.Delay)

	self.NextThrow = time + self.PoisonThrowDelay
	self.NextThrowAnim = self.NextThrow - 0.4
end

-- ==== Reload - 换弹键触发母本的副攻击（特殊技能） ====
function SWEP:Reload()
	if not self.NextThrow then
		BaseClass.SecondaryAttack(self)
	end
end

-- ==== CheckMoaning - 占位：毒液僵尸无持续呻吟检测 ====
function SWEP:CheckMoaning()
end

-- ==== StopMoaningSound - 占位：毒液僵尸无呻吟声 ====
function SWEP:StopMoaningSound()
end

-- ==== StartMoaningSound - 占位：毒液僵尸无呻吟声 ====
function SWEP:StartMoaningSound()
end

-- ==== PlayHitSound - 播放近战命中音效（随机爪子抓击声） ====
function SWEP:PlayHitSound()
	self:EmitSound("npc/zombie/claw_strike"..math.random(1, 3)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 播放近战挥空音效（随机爪子挥空声） ====
function SWEP:PlayMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(1, 2)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 播放攻击起始（吐毒警告）音效 ====
function SWEP:PlayAttackSound()
	self:EmitSound("NPC_PoisonZombie.ThrowWarn")
end

-- ==== PlayAlertSound - 播放发现敌人时的警报音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("NPC_PoisonZombie.Alert")
end
-- 待机音效复用警报音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound
