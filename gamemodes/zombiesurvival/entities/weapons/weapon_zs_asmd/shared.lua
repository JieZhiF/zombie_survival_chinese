-- ============================================================================
-- weapon_zs_asmd/shared.lua - ASMD：脉冲步枪
-- 负责：定义脉冲步枪的射击属性、主/副两种开火模式、自定义射击动画与弹药消耗
-- ============================================================================
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_asmd")


-- 栏位内位置
SWEP.SlotPos = 0

-- 基于武器基础母本
SWEP.Base = "weapon_zs_base"

-- 持握姿势：AR2 步枪
SWEP.HoldType = "ar2"

-- 第一人称（AWP 枪模）与第三人称模型，使用玩家手部模型
SWEP.ViewModel = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"
SWEP.UseHands = true

-- 单发伤害 53.5，每次 1 颗子弹，间隔 0.45 秒
SWEP.Primary.Damage = 53.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.45

-- 弹匣 28 发，半自动，使用脉冲弹药
SWEP.Primary.ClipSize = 28
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pulse"
SWEP.WeaponType = "pulse"
-- 默认携带 25 发
SWEP.Primary.DefaultClip = 25

-- 扩散范围（未瞄准最大 / 瞄准最小）
SWEP.ConeMax = 0.65
SWEP.ConeMin = 0.5

-- 持枪移动速度：慢速
SWEP.WalkSpeed = SPEED_SLOW

-- 附加射击间隔强化模组（每级 -0.03 秒）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.03)

-- 武器等级与 ASMD 类型标记
SWEP.Tier = 5
SWEP.ASMD = true

-- 子弹曳光特效
SWEP.TracerName = "tracer_cosmos"

-- ==== SendWeaponAnimation - 播放慢速主射击动画，0.2 秒后快速播放收起动画形成开火回弹 ====
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed * 0.35)

	timer.Simple(0.2, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_VM_DRAW)
			self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed * 10.5)
		end
	end)
end

-- ==== CanPrimaryAttack - 判定能否开火：持物/拆墙/换弹时禁止，弹匣不足 2 发时干火 ====
function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then return false end

	if self:Clip1() < 2 then
		self:EmitSound(self.DryFireSound)
		self:SetNextPrimaryFire(CurTime() + math.max(0.25, self.Primary.Delay))
		return false
	end

	return self:GetNextPrimaryFire() <= CurTime()
end

-- ==== EmitFireSound - 播放开火音效：主射击与副射击（蓄力）使用不同音效 ====
function SWEP:EmitFireSound(secondary)
	self:EmitSound(secondary and "weapons/zs_asmd/secondary2.wav" or "weapons/zs_asmd/main3.wav", 75, math.random(105, 110))
	self:EmitSound("weapons/zs_inner/innershot.ogg", 72, 231, 0.45, CHAN_AUTO)
end

-- ==== TakeAmmo - 消耗弹药：主射击 2 发，副射击 5 发 ====
function SWEP:TakeAmmo(secondary)
	self:TakePrimaryAmmo(secondary and 5 or 2)
end

-- ==== BulletCallback - 子弹命中回调：改为泛用伤害类型，且不产生冲击效果 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	dmginfo:SetDamageType(DMG_GENERIC)
	return {impact = false}
end

-- ==== SecondaryAttack - 副攻击：蓄力射击，消耗 5 发弹药，更高伤害与更低扩散 ====
function SWEP:SecondaryAttack()
	if self:Clip1() < 5 or not self:CanPrimaryAttack() then return end

	-- 副射击冷却更长（1.35 倍），伤害 1.67 倍，扩散降至 1/3
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * 1.35)
	self:EmitFireSound(true)
	self:TakeAmmo(true)

	if SERVER then
		self:ShootSecondary(self.Primary.Damage * 1.67, 1, self:GetCone()/3)
	end

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end
