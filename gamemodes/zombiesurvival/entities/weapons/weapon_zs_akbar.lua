AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_akbar")
SWEP.Description = ""..translate.Get("weapon_zs_akbar_description")


SWEP.SlotPos = 0

if CLIENT then
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
	SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "v_weapon.AK47_Parent"
	SWEP.HUD3DPos = Vector(-1, -4.5, -4)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true

SWEP.ReloadSound = Sound("Weapon_AK47.Clipout")
SWEP.Primary.Sound = Sound("Weapon_AK47.Single")
SWEP.Primary.Damage = 21.75
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"

GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.65
SWEP.ConeMin = 1.275

SWEP.WalkSpeed = SPEED_SLOW

SWEP.Tier = 3

SWEP.IronSightsPos = Vector(-6.6, 20, 3.1)

-- ==========================================
-- [配置] 1. 核心后坐力参数 (COD风格AK - 上扬偏右, 渐进扩散)
-- ==========================================
SWEP.Recoil_Enabled             = true
-- 热度曲线系统
SWEP.RecoilPerShot      = 0.6   -- 每发子弹增加的热度
SWEP.RecoilMax          = 10    -- 热度上限
SWEP.RecoilResetTime    = 0.08  -- 停火后多久开始冷却
SWEP.RecoilDissipationRate = 18 -- 热度消散速度
SWEP.RecoilModifierCap  = 1.35  -- 满热度时后坐力倍率上限

-- 后坐力曲线
SWEP.RecoilFirstShotMult = 1.15 -- 首发稍微大一些
SWEP.RecoilSideBias     = 0.4   -- 稍偏右 (AK经典右偏)
SWEP.ConeRamp = 2

-- 单发后坐力 (ViewAngles)
SWEP.RecoilUp           = 0.17   -- 基础垂直上跳
SWEP.RecoilSide         = 0.09  -- 基础水平偏转
SWEP.RecoilRandomUp     = 0.05  -- 垂直随机波动
SWEP.RecoilRandomSide   = 0.03  -- 水平随机波动

-- 限制与自动控制
SWEP.RecoilMaxTotalUp   = 50
SWEP.RecoilAutoControl  = 3     -- 轻度自动回正 (COD靠玩家手动压枪)
SWEP.RecoilAutoControlTime = 0.06
SWEP.RecoilAutoControl_PerShot = 0.08
SWEP.RecoilAutoControl_DontTryToReturnBack = false

-- ==========================================
-- [配置] 2. 镜头效果 (COD风格 - 明显的屏幕震动)
-- ==========================================
SWEP.CamRecoilFOV       = 1.3    -- FOV冲击感
SWEP.CamRecoilFOVStiffness = 220
SWEP.CamRecoilFOVDamping = 10
SWEP.CamRecoilUp        = 0.018  -- 镜头上跳 (屏幕视角弹跳)
SWEP.CamRecoilSide      = 0.01   -- 镜头侧偏
SWEP.CamRecoilRoll      = 0.015  -- 屏幕倾斜 (COD特色)
SWEP.CamRecoilLerpSpeed = 24

-- ==========================================
-- [配置] 3. 枪模视觉效果
-- ==========================================
SWEP.UseVisualRecoil    = true
SWEP.CustomSightsAttackAnim = false
SWEP.VisualRecoilUp     = -1.5   -- 枪模垂直位移
SWEP.VisualRecoilPunch  = 1.6    -- 枪模后撞力度
SWEP.VisualRecoilRoll   = 2.2    -- 枪模滚转
SWEP.VisualRecoilStiffness = 220
SWEP.VisualRecoilDamping   = 22
SWEP.VisualRecoilCenter = Vector(0, 0, 0)

-- ==========================================
-- [配置] 4. 姿态倍率
-- ==========================================
SWEP.RecoilMultSights   = 0.5    -- 瞄准时减半
SWEP.RecoilMultCrouch   = 0.7    -- 蹲下时
SWEP.RecoilMultMidAir   = 2.0    -- 空中
SWEP.RecoilMultMove     = 1.3    -- 移动时
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.344)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.172)
