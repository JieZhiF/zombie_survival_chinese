-- ============================================================================
-- weapon_zs_tormentedwraith/shared.lua - 痛苦怨灵之爪（僵尸专用近战武器）
-- 负责：定义近战爪击的属性与左右键攻击逻辑，继承武器_zs_wraith（怨灵之爪）基类
-- ============================================================================

-- 继承的基础武器类
SWEP.Base = "weapon_zs_wraith"
-- 声明基类引用，供后续调用 BaseClass.xxx 使用
DEFINE_BASECLASS("weapon_zs_wraith")

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_tormentedwraith")

-- 近战挥击后的收招延迟
SWEP.MeleeDelay = 0.4
-- 近战攻击距离
SWEP.MeleeReach = 48
-- 近战攻击判定范围半径
SWEP.MeleeSize = 4.5
-- 近战基础伤害
SWEP.MeleeDamage = 20
-- 近战伤害类型：切割伤害
SWEP.MeleeDamageType = DMG_SLASH
-- 近战攻击动画延迟（0 表示立即播放）
SWEP.MeleeAnimationDelay = 0

-- 右键（重爪击）的施放延迟
SWEP.Secondary.Delay = 0.88

-- 第一人称视角模型
SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
-- 第三人称世界模型（留空则不可见）
SWEP.WorldModel = ""

-- 注册网络同步的 DT 变量：Tormented（受折磨状态剩余时间），用于强化状态判定
AccessorFuncDT(SWEP, "Tormented", "Float", 1)

-- ==== PrimaryAttack - 左键轻爪击 ====
function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	-- 冷却未结束则跳过本次攻击
	if CurTime() < self:GetNextPrimaryFire() then return end

	-- 攻击间隔：受攻速加成影响，且在"受折磨"强化生效期间（2 秒内）缩短为 75%
	local armdelay = owner:GetMeleeSpeedMul() * ((CurTime() < self:GetTormented() + 2) and 0.75 or 1)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)

	-- 轻爪击：收招快、伤害低
	self.MeleeDelay = 0.8
	self.MeleeDamage = 43
	self:StartSwinging()
end

-- ==== SecondaryAttack - 右键重爪击 ====
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	-- 与左键共用开火冷却
	if CurTime() < self:GetNextPrimaryFire() then return end

	-- 攻击间隔计算与左键相同，受攻速与"受折磨"强化影响
	local armdelay = owner:GetMeleeSpeedMul() * ((CurTime() < self:GetTormented() + 2) and 0.75 or 1)
	self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay * armdelay)

	-- 重爪击：收招快、伤害低但范围判定更广（调用 StartSwinging(true)）
	self.MeleeDelay = 0.4
	self.MeleeDamage = 21
	self:StartSwinging(true)
end

-- ==== StartSwinging - 开始挥击（secondary 为 true 时是重爪击） ====
function SWEP:StartSwinging(secondary)
	-- 只在本端进行预测执行，避免多端重复
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()
	-- 玩家攻速倍率（决定动画与判定速度）
	local armdelay = owner:GetMeleeSpeedMul()

	-- 动画播放速度与攻速反比，保证动作时长与攻击节奏一致
	self.MeleeAnimationMul = 1 / armdelay
	-- 若设置了动画延迟则延后播放攻击动画，否则立即播放
	if self.MeleeAnimationDelay then
		self.NextAttackAnim = CurTime() + self.MeleeAnimationDelay * armdelay
	else
		self:SendAttackAnim()
	end

	-- 轻爪击触发挥击事件；重爪击直接播放近战姿态动画
	if not secondary then
		self:DoSwingEvent()
	else
		owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
	end

	self:PlayAttackSound(secondary)

	-- 挥击时停止嚎叫音效
	self:StopMoaning()

	-- 若挥击期间冻结移动，则将移速压到最低
	if self.FrozenWhileSwinging then
		self:GetOwner():SetSpeed(1)
	end

	-- 有收招延迟时安排判定时间与提前命中缓存，否则立即结算伤害
	if self.MeleeDelay > 0 then
		self:SetSwingEndTime(CurTime() + self.MeleeDelay * armdelay)

		-- 预判命中：若提前命中非玩家实体，先缓存命中结果
		local trace = owner:CompensatedMeleeTrace(self.MeleeReach, self.MeleeSize)
		if trace.HitNonWorld and not trace.Entity:IsPlayer() then
			trace.IsPreHit = true
			self.PreHit = trace
		end

		self.IdleAnimation = CurTime() + (self:SequenceDuration() + (self.MeleeAnimationDelay or 0)) * armdelay
	else
		self:Swung()
	end
end

-- ==== PlayAttackSound - 播放挥击音效（左右键音效不同） ====
function SWEP:PlayAttackSound(secondary)
	if secondary then
		-- 重爪击：僵尸苏醒声 + 蚁狮攻击声（高频）
		self:EmitSound("npc/fast_zombie/wake1.wav", 75, 125, 0.75)
		self:EmitSound("npc/antlion/attack_single2.wav", 75, 215, 0.75, CHAN_AUTO)
	else
		-- 轻爪击：沿用基类音效
		BaseClass.PlayAttackSound(self)
	end
end

-- ==== PlayHitSound - 播放命中音效（按伤害大小区分音效） ====
function SWEP:PlayHitSound()
	-- 高伤害（重爪击）播放机器切割声，低伤害（轻爪击）播放僵尸爪击声，均为随机变体
	if self.MeleeDamage > 20 then
		self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 75, 80, nil, CHAN_AUTO)
	else
		self:EmitSound("npc/fast_zombie/claw_strike"..math.random(3)..".wav", 70, 80, nil, CHAN_AUTO)
	end
end
