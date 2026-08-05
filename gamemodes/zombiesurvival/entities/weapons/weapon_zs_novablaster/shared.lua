-- ============================================================================
-- weapon_zs_novablaster/shared.lua - 脉冲手枪「新星爆破」（Nova Blaster）共享端
-- 负责：定义脉冲手枪基础属性、改造分支（散射模式）与开火音效
-- ============================================================================

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_novablaster")
SWEP.Description = ""..translate.Get("weapon_zs_novablaster_description")

-- 继承投射物武器基础模板（weapon_zs_baseproj）
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势（左轮手枪姿势）
SWEP.HoldType = "revolver"

-- 第一人称与第三人称模型（马格南左轮），隐藏官方模型改用 SCK 外观，使用玩家手部
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 左键开火：单发伤害 46、每次 1 发、0.65 秒射击间隔
SWEP.Primary.Sound = Sound("Weapon_357.Single")
SWEP.Primary.Delay = 0.65
SWEP.Primary.Damage = 46
SWEP.Primary.NumShots = 1

-- 弹匣 27 发、半自动、消耗脉冲弹药（备弹 27 发）
SWEP.Primary.ClipSize = 27
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pulse"
SWEP.WeaponType = "pulse"
SWEP.Primary.DefaultClip = 27

-- 射击所需的最低弹匣弹数（少于 3 发不可开火）
SWEP.RequiredClip = 3

-- 扩散范围（最大/最小准星扩散）
SWEP.ConeMax = 3.5
SWEP.ConeMin = 1.75

-- 持枪移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOW

-- 机瞄时视角偏移位置与角度
SWEP.IronSightsPos = Vector(-4.65, 4, 0.25)
SWEP.IronSightsAng = Vector(0, 0, 1)

-- 武器等级 2
SWEP.Tier = 2

-- 附加武器改造（多槽位）：最大扩散 -0.7、最小扩散 -0.4、开火间隔 -0.05 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.7, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.4, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.05, 1)
-- 改造分支 1「散射模式」：降低伤害并改为多发投射物，投射物标记为分支形态
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_novablaster_r1"), ""..translate.Get("weapon_zs_novablaster_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.6
	wept.Primary.ProjVelocity = 450
	wept.Primary.NumShots = 2
	wept.Primary.ClipSize = 18
	wept.SameSpread = true
	-- 服务器端：生成的投射物标记为分支形态（实体显示与碰撞行为不同）
	if SERVER then
		wept.EntModify = function(self, ent)
			ent:SetDTBool(0, true)
			ent.Branch = true
		end
	end
end)

-- ==== EmitFireSound - 播放开火音效（电击发射声 + 能量投射声） ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/stunstick/alyx_stunner2.wav", 72, 219, 0.75)
	self:EmitSound("weapons/physcannon/superphys_launch1.wav", 72, 208, 0.65, CHAN_AUTO)
end
