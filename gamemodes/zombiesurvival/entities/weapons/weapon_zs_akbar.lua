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
SWEP.Primary.Delay = 0.08

SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"

GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.ConeMax = 2.65
SWEP.ConeMin = 1.275

SWEP.WalkSpeed = SPEED_SLOW

SWEP.Tier = 3

SWEP.IronSightsPos = Vector(-6.6, 20, 3.1)

-- =============================================================================
-- ARC9 + ZS 核心后坐力配置文件 (参数化)
-- =============================================================================
SWEP.Recoil_Enabled             = true

-- [1. 物理弹道: 影响准星实际落点]

-- 后坐力系统 (Recoil)
SWEP.Recoil_Enabled = true -- 设为 true 来为武器启用此系统
--SWEP.Recoil = 0
SWEP.RecoilUp = 0.4 -- 基础垂直后坐力
SWEP.RecoilSide = 0.2  -- 基础水平后坐力 (随机范围)
SWEP.RecoilRandomUp = 0.2  -- 垂直后坐力随机范围    
SWEP.RecoilRandomSide = 0.2  -- 水平后坐力随机范围
SWEP.RecoilAutoControl = 1  -- 自动压枪控制 (越高越稳)
SWEP.RecoilResetTime = 0.12   -- 停火后多久重置后坐力计数
SWEP.RecoilDissipationRate = 1 -- 连续射击时后坐力增加的速度
SWEP.RecoilRecoveryPercentage = 0.6 -- 连续射击后恢复到原始位置的百分比

-- 视觉后坐力 (镜头与模型)
SWEP.CamRecoilUp = 0 -- 镜头垂直后坐力
SWEP.CamRecoilSide = 0 -- 镜头水平后坐力
SWEP.CamRecoilRoll = 0 -- 镜头滚转后坐力
SWEP.CamRecoilPunch = 0 -- 镜头后坐力冲击感
SWEP.CamRecoilFOV = 0   -- 镜头FOV后坐力

---枪模视觉效果: 影响武器模型动作
SWEP.CustomSightsAttackAnim = true --是否启用模拟开镜开火动画，对于默认开火动画不是很适合开镜射击和没有开镜开火的武器非常有用	
SWEP.VisualRecoilPunch = 1 -- 视觉后坐力冲击感 (弹簧效果强度)
SWEP.VisualRecoilUp = 0 -- 视觉后坐力垂直位移
SWEP.VisualRecoilRoll = 0 -- 视觉后坐力滚转
SWEP.VisualRecoilStiffness = 80 -- 视觉后坐力弹簧刚度 (越高越“硬”)
SWEP.VisualRecoilDamping = 10 -- 视觉后坐力弹簧阻尼 (越高越快衰减)

-- 状态倍率
SWEP.RecoilMultSights = 0.5 -- 瞄准时后坐力倍率
SWEP.RecoilMultCrouch = 0.75 -- 蹲下时后坐力倍率
SWEP.RecoilMultMidAir = 2.0 -- 半空中时后坐力倍率
SWEP.RecoilMultMove = 1.3 -- 移动时后坐力倍率


GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.344)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.172)
