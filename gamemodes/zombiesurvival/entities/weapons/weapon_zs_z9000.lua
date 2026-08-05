-- ============================================================================
-- weapon_zs_z9000.lua - 脉冲手枪「Z9000」
-- 负责：定义脉冲手枪的武器属性、弹道回调（腿部减速与脉冲命中特效）
-- ============================================================================

AddCSLuaFile()

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_z9000")
SWEP.Description = ""..translate.Get("weapon_zs_z9000_description")

-- 武器在武器选择栏中的槽位序号
SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 第一人称视角设置：不翻转、FOV 60
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- 3D HUD 中展示武器模型的绑定骨骼与位置/缩放
	SWEP.HUD3DBone = "ValveBiped.square"
	SWEP.HUD3DPos = Vector(1.1, 0.25, -2)
	SWEP.HUD3DScale = 0.015

	-- 隐藏第一人称视图模型（改用 SCK 自定义模型元素）
	SWEP.ShowViewModel = false

	-- SCK 元素：以 Alyx 枪模型作为手持外观
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/weapons/w_alyx_gun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(7, 2, -4.092), angle = Angle(170, 10, 10), size = Vector(1.1, 1.1, 1.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承基础武器模板
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（手枪姿势）
SWEP.HoldType = "pistol"

-- 第一人称与第三人称模型，使用玩家的手部模型
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_alyx_gun.mdl"
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 换弹与开火音效
SWEP.ReloadSound = Sound("weapons/alyx_gun/alyx_shotgun_cock1.wav")
SWEP.Primary.Sound = Sound("weapons/alyx_gun/alyx_gun_fire3.wav")
-- 左键开火：单发伤害 14.5、每次 1 发、0.2 秒射击间隔
SWEP.Primary.Damage = 14.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2

-- 弹匣 10 发、半自动、消耗脉冲弹药（备弹 50 发）
SWEP.Primary.ClipSize = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pulse"
SWEP.WeaponType = "pulse"
SWEP.Primary.DefaultClip = 50

-- 扩散范围（最大/最小准星扩散）
SWEP.ConeMax = 2
SWEP.ConeMin = 1.5

-- 机瞄时视角偏移位置与角度
SWEP.IronSightsPos = Vector(-5.95, 3, 2.75)
SWEP.IronSightsAng = Vector(-0.15, -1, 2)

-- 子弹曳光效果类型
SWEP.TracerName = "AR2Tracer"

-- 附加武器改造：最大扩散 -0.25、开火间隔 -0.0175 秒（多开火间隔槽位）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.25)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.0175, 1)

-- 脉冲武器击杀/命中得分倍率
SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

-- ==== BulletCallback - 命中回调：对僵尸附加腿部减速与脉冲命中特效 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	-- 命中僵尸时附加 4.5 腿部伤害（脉冲减速效果）
	if ent:IsValidZombie() then
		ent:AddLegDamageExt(4.5, attacker, attacker:GetActiveWeapon(), SLOWTYPE_PULSE)
	end

	-- 本地预测时生成脉冲命中特效
	if IsFirstTimePredicted() then
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)
	end
end
