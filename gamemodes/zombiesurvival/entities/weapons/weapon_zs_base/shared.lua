-- shared.lua
--SWEP.Base = "weapon_base"
SWEP.PrintName = "ZS Modular Base"

--SWEP.Instructions = ""
SWEP.DrawAmmo = true                      -- 是否绘制游戏默认的弹药 HUD。
SWEP.DrawCrosshair = false                -- 是否绘制准星。
SWEP.Slot = 0                             -- 武器在武器选择栏中的位置（0 通常是主武器）。
-- =============================================================================
-- SECTION: 参数配置 (Parameters) - 所有的数值定义在这里
-- =============================================================================

-- 基础战斗属性
SWEP.Primary.Sound = Sound("Weapon_Pistol.Single")
SWEP.DryFireSound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Damage = 30
SWEP.Primary.KnockbackScale = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.RequiredClip = 1

SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

SWEP.CSMuzzleFlashes = false -- 是否使用 Counter-Strike 样式的枪口闪光效果（需要配合模型支持）
SWEP.EmptyWhenPurchased = true -- 购买时是否空弹夹（需要配合 GAMEMODE:SetupDefaultClip 使用）

SWEP.Undroppable = false --禁止丢弃，true 为禁止丢弃，false 为允许丢弃
SWEP.NoPickupNotification = false --捡起的时候是否显示提示，true 为禁止提示，false 为显示提示
SWEP.NoDismantle = false --禁止拆除，true 为禁止拆除，false 为允许拆除
--SWEP.NoGlassWeapons = true --不是玻璃武器
SWEP.AllowQualityWeapons = true --禁止强化
-- 移动与状态
SWEP.WalkSpeed = 190 -- SPEED_NORMAL
SWEP.HoldType = "pistol"
SWEP.IronSightsHoldType = "ar2"
SWEP.Weight = 5
SWEP.Tier = 1

-- 扩散 (Cone)
SWEP.ConeMax = 1.5
SWEP.ConeMin = 0.5
SWEP.ConeRamp = 2
SWEP.FixedAccuracy = false  -- 如果设为 true，则完全忽略玩家状态和移动，始终使用 ConeMin 作为扩散。

-- 后坐力系统 (Recoil)
SWEP.Recoil_Enabled = false -- 设为 true 来为武器启用此系统
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
SWEP.CustomSightsAttackAnim = false --是否启用模拟开镜开火动画，对于默认开火动画不是很适合开镜射击和没有开镜开火的武器非常有用
SWEP.VisualRecoilPunch = 0 -- 枪后坐力冲击感 (弹簧效果强度)
SWEP.VisualRecoilUp = 0 -- 视觉后坐力垂直位移
SWEP.VisualRecoilRoll = 0 -- 视觉后坐力滚转
SWEP.VisualRecoilStiffness = 80 -- 视觉后坐力弹簧刚度 (越高越“硬”)
SWEP.VisualRecoilDamping = 10 -- 视觉后坐力弹簧阻尼 (越高越快衰减)

-- 状态倍率
SWEP.RecoilMultSights = 0.5 -- 瞄准时后坐力倍率
SWEP.RecoilMultCrouch = 0.75 -- 蹲下时后坐力倍率
SWEP.RecoilMultMidAir = 2.0 -- 半空中时后坐力倍率
SWEP.RecoilMultMove = 1.3 -- 移动时后坐力倍率

-- 视图模型基础设置
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = true
SWEP.BobScale = 1
SWEP.SwayScale = 1
SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Angle(0, 0, 0)

-- 机械瞄准 (Iron Sights)
SWEP.IronEnable = true
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


-- HUD 相关
SWEP.HUD3DBone = "base"
SWEP.HUD3DScale = 0.01
SWEP.HUD3DAng = Angle(180, 0, 0)
SWEP.HUD3DPos = Vector(0, 0, 0)
SWEP.CooldownExtraSize = 1

-- SCK 元素容器
SWEP.VElements = {}
SWEP.WElements = {}
SWEP.ViewModelBoneMods = {}

-- =============================================================================
-- SECTION: ARC9 风格加载器 (Auto Loader)
-- =============================================================================

local baseName = "weapon_zs_base" -- 请确保文件夹名与此一致
local searchdir = "weapons/" .. baseName

local function autoinclude(dir)
    local files, dirs = file.Find(dir .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        if filename == "shared.lua" or filename == "init.lua" or filename == "cl_init.lua" then continue end
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

    for _, path in pairs(dirs) do
        autoinclude(dir .. "/" .. path)
    end
end

autoinclude(searchdir)