--[[
==================================================================
泰坦3 (Titan3) — BOSS僵尸职业
继承自：titan
特点：泰坦的BOSS版本、更高血量、已解锁、暗色材质渲染
==================================================================
]]

-- 基础职业为"泰坦"
CLASS.Base = "titan"

-- 职业显示名称
CLASS.Name = "Titan3"
-- 翻译键名
CLASS.TranslationName = "class_titan_b"
-- 描述/帮助文本键名（复用泰坦）
CLASS.Description = "description_titan"
CLASS.Help = "controls_titan"

-- 生命值/速度
CLASS.Health = 2000
CLASS.Speed = 145
-- 不可复活
CLASS.Revives = false
-- 标记为BOSS
CLASS.Boss = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_titan_b"

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/zombie"
CLASS.IconColor = Color(0.271, 0.271, 0.271)

-- 属性
CLASS.NoFallDamage = true
CLASS.Unlocked = true
CLASS.CanFeignDeath = false
CLASS.CanTaunt = true

CLASS.VoicePitch = 1.0
CLASS.ModelScale = 1.45
CLASS.Mass = 500
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
CLASS.StepSize = 25
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}

-- 材质
local matSkin = Material("models/Zombie_Classic/Zombie_Classic_sheet.vtf")

function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.271, 0.271, 0.271)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
