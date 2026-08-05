-- ============================================================================
-- weapon_zs_smelter/shared.lua - 熔炼者：发射废料霰弹与燃烧弹的双模式武器
-- 负责：定义主射击（废料霰弹）与副射击（燃烧弹投射物）、装填音效与动画
-- ============================================================================
-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_smelter")
SWEP.Description = ""..translate.Get("weapon_zs_smelter_description")

-- 基于投射物武器母本
SWEP.Base = "weapon_zs_baseproj"

-- 持握姿势：十字弓
SWEP.HoldType = "crossbow"

-- 第一人称与第三人称模型（M3 霰弹枪）
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel = "models/weapons/w_shot_m3super90.mdl"

-- 不使用玩家手部模型
SWEP.UseHands = false

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 开火音效；射击间隔 1.25 秒，全自动；单发伤害 20.5，每次 7 颗弹丸（霰弹）
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
SWEP.Primary.Delay = 1.25
SWEP.Primary.Automatic = true
SWEP.Primary.Damage = 20.5
SWEP.Primary.NumShots = 7

-- 弹匣 6 发，使用废料（scrap）弹药，默认携带 15 发
SWEP.Primary.ClipSize = 6
SWEP.Primary.Ammo = "scrap"
SWEP.Primary.DefaultClip = 15

-- 后坐力强度
SWEP.Recoil = 7

-- 持枪移动速度：极慢
SWEP.WalkSpeed = SPEED_SLOWEST

-- 武器等级与商店最大库存
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 扩散范围（未瞄准最大 / 瞄准最小）
SWEP.ConeMax = 6.5
SWEP.ConeMin = 5.75

-- 装填速度倍率
SWEP.ReloadSpeed = 0.45

-- 附加射击间隔强化模组（每级 -0.05 秒）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.05)

-- ==== EmitReloadSound - 播放装填音效（拉栓 + 拍机匣），仅首次预测时播放 ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/g3sg1/g3sg1_slide.wav", 75, 45, 1, CHAN_WEAPON + 23)
		self:EmitSound("weapons/ump45/ump45_boltslap.wav", 70, 47, 0.85, CHAN_WEAPON + 24)
	end
end

-- ==== EmitReloadFinishSound - 播放装填完成音效，仅首次预测时播放 ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/galil/galil_boltpull.wav", 70, 110)
		self:EmitSound("weapons/zs_flak/load1.wav", 75, 100, 0.85, CHAN_WEAPON + 20)
	end
end

-- ==== SendReloadAnimation - 换弹时播放拔出（上膛）动画 ====
function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== SendWeaponAnimation - 射击动画：慢速开火 → 0.4 秒后快速复位，0.55 秒后播放上膛声 ====
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed * 0.25)

	timer.Simple(0.4, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_VM_DRAW)
			self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed * 10.5)
		end
	end)

	-- 本地玩家且弹匣还有弹时播放装弹音
	timer.Simple(0.55, function()
		if IsValid(self) and self:GetOwner() == MySelf and self:Clip1() > 0 then
			self:EmitSound("weapons/zs_flak/load1.wav", 75, 100, 0.85, CHAN_WEAPON + 20)
		end
	end)
end

-- ==== EmitFireSound - 播放开火音效：主射击（金属碰撞）与副射击（发射爆鸣）用不同音效 ====
function SWEP:EmitFireSound(secondary)
	self:EmitSound(secondary and "weapons/stinger_fire1.wav" or "doors/door_metal_thin_close2.wav", 75, secondary and 250 or 70, 0.65)
	self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, secondary and 105 or 115, 0.55, CHAN_WEAPON + 20)
	self:EmitSound("weapons/zs_flak/shot1.wav", 70, secondary and 65 or 100, 0.65, CHAN_WEAPON + 21)
end

-- ==== SetLastFired - 记录最近开火时间（DT 浮点字段 8） ====
function SWEP:SetLastFired(float)
	self:SetDTFloat(8, float)
end

-- ==== GetLastFired - 读取最近开火时间 ====
function SWEP:GetLastFired()
	return self:GetDTFloat(8)
end

-- ==== PrimaryAttack - 主射击：标准霰弹开火 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:SetLastFired(CurTime())

	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== SecondaryAttack - 副射击：消耗 2 发弹药发射燃烧弹（flakbomb），冷却更长、扩散减半 ====
function SWEP:SecondaryAttack()
	if self:Clip1() <= 1 or not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * 1.2)
	self:SetLastFired(CurTime())

	self:EmitFireSound(true)
	self:TakeAmmo(); self:TakeAmmo()

	-- 临时切换为燃烧弹投射物（速度 1000），发射后再切回普通废料弹（速度 1500）
	self.Primary.Projectile = "projectile_flakbomb"
	self.Primary.ProjVelocity = 1000

	self:ShootBullets(self.Primary.Damage, 1, self:GetCone()/2)

	self.Primary.Projectile = "projectile_flak"
	self.Primary.ProjVelocity = 1500

	self.IdleAnimation = CurTime() + self:SequenceDuration()
end
