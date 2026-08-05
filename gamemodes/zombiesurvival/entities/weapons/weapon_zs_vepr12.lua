-- ============================================================================
-- weapon_zs_vepr12.lua - VEPR-12 全自动霰弹枪
-- 负责：定义霰弹枪属性（七弹丸散射）、弹药与武器栏位
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_vepr12")
-- 武器商店描述
SWEP.Description = "一柱擎天！."

-- 武器栏内的位置
SWEP.SlotPos = 0

-- 客户端专属配置块
if CLIENT then
	-- 武器栏位：霰弹枪栏
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	-- 视图模型不镜像翻转
	SWEP.ViewModelFlip = false
	-- 第一人称视野角度
	SWEP.ViewModelFOV = 60

	-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置与缩放
	SWEP.HUD3DBone = "v_weapon.galil"
	SWEP.HUD3DPos = Vector(1, 0, 6)
	SWEP.HUD3DScale = 0.015
end

-- 继承的武器基类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（霰弹枪）
SWEP.HoldType = "shotgun"

-- 视图模型与世界模型文件
SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 开火音效
SWEP.Primary.Sound = Sound("Weapon_Galil.Single")
-- 单颗弹丸伤害
SWEP.Primary.Damage = 14
-- 每次射击的弹丸数
SWEP.Primary.NumShots = 7
-- 射击间隔
SWEP.Primary.Delay = 0.17

-- 弹匣容量 10 发
SWEP.Primary.ClipSize = 10
-- 全自动射击
SWEP.Primary.Automatic = true
-- 使用的弹药类型（霰弹）
SWEP.Primary.Ammo = "buckshot"
-- 按幸存模式规则计算初始备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 最大/最小准星扩散（移动中/静止时）
SWEP.ConeMax = 3
SWEP.ConeMin = 2

-- 换弹速度倍率
SWEP.ReloadSpeed = 1.75

-- 移动速度：非常缓慢（重型霰弹枪）
SWEP.WalkSpeed = SPEED_SLOWER

-- 武器等级（Tier 5）
SWEP.Tier = 5


-- 强化修饰器：降低最大扩散
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.603, 1)

-- ==== SecondaryAttack - 禁用右键功能（空实现） ====
function SWEP:SecondaryAttack()
end
