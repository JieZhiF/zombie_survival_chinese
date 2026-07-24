--[[
==================================================================
剧毒食尸鬼 (Noxious Ghoul) — 僵尸职业
继承自：elder_ghoul
特点：长老食尸鬼的进阶版、更高血量速度、紫粉色眼睛发光效果
==================================================================
]]

-- 基础职业为"长老食尸鬼"
CLASS.Base = "elder_ghoul"

-- 出现波次
CLASS.Wave = 4 / 6

-- 职业显示名称
CLASS.Name = "Noxious Ghoul"
-- 翻译键名
CLASS.TranslationName = "class_noxiousghoul"
-- 描述文本键名
CLASS.Description = "description_noxiousghoul"
-- 控制帮助文本键名
CLASS.Help = "controls_noxiousghoul"

-- 生命值
CLASS.Health = 320
-- 移动速度
CLASS.Speed = 185

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio
-- 无玩家颜色
CLASS.NoPlayerColor = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_noxiousghoul"

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/ghoul"
CLASS.IconColor = Color(230, 130, 190)

-- 渲染变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 发光颜色（亮绿色）
local colGlow = Color(100, 200, 80)
local matSkin = Material("Models/humans/corpse/corpse1.vtf")
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.9, 0.55, 0.9)
end

-- 绘制后
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 10, 0.5, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 3, 3, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 10, 0.5, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 3, 3, colGlow)
	end
end
