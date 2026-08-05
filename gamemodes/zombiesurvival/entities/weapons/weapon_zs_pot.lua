-- ============================================================================
-- weapon_zs_pot.lua - 平底锅近战武器
-- 负责：以平底锅模型进行近战攻击（敲击），并带烹饪（Culinary）与格挡减伤特性
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_pot")

if CLIENT then -- 客户端专属设置
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 55 -- 第一人称视野大小

	-- 隐藏原始第一人称模型（改用自定义元素渲染）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 第一人称手持元素：在右手骨骼上附加平底锅模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_interiors/pot02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -6.818), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称世界元素：同样在右手骨骼上附加平底锅模型
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_interiors/pot02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -6.818), angle = Angle(0, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器母本
SWEP.Base = "weapon_zs_basemelee"

-- 伤害类型：钝器敲击伤害
SWEP.DamageType = DMG_CLUB

-- 第一人称模型（电击棒模型仅用于动画骨架）
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
-- 世界模型：平底锅
SWEP.WorldModel = "models/props_interiors/pot02a.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.MeleeDamage = 40 * GAMEMODE.LabourTime -- 近战伤害（随游戏时长"劳工时间"增长）
SWEP.MeleeRange = 50 -- 近战攻击距离
SWEP.MeleeSize = 1.15 -- 近战判定范围大小（命中半径）

SWEP.UseMelee1 = true -- 使用左键近战攻击模式

-- 命中时的挥击手势动画
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
-- 落空时的挥击手势动画（与命中相同）
SWEP.MissGesture = SWEP.HitGesture

SWEP.SwingRotation = Angle(30, -30, -30) -- 挥击时的模型旋转
SWEP.SwingTime = 0.3 -- 挥击动画时长
SWEP.SwingHoldType = "grenade" -- 挥击期间的手持姿势
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319) -- 格挡时模型的位置偏移
SWEP.BlockAng = Angle(10.732, -4.687, -46.086) -- 格挡时模型的旋转

SWEP.DefendingDamageBlockedDefault = 1.1 -- 格挡减伤的默认倍率
SWEP.DefendingDamageBlocked = 1.1 -- 当前格挡减伤倍率

SWEP.AllowQualityWeapons = true -- 允许武器强化
SWEP.Culinary = true -- 具有"烹饪"特性（可与厨师技能联动）

-- 附加武器修正：开火延迟减少 0.1 秒（挥击更快）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1)

-- ==== PlayHitSound - 播放命中音效 ====
-- 随机播放平底锅敲击声
function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/frying_pan/pan_hit-0"..math.random(4)..".ogg")
end
