-- ============================================================================
-- weapon_zs_meattenderizer.lua - 近战武器「肉锤」（Meat Tenderizer）
-- 负责：定义大锤近战属性、攻击/命中音效与 SCK 锤头+尖刺外观模型
-- ============================================================================

AddCSLuaFile()

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_meattenderizer")
SWEP.Description = ""..translate.Get("weapon_zs_meattenderizer_description")

if CLIENT then
	-- 第一人称视野 FOV 70，显示第一人称模型、隐藏第三人称模型
	SWEP.ViewModelFOV = 70
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	-- SCK 元素（第一人称）：由纸箱块与四根金属条组成的锤头造型
	SWEP.VElements = {
		["spikes2"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "sledgetop", pos = Vector(-0.051, -5.915, -0.113), angle = Angle(0, 0, -90), size = Vector(0.076, 1.013, 0.356), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes2+"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "sledgetop", pos = Vector(-0.047, 5.934, 0.104), angle = Angle(0, 0, 90), size = Vector(0.076, 1.013, 0.356), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["sledgetop"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.466, 2.184, -22.969), angle = Angle(0, 90, -5.652), size = Vector(0.196, 0.326, 0.284), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "sledgetop", pos = Vector(-0.087, -5.854, 0), angle = Angle(-90, 90, 0), size = Vector(0.059, 0.95, 0.374), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes+"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "sledgetop", pos = Vector(-0.04, 5.888, 0), angle = Angle(90, 90, 0), size = Vector(0.059, 0.95, 0.374), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} }
	}
	-- SCK 元素（第三人称）：大锤柄加锤头与尖刺造型
	SWEP.WElements = {
		["top"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "sledge", pos = Vector(0, 0, 26.433), angle = Angle(90, 90, 0), size = Vector(0.196, 0.305, 0.284), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes1++"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "sledge", pos = Vector(-5.422, -0.069, 26.549), angle = Angle(0, -90, 90), size = Vector(0.059, 0.95, 0.374), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes1+++"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "sledge", pos = Vector(5.407, -0.069, 26.538), angle = Angle(0, 90, 90), size = Vector(0.059, 0.95, 0.374), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes1"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "sledge", pos = Vector(-5.487, 0, 26.361), angle = Angle(90, -90, 90), size = Vector(0.076, 1.011, 0.356), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["spikes1+"] = { type = "Model", model = "models/props_phx/mechanics/slider1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "sledge", pos = Vector(5.535, 0.126, 26.361), angle = Angle(90, 90, 90), size = Vector(0.076, 1.011, 0.356), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["sledge"] = { type = "Model", model = "models/weapons/w_sledgehammer.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.203, 1.284, 4.852), angle = Angle(180, 0, 0), size = Vector(0.759, 0.759, 0.759), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基础模板
SWEP.Base = "weapon_zs_basemelee"

-- 持枪姿势（双手近战姿势）
SWEP.HoldType = "melee2"

-- 伤害类型：钝器打击
SWEP.DamageType = DMG_CLUB

-- 第一人称与第三人称模型，使用玩家的手部模型
SWEP.ViewModel = "models/weapons/v_sledgehammer/c_sledgehammer.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

-- 近战伤害/距离/判定范围/击退力度
SWEP.MeleeDamage = 127
SWEP.MeleeRange = 60
SWEP.MeleeSize = 3.55
SWEP.MeleeKnockBack = 240

-- 攻击间隔 1.25 秒（慢速重锤）
SWEP.Primary.Delay = 1.25

-- 武器等级 3
SWEP.Tier = 3

-- 持锤移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOW

-- 挥动动画的旋转/偏移/时长与姿势
SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingTime = 0.75
SWEP.SwingHoldType = "melee"

-- 允许强化；属于烹饪类武器（切菜用途）
SWEP.AllowQualityWeapons = true
SWEP.Culinary = true
-- 格挡（右键防御）时视角偏移位置与角度
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 格挡时减免伤害倍率（默认与当前一致）
SWEP.DefendingDamageBlockedDefault = 3.2
SWEP.DefendingDamageBlocked = 3.2

-- 附加武器改造：近战命中判定延迟 -0.12 秒（挥击更快命中）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.12)

-- ==== PlaySwingSound - 播放挥动音效 ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(25, 35))
end

-- ==== PlayHitSound - 播放击中非生物（金属/硬物）音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(3)..".wav", 75, math.Rand(70, 74))
end

-- ==== PlayHitFleshSound - 播放击中生物（血肉）音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_impact_hard"..math.random(2, 3)..".wav", 75, math.Rand(80, 84))
end
