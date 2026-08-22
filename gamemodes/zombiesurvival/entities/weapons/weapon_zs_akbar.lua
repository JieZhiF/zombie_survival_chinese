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
---------------- [后坐力系统] ----------------
SWEP.Recoil_Enabled = true -- 设为 true 来为武器启用此系统
SWEP.Recoil = 0
SWEP.RecoilUp = 0.4 -- 基础垂直后坐力
SWEP.RecoilSide = 0.2  -- 基础水平后坐力
SWEP.RecoilRandomUp = 0.2  -- 垂直后坐力随机范围    
SWEP.RecoilRandomSide = 0.2  -- 水平后坐力随机范围
SWEP.RecoilAutoControl = 1  -- 自动回正速度 (越高越稳)
SWEP.RecoilAutoControlTime = 0.08 -- 停火后多少秒开始回正
SWEP.RecoilAutoControl_DontTryToReturnBack = false
SWEP.RecoilResetTime = 0.12   -- 停火后多久重置后坐力计数
SWEP.RecoilDissipationRate = 1 -- 连续射击时后坐力增加的速度
SWEP.RecoilRecoveryPercentage = 0.6 -- 连续射击后恢复到原始位置的百分比

-- 后坐力曲线系统（渐进式递增）
SWEP.RecoilFirstShotMult = 1.0 -- 首发后坐力倍率（第一发通常较大）
SWEP.RecoilSideBias = 0 -- 水平偏移倾向 (-1到1, 负=偏左, 正=偏右, 0=随机)
SWEP.RecoilPerShot = 1 -- 每发子弹增加的热度
SWEP.RecoilMax = 6 -- 热度上限
SWEP.RecoilModifierCap = 1.2 -- 满热度时的后坐力倍率上限
SWEP.RecoilMaxTotalUp = 45 -- [实际轨] 弹道垂直爬升累积上限(度)

-- ====== [双轨分离·实际轨] ARC9 移植参数（累积量经 cl_recoil_handler 渐进注入视角） ======
SWEP.RecoilPatternDrift = 0.35 -- 连射方向图案逐发漂移幅度(度)，越大水平走位越飘
SWEP.RecoilAccumScale = 1      -- 累积量总乘数（服务器平衡旋钮，不影响视觉层）
SWEP.RecoilRiseSpeed = 25      -- 视角上抬速率乘数（ARC9 的 m=25），越大抬头越猛
SWEP.RecoilTimeStep = 0.02     -- 注入采样步长(秒)，越小上抬越平滑

-- 视觉后坐力 (镜头与模型)
SWEP.CamRecoilUp = 0.015 -- 镜头垂直后坐力 (屏幕视角弹跳)
SWEP.CamRecoilSide = 0.008 -- 镜头水平后坐力
SWEP.CamRecoilRoll = 0.01 -- 镜头滚转后坐力 (射击时屏幕倾斜)
SWEP.CamRecoilFOV = 1.2   -- 镜头FOV后坐力 (射击时FOV微变化)
SWEP.CamRecoilFOVStiffness = 200 -- FOV弹簧刚度
SWEP.CamRecoilFOVDamping = 12 -- FOV弹簧阻尼
SWEP.CamRecoilLerpSpeed = 22 -- 镜头回正速度
SWEP.CamRecoilADSMult = 2.0 --开镜时镜头后坐力增强倍率（随开镜进度线性生效；枪模侧比例由 *HipFire 双参数组承担）

---枪模视觉效果（ARC9 式双参数组：* 为开镜组，配对 *HipFire 另定义腰射组，注入时按开镜进度插值）
SWEP.CustomSightsAttackAnim = true --是否启用模拟开镜开火动画
SWEP.UseVisualRecoil = true -- 启用枪模物理后坐力
SWEP.VisualRecoilPunch = 1.5 -- [开镜组] 枪模后坐冲击感
SWEP.VisualRecoilUp = -1.8 -- [开镜组] 枪模垂直位移
SWEP.VisualRecoilRoll = 2.5 -- [开镜组] 枪模滚转
SWEP.VisualRecoilStiffness = 200 -- 弹簧刚度 (越高越"硬")
SWEP.VisualRecoilDamping = 20 -- 弹簧阻尼 (越高越快衰减)
SWEP.VisualRecoilCenter = Vector(0, 0, 0)


GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.344)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.172)
