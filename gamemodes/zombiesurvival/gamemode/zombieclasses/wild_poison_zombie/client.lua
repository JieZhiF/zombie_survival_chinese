-- ============================================================================
-- wild_poison_zombie/client.lua - 野性毒僵尸 (Wild Poison Zombie) 客户端逻辑
-- 负责：击杀图标、皮肤着色与眼睛发光点渲染
-- ============================================================================

include("shared.lua")

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/poisonzombie"
-- 图标颜色（黄绿色）
CLASS.IconColor = Color(190, 240, 0)

-- 缓存渲染与坐标变换函数
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local LocalToWorld = LocalToWorld

-- 发光点颜色与材质
local colGlow = Color(110, 160, 40)
local matSkin = Material("models/headcrab/allinonebacup2")
local matGlow = Material("sprites/glow04_noz")
-- 眼睛发光点相对头部骨骼的角度与偏移
local angEye = Angle(0, 90, 90)
local vecEyeLeft = Vector(9.1, 1.2, -4)
local vecEyeRight = Vector(9.1, -1.2, -4)

-- ==== PrePlayerDraw - 绘制前覆盖皮肤材质并施加黄绿色调 ====
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.7, 0.9, 0.2)
end

-- ==== PostPlayerDraw - 绘制后恢复材质，并在眼睛位置渲染发光点 ====
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	-- 第一人称且未启用本地绘制、或处于出生保护时跳过发光点
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	-- 在左右眼骨骼位置绘制发光精灵
	local pos, ang = pl:GetBonePositionMatrixed(4)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angEye, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angEye, pos, ang), 4, 4, colGlow)
	end
end
