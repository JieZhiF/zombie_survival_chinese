-- ============================================================================
-- weapon_zs_ender.lua - 终结者霰弹枪（Ender）
-- 负责：定义霰弹枪属性（8 弹丸散射）、弹匣式霰弹机制与单发重型改造分支
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_ender")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_ender_description")


-- 武器选择槽内位置 0
SWEP.SlotPos = 0

if CLIENT then
	-- 武器槽位：霰弹枪类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	-- 武器选择分组：霰弹枪
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	-- 不翻转第一人称模型
	SWEP.ViewModelFlip = false
	-- 第一人称镜头视野
	SWEP.ViewModelFOV = 60

	-- HUD 3D 模型挂点：枪身骨骼
	SWEP.HUD3DBone = "v_weapon.galil"
	-- HUD 3D 模型偏移位置
	SWEP.HUD3DPos = Vector(1, 0, 6)
	-- HUD 3D 模型缩放
	SWEP.HUD3DScale = 0.015
end

-- 母本：基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：霰弹枪
SWEP.HoldType = "shotgun"

-- 第一人称模型（Galil 步枪模型改造为霰弹枪外观）
SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 开火音效（Galil 单发音）
SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
-- 单颗弹丸伤害
SWEP.Primary.Damage = 9.5
-- 每次开火射出 8 颗弹丸（霰弹散射）
SWEP.Primary.NumShots = 8
-- 射击间隔 0.4 秒
SWEP.Primary.Delay = 0.4

-- 弹匣容量 8 发（弹匣式霰弹枪）
SWEP.Primary.ClipSize = 8
-- 自动开火
SWEP.Primary.Automatic = true
-- 消耗鹿弹弹药
SWEP.Primary.Ammo = "buckshot"
-- 按游戏模式规则设置默认弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 最大扩散
SWEP.ConeMax = 5.625
-- 最小扩散
SWEP.ConeMin = 4.875

-- 移动速度：较慢
SWEP.WalkSpeed = SPEED_SLOWER

-- 武器等级 3
SWEP.Tier = 3

-- 附加武器强化修改器：最大扩散 -0.603
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)
-- 附加武器强化修改器：最小扩散 -0.51
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.51, 1)
-- 改造分支 1：重型独头弹——改为单发大威力（伤害 x5.5）、散布极低
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_ender_r1"), ""..translate.Get("weapon_zs_ender_r1_description"), function(wept)
	-- 单发伤害提升至 5.5 倍
	wept.Primary.Damage = wept.Primary.Damage * 5.5
	-- 改为单发独头弹
	wept.Primary.NumShots = 1
	-- 散布大幅降低（精确打击）
	wept.ConeMin = wept.ConeMin * 0.15
	wept.ConeMax = wept.ConeMax * 0.3
end)

-- ==== SecondaryAttack - 禁用右键开火 ====
function SWEP:SecondaryAttack()
end
