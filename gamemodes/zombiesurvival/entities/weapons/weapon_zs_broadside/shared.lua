-- ============================================================================
-- weapon_zs_broadside/shared.lua - 舷侧火箭炮（共享）
-- 负责：定义舷侧火箭炮的基本属性与发射逻辑，发射可遥控引爆的火箭弹；
--       包含一个改造分支（全自动连发模式）
-- ============================================================================
-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_broadside")
-- 武器描述文本（本地化键）
SWEP.Description = ""..translate.Get("weapon_zs_broadside_description")

-- 不使用 C 模型手部
SWEP.UseHands = false

-- 隐藏第一人称和世界模型（使用 SCK 元素自定义外观）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 继承投射物武器基类
SWEP.Base = "weapon_zs_baseproj"
-- 武器类型：爆炸物
SWEP.WeaponType = "explosive"
-- 持握姿势：RPG
SWEP.HoldType = "rpg"

-- 第一人称/世界模型
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

-- 主攻击设置：延迟、弹匣容量、非全自动、弹药类型、默认弹药、伤害
SWEP.Primary.Delay = 1.2
SWEP.Primary.ClipSize = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "impactmine"
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Damage = 107

-- 换弹音效与开火音效
SWEP.ReloadSound = Sound("vehicles/tank_readyfire1.wav")
SWEP.Primary.Sound = Sound("weapons/stinger_fire1.wav")

-- 换弹速度倍率与后坐力
SWEP.ReloadSpeed = 0.55
SWEP.Recoil = 3

-- 准星扩散（火箭炮精度极高，几乎无扩散）
SWEP.ConeMin = 0.0001
SWEP.ConeMax = 0.0001

-- 开火与换弹手势动画
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_RPG

-- 持有时的移动速度（极慢）
SWEP.WalkSpeed = SPEED_SLOWEST * 0.85

-- 开火动画播放速度
SWEP.FireAnimSpeed = 0.75

-- 武器等级与最大库存
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 武器修饰符：弹匣容量+1（每级1点）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)

-- 改造分支1：全自动连发模式（大幅降低延迟和伤害，改为自动射击）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_broadside_r1"), ""..translate.Get("weapon_zs_broadside_r1_description"), function(wept)
	-- 攻击延迟降至原来的24%
	wept.Primary.Delay = wept.Primary.Delay * 0.24
	-- 改为全自动
	wept.Primary.Automatic = true
	-- 无后坐力
	wept.Recoil = 0
	-- 伤害降至原来的30%
	wept.Primary.Damage = wept.Primary.Damage * 0.3
	-- 开火动画速度提升
	wept.FireAnimSpeed = 1.1

	-- 覆盖开火音效（高频连发音）
	wept.EmitFireSound = function(self)
		self:EmitSound(self.Primary.Sound, 75, math.random(218, 223), 0.6)
		self:EmitSound("weapons/grenade_launcher1.wav", 75, math.random(126, 132), 0.5, CHAN_WEAPON + 20)
	end
	-- 覆盖投射物修改：标记为遥控火箭，设置锥形爆炸参数
	wept.EntModify = function(self, ent)
		ent:SetDTBool(0, true)
		ent.ProjTaper = self.Primary.ProjExplosionTaper

		local owner = self:GetOwner()
		-- 记录遥控火箭引用到持有者
		owner.RemoteDetRocket = ent

		self:SetNextSecondaryFire(CurTime() + 0.2)
	end

	-- 覆盖主攻击：使用弹药计数循环（3发一轮）
	wept.PrimaryAttack = function(self)
		if not self:CanPrimaryAttack() then return end
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:EmitFireSound()

		-- 获取副攻击计数器（用于3发循环）
		local altuse = self:GetDTInt(10)
		if altuse == 0 then
			self:TakeAmmo()
		end
		-- 计数器循环递减（0→2→1→0）
		self:SetDTInt(10, (altuse - 1) % 3)

		self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end

	-- 连发模式下准星扩散增大
	wept.ConeMax = 3
	wept.ConeMin = 1.5
end)


-- ==== EmitFireSound - 发射音效 ====
function SWEP:EmitFireSound()
	-- 播放主开火音效（随机音调）和榴弹发射器音效
	self:EmitSound(self.Primary.Sound, 80, math.random(118, 123), 0.8)
	self:EmitSound("weapons/grenade_launcher1.wav", 80, math.random(76, 82), 0.7, CHAN_WEAPON + 20)
end
