--[[
==================================================================
倒刺猎头蟹 (Barbed Headcrab) — 僵尸职业
继承自：poison_headcrab
特点：带有尖刺的变异猎头蟹，皮肤呈暗黄色，具有特殊材质渲染
==================================================================
]]

-- 基础职业为"中毒猎头蟹"
CLASS.Base = "poison_headcrab"

-- 职业显示名称
CLASS.Name = "Barbed Headcrab"
-- 翻译键名
CLASS.TranslationName = "class_barbed_headcrab"
-- 描述文本键名
CLASS.Description = "description_barbed_headcrab"
-- 控制帮助文本键名
CLASS.Help = "controls_barbed_headcrab"

-- 生命值
CLASS.Health = 100
-- 击杀得分 = 生命值 / 猎头蟹僵尸点数比率
CLASS.Points = CLASS.Health/GM.HeadcrabZombiePointRatio
-- 移动速度
CLASS.Speed = 160

-- 出现波次
CLASS.Wave = 4 / 6

-- 绑定的武器
CLASS.SWEP = "weapon_zs_barbedheadcrab"

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/poisonheadcrab"
-- 图标颜色（金黄色）
CLASS.IconColor = Color(236, 218, 0)

-- 使用藤壶皮肤材质
local matSkin = Material("Models/Barnacle/barnacle_sheet")
-- 绘制前的材质覆盖和颜色调制
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.65, 0.65, 0.5)
end

-- 绘制后恢复材质和颜色
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
