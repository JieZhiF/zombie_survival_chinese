-- ============================================================================
-- weapon_zs_kongolaxe.lua - 刚果斧近战武器
-- 负责：高伤害重型双手斧，具有大范围击退、格挡功能、自定义挥砍动画
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_kongolaxe")
SWEP.Description = ""..translate.Get("weapon_zs_kongolaxe_description")

if CLIENT then
	-- 第一人称视角设置
	SWEP.ViewModelFOV = 65
	SWEP.ViewModelFlip = false

	-- 隐藏原始模型，使用 SCK 元素自定义外观
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	-- 第一人称视角模型元素（由斧头模型和金属道具拼装的重型斧头外观）
	SWEP.VElements = {
		["base2+++"] = { type = "Model", model = "models/props_phx/misc/iron_beam1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.519, 14, 0), angle = Angle(0, 90, -90), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} },
		["base2"] = { type = "Model", model = "models/props_phx/gibs/wooden_wheel2_gib2.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(2, 15.074, -1.5), angle = Angle(0, -45, 0), size = Vector(0.349, 0.349, 0.349), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base2++++"] = { type = "Model", model = "models/props_phx/construct/metal_angle180.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 15.064, -1), angle = Angle(0, 180, 0), size = Vector(0.2, 0.2, 0.5), color = Color(255, 255, 255, 35), surpresslightning = false, material = "models/shiny", skin = 0, bodygroup = {} },
		["base2++"] = { type = "Model", model = "models/props_phx/gibs/wooden_wheel2_gib2.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(2.049, 15.064, -1.52), angle = Angle(0, -80, 0), size = Vector(0.349, 0.349, 0.349), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} },
		["base2+"] = { type = "Model", model = "models/props_phx/construct/metal_angle180.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 15.064, -1), angle = Angle(0, 180, 0), size = Vector(0.2, 0.2, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} }
	}

	-- 世界模型元素（第三人称显示的重型斧头外观）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.299, -4), angle = Angle(0, 0, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["base2+++"] = { type = "Model", model = "models/props_phx/misc/iron_beam1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.519, 14, 0), angle = Angle(0, 90, -90), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} },
		["base2"] = { type = "Model", model = "models/props_phx/gibs/wooden_wheel2_gib2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.699, 15.074, -1.5), angle = Angle(0, -45, 0), size = Vector(0.349, 0.349, 0.349), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} },
		["base2++++"] = { type = "Model", model = "models/props_phx/construct/metal_angle180.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 15.064, -1), angle = Angle(0, 180, 0), size = Vector(0.2, 0.2, 0.5), color = Color(255, 255, 255, 35), surpresslightning = false, material = "models/shiny", skin = 0, bodygroup = {} },
		["base2++"] = { type = "Model", model = "models/props_phx/gibs/wooden_wheel2_gib2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0.75, 15.064, -1.52), angle = Angle(0, -80, 0), size = Vector(0.349, 0.349, 0.349), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} },
		["base2+"] = { type = "Model", model = "models/props_phx/construct/metal_angle180.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 15.064, -1), angle = Angle(0, 180, 0), size = Vector(0.2, 0.2, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/chairchrome01", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称/世界模型
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
-- 使用 C 模型手部
SWEP.UseHands = true

-- 持握姿势：双手近战（melee2）
SWEP.HoldType = "melee2"

-- 近战伤害、攻击范围、攻击判定大小、击退力度
SWEP.MeleeDamage = 150
SWEP.MeleeRange = 75
SWEP.MeleeSize = 3
SWEP.MeleeKnockBack = 350

-- 攻击延迟
SWEP.Primary.Delay = 1.3

-- 持有时的移动速度（较慢）
SWEP.WalkSpeed = SPEED_SLOWER

-- 自定义挥砍动画参数：旋转角度、偏移、挥砍时间、挥砍时持握类型
SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.6
SWEP.SwingHoldType = "melee"

-- 命中贴花类型（砍痕）
SWEP.HitDecal = "Manhackcut"
-- 格挡时武器位置与角度偏移
SWEP.BlockPos = Vector(-22.19, -5.29, 9.319)
SWEP.BlockAng = Angle(0.732, -14.687, -66.086)
-- 格挡音效音调与音效文件（随机金属撞击音）
SWEP.BlockSoundPitch  = math.random(120,150)
SWEP.BlockSound = "physics/metal/metal_sheet_impact_hard"..math.random(6,8)..".wav"


-- 武器等级与最大库存
SWEP.Tier = 4
SWEP.MaxStock = 3

-- 允许强化
SWEP.AllowQualityWeapons = true

-- 武器修饰符：攻击延迟-0.13（加快攻击速度）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.13)

-- ==== PlaySwingSound - 播放挥砍音效 ====
function SWEP:PlaySwingSound()
	-- 播放冰镐挥砍音效（低音调）
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(40, 45))
end

-- ==== PlayHitSound - 播放命中墙壁音效 ====
function SWEP:PlayHitSound()
	-- 随机播放高尔夫球杆击球音效
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(4)..".ogg", 75, math.random(70, 75))
end

-- ==== PlayHitFleshSound - 播放命中肉体音效 ====
function SWEP:PlayHitFleshSound()
	-- 播放血肉破裂音效
	self:EmitSound("physics/flesh/flesh_bloody_break.wav", 80, math.random(95, 105))
end
