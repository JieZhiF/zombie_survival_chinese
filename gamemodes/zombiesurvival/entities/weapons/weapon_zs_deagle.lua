AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_deagle")
SWEP.Description = ""..translate.Get("weapon_zs_deagle_description") --SWEP.Description = ""..translate.Get("weapon_zs_deagle_description")s power decreases by half which each zombie it hits."

SWEP.SlotPos = 0

if CLIENT then
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
SWEP.WeaponType = "pistol"
	SWEP.SlotGroup = WEPSELECT_PISTOL
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 55

	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	SWEP.IronSightsPos = Vector(-6.35, 5, 1.7)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "revolver"

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
SWEP.Primary.Damage = 57
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.32
SWEP.Primary.KnockbackScale = 2

SWEP.Primary.ClipSize = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 3
SWEP.ConeMin = 0.4
SWEP.ConeRamp = 2
SWEP.FireAnimSpeed = 1.3

SWEP.Tier = 3
SWEP.Recoil_Enabled             = true
-- 热度曲线 (半自动手枪: 快速冷却, 低热度累积)
SWEP.RecoilPerShot      = 2.5   -- 每发热度 (单发大威力)
SWEP.RecoilMax          = 3     -- 低热度上限 (半自动几乎不连射)
SWEP.RecoilResetTime    = 0.05  -- 快速冷却
SWEP.RecoilDissipationRate = 25 -- 高消散速度
SWEP.RecoilModifierCap  = 1.05  -- 几乎不递增

-- 后坐力曲线
SWEP.RecoilFirstShotMult = 1.0  -- 单发武器无首发区别
SWEP.RecoilSideBias     = 0.1   -- 轻微右偏
SWEP.ConeRamp = 2

-- 单发后坐力 (ViewAngles) - 大威力手枪
SWEP.RecoilUp           = 0.4    -- 强垂直上跳
SWEP.RecoilSide         = 0.08  -- 水平偏转
SWEP.RecoilRandomUp     = 0.06  -- 垂直随机
SWEP.RecoilRandomSide   = 0.04  -- 水平随机

-- 限制与自动控制
SWEP.RecoilMaxTotalUp   = 45
SWEP.RecoilAutoControl  = 5     -- 轻度回正
SWEP.RecoilAutoControlTime = 0.04
SWEP.RecoilAutoControl_PerShot = 0.05
SWEP.RecoilAutoControl_DontTryToReturnBack = false

-- ==========================================
-- [配置] 2. 镜头效果 (大威力手枪 - 强烈震动)
-- ==========================================
SWEP.CamRecoilFOV       = 2.0    -- 强烈的FOV冲击
SWEP.CamRecoilFOVStiffness = 180
SWEP.CamRecoilFOVDamping = 8
SWEP.CamRecoilUp        = 0.03   -- 明显的镜头弹跳
SWEP.CamRecoilSide      = 0.012
SWEP.CamRecoilRoll      = 0.025  -- 明显的屏幕倾斜
SWEP.CamRecoilLerpSpeed = 28

-- ==========================================
-- [配置] 3. 枪模视觉效果 (强烈后撞感)
-- ==========================================
SWEP.UseVisualRecoil    = true
SWEP.CustomSightsAttackAnim = false
SWEP.VisualRecoilUp     = -2.0   -- 较大的枪模上跳
SWEP.VisualRecoilPunch  = 2.2    -- 强烈后撞
SWEP.VisualRecoilRoll   = 3.0    -- 枪模滚转
SWEP.VisualRecoilStiffness = 200
SWEP.VisualRecoilDamping   = 18
SWEP.VisualRecoilCenter = Vector(0, 0, 0)

-- ==========================================
-- [配置] 4. 姿态倍率 (Multipliers)
-- ==========================================
SWEP.RecoilMultSights   = 0.7    -- 瞄准时
SWEP.RecoilMultCrouch   = 0.75   -- 蹲下时
SWEP.RecoilMultMidAir   = 2.0    -- 空中时
SWEP.RecoilMultMove     = 1.3    -- 移动时

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 2)
