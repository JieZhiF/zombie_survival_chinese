-- ============================================================================
-- 寒冰亡魂 (Frigid Revenant) — 僵尸职业
-- 继承自：shadow_walker
-- 特点：冰霜抗性、骷髅标记、半透明冰蓝色渲染、
--       双眼发出蓝白色光芒、黑色覆盖模型材质
-- ============================================================================

-- 基础职业为"暗影行者"
CLASS.Base = "shadow_walker"

-- 职业显示名称
CLASS.Name = "Frigid Revenant"
-- 翻译键名
CLASS.TranslationName = "class_frigid_revenant"
-- 描述文本键名
CLASS.Description = "description_frigid_revenant"
-- 控制帮助文本键名
CLASS.Help = "controls_frigid_revenant"

-- 绑定的武器
CLASS.SWEP = "weapon_zs_frigidrevenant"

-- 出现波次
CLASS.Wave = 4 / 6

-- 生命值
CLASS.Health = 300
-- 移动速度
CLASS.Speed = 180

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 冰霜抗性
CLASS.ResistFrost = true

-- 骷髅标记
CLASS.Skeletal = true

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/skeletal_walker"
-- 图标颜色（冰蓝色）
CLASS.IconColor = Color(50, 90, 135)

-- 渲染变量
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_ModelMaterialOverride = render.ModelMaterialOverride
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 发光颜色（淡紫色/冰蓝色）
local colGlow = Color(200, 175, 255)
local matGlow = Material("sprites/glow04_noz")
local matBlack = CreateMaterial("shadowlurkersheet", "UnlitGeneric", {["$basetexture"] = "Tools/toolsblack", ["$model"] = 1})
local vecEyeLeft = Vector(5, -3.5, -1)
local vecEyeRight = Vector(5, -3.5, 1)

-- 主模型绘制前：半透明+冰蓝色
function CLASS:PrePlayerDraw(pl)
	render_SetBlend(0.85)
	render_SetColorModulation(0.6, 0.3, 0.8)
end

-- 主模型绘制后恢复
function CLASS:PostPlayerDraw(pl)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end

-- 覆盖模型绘制前：黑色材质
function CLASS:PrePlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(matBlack)
end

-- 覆盖模型绘制后：绘制发光眼睛
function CLASS:PostPlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(nil)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 10, 0.5, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 10, 0.5, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
