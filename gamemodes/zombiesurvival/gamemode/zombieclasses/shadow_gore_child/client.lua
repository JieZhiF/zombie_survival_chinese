-- ============================================================================
-- shadow_gore_child/client.lua - 暗影血娃 (Shadow Child) 客户端逻辑
-- 负责：击杀图标、半透明黑色渲染、覆写模型渲染与眼睛发光点
-- ============================================================================

include("shared.lua")

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/gorechild"
-- 图标颜色（黑色）
CLASS.IconColor = Color(20, 20, 20)

-- 缓存渲染与坐标变换函数
local render_ModelMaterialOverride = render.ModelMaterialOverride
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 眼睛发光点颜色与材质
local colGlow = Color(255, 0, 0)
local matGlow = Material("sprites/glow04_noz")
-- 全黑无光照材质（覆写模型用）
local matBlack = CreateMaterial("shadowlurkersheet", "UnlitGeneric", {["$basetexture"] = "Tools/toolsblack", ["$model"] = 1})
-- 眼睛发光点相对头部骨骼的偏移
local vecEyeLeft = Vector(1.5, -1.25, -0.8)
local vecEyeRight = Vector(1.5, -1.25, 0.8)
-- 手部皮肤材质（布料材质）
local matSheet = Material("models/props_c17/doll01")

-- ==== DrawHands - 渲染半透明深色手部模型 ====
function CLASS:DrawHands(pl, hands)
	render_ModelMaterialOverride(matSheet)
	render_SetColorModulation(0.1, 0.1, 0.1)
	render_SetBlend(0.55)

	hands:DrawModel()

	-- 恢复默认渲染状态
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
	render_ModelMaterialOverride(nil)

	return true
end

-- ==== PrePlayerDraw - 绘制前设置半透明深色效果 ====
function CLASS:PrePlayerDraw(pl)
	render_SetBlend(0.55)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

-- ==== PostPlayerDraw - 绘制后恢复默认渲染状态 ====
function CLASS:PostPlayerDraw(pl)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end

-- ==== PrePlayerDrawOverrideModel - 覆写模型绘制前覆盖为纯黑材质 ====
function CLASS:PrePlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(matBlack)
end

-- ==== PostPlayerDrawOverrideModel - 覆写模型绘制后恢复材质并绘制眼睛发光点 ====
function CLASS:PostPlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(nil)

	-- 第一人称且未启用本地绘制时跳过发光点
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() then return end

	-- 在眼睛骨骼位置绘制红色发光精灵
	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 2, 2, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 2, 2, colGlow)
	end
end
