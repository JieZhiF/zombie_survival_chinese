-- ============================================================================
-- weapon_zs_barrage/shared.lua - 弹幕榴弹发射器（共享）
-- 负责：UMP45 外形的榴弹发射器属性：全自动、每次射击打出 3 发榴弹
-- ============================================================================
-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_barrage")
SWEP.Description = ""..translate.Get("weapon_zs_barrage_description")

-- 基于抛射物武器基础
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势
SWEP.HoldType = "smg"

-- 模型与手臂
SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"
SWEP.UseHands = true

-- 关闭 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 弹匣 4 发、全自动，每次射击打出 3 发榴弹
SWEP.Primary.ClipSize = 4
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "impactmine"
SWEP.Primary.Delay = 0.7
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Damage = 31
SWEP.Primary.NumShots = 3

-- 扩散
SWEP.ConeMax = 8
SWEP.ConeMin = 7.5

-- 移动速度
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级与库存上限
SWEP.Tier = 4
SWEP.MaxStock = 3

-- 强化：射速提升
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.05)

-- ==== EmitFireSound - 开火音效 ====
-- 榴弹发射声 + 直升机投放地雷声叠加
function SWEP:EmitFireSound()
	self:EmitSound("weapons/grenade_launcher1.wav", 70, math.random(118, 124), 0.3)
	self:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav", 70, 100, 0.7, CHAN_AUTO + 20)
end
