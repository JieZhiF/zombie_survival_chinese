--[[
==================================================================
吸血猎头蟹 (Bloodsucker Headcrab) — 僵尸职业
继承自：fast_headcrab
特点：快速猎头蟹的进阶版、暗红色调皮肤、稍高的生命值
==================================================================
]]

-- 基础职业为"快速猎头蟹"
CLASS.Base = "fast_headcrab"

-- 职业显示名称
CLASS.Name = "Bloodsucker Headcrab"
-- 翻译键名
CLASS.TranslationName = "class_bloodsucker_headcrab"
-- 描述文本键名
CLASS.Description = "description_bloodsucker_headcrab"
-- 控制帮助文本键名
CLASS.Help = "controls_bloodsucker_headcrab"

-- 出现波次
CLASS.Wave = 3 / 6

-- 使用猎头蟹模型
CLASS.Model = Model("models/headcrab.mdl")

-- 绑定的武器
CLASS.SWEP = "weapon_zs_bloodsucker_headcrab"

-- 生命值
CLASS.Health = 50

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HeadcrabZombiePointRatio

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fastheadcrab"
-- 图标颜色（暗红色）
CLASS.IconColor = Color(175, 100, 100)

-- 使用水蛭皮肤材质
local matSkin = Material("models/leech/leech.vtf")
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.68, 0.39, 0.39)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
