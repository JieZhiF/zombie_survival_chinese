-- shared.lua

---------------- [武器基本属性] ----------------
--SWEP.Base = "weapon_base"
SWEP.PrintName = ""..translate.Get("weapon_zs_base")
SWEP.Description = "武器母本"
SWEP.DrawAmmo = true                      -- 是否绘制游戏默认的弹药 HUD。
SWEP.DrawCrosshair = false                -- 是否绘制准星。
SWEP.Slot = 0                             -- 武器在武器选择栏中的位置（0 - 5 对应我们在游戏中的1-6号位置）
SWEP.Weight = 5 --武器的权重，权重越高在对应栏位的位置就越靠上
SWEP.Tier = 1 --武器的等级
SWEP.WalkSpeed = 190 --拿着武器的速度
SWEP.HoldType = "pistol" --拿着武器的姿势
SWEP.IronSightsHoldType = "ar2" --机瞄时的姿势
---------------- [武器模型设置] ----------------
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Angle(0, 0, 0)
SWEP.ViewModelFOV = 60 --第一人称镜头的大小
SWEP.ViewModelFlip = true
SWEP.BobScale = 1
SWEP.SwayScale = 1

-- SCK 元素容器
SWEP.VElements = {}
SWEP.WElements = {}
SWEP.ViewModelBoneMods = {}
---------------- [特殊属性] ----------------
SWEP.CSMuzzleFlashes = true -- 是否使用 Counter-Strike 样式的枪口闪光效果（需要配合模型支持）
SWEP.EmptyWhenPurchased = true -- 购买时是否空弹夹（需要配合 GAMEMODE:SetupDefaultClip 使用）
SWEP.Undroppable = false --禁止丢弃，true 为禁止丢弃，false 为允许丢弃
SWEP.NoPickupNotification = false --捡起的时候是否显示提示，true 为禁止提示，false 为显示提示
SWEP.NoDismantle = false --禁止拆除，true 为禁止拆除，false 为允许拆除
SWEP.NoGlassWeapons = true --不是玻璃武器
SWEP.AllowQualityWeapons = true --是否允许强化
---------------- [武器扩散] ----------------
SWEP.ConeMax = 1.5 --最大
SWEP.ConeMin = 0.5 --最小准星（这个是白板武器和没有装备
SWEP.ConeRamp = 2 --准星扩散速度
SWEP.FixedAccuracy = false  -- 如果设为 true，则完全忽略玩家状态和移动，始终使用 ConeMin 作为扩散。
SWEP.RecoilMultSights = 0.5 -- 瞄准时后坐力倍率
SWEP.RecoilMultCrouch = 0.75 -- 蹲下时后坐力倍率
SWEP.RecoilMultMidAir = 2.0 -- 半空中时后坐力倍率
SWEP.RecoilMultMove = 1.3 -- 移动时后坐力倍率

---------------- [左键设置] ----------------

SWEP.Primary.Sound = Sound("Weapon_Pistol.Single") --左键开火音效
SWEP.DryFireSound = Sound("Weapon_Pistol.Empty") --没子弹音效
SWEP.Primary.Damage = 30 --伤害
SWEP.Primary.KnockbackScale = 1
SWEP.Primary.NumShots = 1 --一次射击的子弹数目
SWEP.Primary.Delay = 0.15 --一次射击的延迟
SWEP.Primary.ClipSize = 8 --主弹匣的子弹数
SWEP.Primary.DefaultClip = 0 --默认送的弹匣数目，如果不为零最终送的子弹数是： ClipSize × DefaultClip ，两个相乘
SWEP.Primary.Automatic = false --全自动设置
SWEP.Primary.Ammo = "pistol" --左键开火需要的弹药
SWEP.RequiredClip = 1
---------------- [右键设置] ----------------
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"
---------------- [武器HUD] ----------------
SWEP.HUD3DBone = "base"
SWEP.HUD3DScale = 0.01
SWEP.HUD3DAng = Angle(180, 0, 0)
SWEP.HUD3DPos = Vector(0, 0, 0)
SWEP.CooldownExtraSize = 1 --冷却环大小
---------------- [后坐力系统] ----------------
SWEP.Recoil_Enabled = false -- 设为 true 来为武器启用此系统
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
SWEP.RecoilTimeStep = 0.06     -- 注入采样步长(秒)，越小上抬越平滑

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
SWEP.CustomSightsAttackAnim = false --是否启用模拟开镜开火动画
SWEP.UseVisualRecoil = true -- 启用枪模物理后坐力
SWEP.VisualRecoilPunch = 1.5 -- [开镜组] 枪模后坐冲击感
SWEP.VisualRecoilUp = -1.8 -- [开镜组] 枪模垂直位移
SWEP.VisualRecoilRoll = 2.5 -- [开镜组] 枪模滚转
SWEP.VisualRecoilStiffness = 200 -- 弹簧刚度 (越高越"硬")
SWEP.VisualRecoilDamping = 20 -- 弹簧阻尼 (越高越快衰减)
SWEP.VisualRecoilCenter = Vector(0, 0, 0)


---------------- 机械瞄准 (Iron Sights)----------------
SWEP.IronEnable = true --是否允许机瞄（false 时右键不再进入瞄准状态）
SWEP.AimDownSightsTime = 0.25 --完成一次开镜/收镜的平滑过渡秒数（ARC9 风格）
SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Angle(0, 0, 0)
SWEP.IronSpeed = 8
SWEP.IronsightsMultiplier = 0.6 --开镜的放大倍数
SWEP.Breathmult = 1.3 -- 呼吸强度系数

-- 动态运动参数 (Sway/Bob)
SWEP.SwayAmount = 0.02
SWEP.BobAmount = 0.001
SWEP.MovementLerpSpeed = 4

-- 检视与动画
SWEP.InspectOnDeploy = false
SWEP.DeployInspectTime = 5
SWEP.InspectSpeed = 1
SWEP.ReloadSpeed = 1.0
SWEP.FireAnimSpeed = 1.0
SWEP.IdleActivity = ACT_VM_IDLE


-- =============================================================================
-- SECTION: ARC9 风格加载器 (Auto Loader)
-- =============================================================================

local baseName = "weapon_zs_base" -- 请确保文件夹名与此一致
local searchdir = "weapons/" .. baseName

local function autoinclude(dir)
    local files, dirs = file.Find(dir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        if filename ~= "shared.lua" and filename ~= "init.lua" and filename ~= "cl_init.lua" then
            local luatype = string.sub(filename, 1, 3)

            if luatype == "sv_" then
                if SERVER then
                    include(dir .. "/" .. filename)
                end
            elseif luatype == "cl_" then
                if SERVER then
                    AddCSLuaFile(dir .. "/" .. filename)
                else
                    include(dir .. "/" .. filename)
                end
            elseif luatype == "sh_" then
                if SERVER then
                    AddCSLuaFile(dir .. "/" .. filename)
                end
                include(dir .. "/" .. filename)
            end
        end
    end

    for _, path in pairs(dirs) do
        autoinclude(dir .. "/" .. path)
    end
end

autoinclude(searchdir)