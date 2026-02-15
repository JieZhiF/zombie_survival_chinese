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

SWEP.Recoil_Enabled             = true
SWEP.Recoil_Enabled = true

-- ==========================================
-- [配置] 1. 核心后坐力参数 (物理弹道/准星移动)
-- ==========================================
-- 基础数值
SWEP.RecoilPerShot      = 1   -- [热度] 每一发子弹增加的"后坐力热度" (Heat)
SWEP.RecoilMax          = 12    -- [热度] 热度上限 (超过此值后，后坐力不再因连射而增加)
SWEP.RecoilResetTime    = 0.09  -- [重置] 停火多少秒后，热度开始消散 (ARC9通常很短，0.05-0.1)
SWEP.RecoilDissipationRate = 15 -- [重置] 热度消散速度 (值越大，停火后准星回复越快)

-- 动态倍率 (根据热度调整后坐力)
SWEP.RecoilModifierCap  = 0.95   -- [倍率] 最大热度时的后坐力倍率 (1.2 = 满热度时后坐力是第一发的1.2倍)

-- 单发后坐力 (ViewAngles 变化)
SWEP.RecoilUp           = 0.3   -- [垂直] 基础枪口上跳角度
SWEP.RecoilSide         = 0.15  -- [水平] 基础左右偏转幅度
SWEP.RecoilRandomUp     = 0.04  -- [随机] 垂直上跳的随机波动量 (+/-)
SWEP.RecoilRandomSide   = 0.02  -- [随机] 水平偏转的随机波动量 (+/-)

-- 限制与自动控制
SWEP.RecoilMaxTotalUp   = 45    -- [上限] 枪口最大抬升角度 (防上天，原值999或5都不合理，45度通常是极限)
SWEP.RecoilAutoControl  = 15    --自动回正速度
SWEP.RecoilAutoControlTime = 0.1 --停火后多少秒开始回正
SWEP.RecoilAutoControl_PerShot = 0.24 -- 每发子弹增加的自动回正速度 (让连射时更稳)
SWEP.RecoilAutoControl_DontTryToReturnBack = false -- 是否禁用"自动回正" (设为true则像CS，准星不会自动回到原位)

-- ==========================================
-- [配置] 2. 镜头效果 (FOV & Camera)
-- ==========================================
SWEP.CamRecoilFOV       = 1    -- 射击时 FOV 瞬间拉伸的度数
SWEP.CamRecoilFOVStiffness = 300 -- FOV 震动的刚度 (越大回弹越快，越脆)
SWEP.CamRecoilDamping   = 10    -- FOV 震动的阻尼
SWEP.CamRecoilUp        = 0     -- 镜头上跳
SWEP.CamRecoilSide      = 0     -- 镜头侧偏
SWEP.CamRecoilRoll      = 0   -- [重要] 镜头滚转 (ARC9 风格核心，射击时屏幕倾斜)
SWEP.CamRecoilLerpSpeed = 20

-- ==========================================
-- [配置] 3. 枪模视觉效果 (Visual Recoil)
-- ==========================================
SWEP.UseVisualRecoil    = false
SWEP.VisualRecoilUp     = -1.5  -- 枪模垂直位移 (负数通常是向上，取决于骨骼)
SWEP.VisualRecoilPunch  = 1.5   -- 枪模向后撞击力度 (Z轴/后坐力感)
SWEP.VisualRecoilRoll   = 2.0   -- 枪模滚转力度
SWEP.VisualRecoilStiffness = 250 -- [刚度] 弹簧回弹速度 (改大可以减少"飘"的感觉)
SWEP.VisualRecoilDamping   = 25  -- [阻尼] 防止来回晃荡
SWEP.VisualRecoilCenter = Vector(0, 0, 0) -- 旋转中心偏移

-- ==========================================
-- [配置] 4. 姿态倍率 (Multipliers)
-- ==========================================
SWEP.RecoilMultSights   = 0.5   -- 瞄准时
SWEP.RecoilMultCrouch   = 0.75  -- 蹲下时
SWEP.RecoilMultMidAir   = 2.0   -- 空中时
SWEP.RecoilMultMove     = 1.3   -- 移动时
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.344)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.172)
