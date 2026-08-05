-- ============================================================================
-- vile_bloated_zombie/client.lua - 恶劣肿胀僵尸 (Vile Bloated Zombie) 客户端逻辑
-- 负责：击杀图标、藤壶皮肤材质、暗绿色调渲染与眼睛发光点
-- ============================================================================

include("shared.lua")

-- 缓存渲染与坐标变换函数
local render_SetColorModulation = render.SetColorModulation
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_ModelMaterialOverride = render.ModelMaterialOverride

local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 眼睛发光点颜色与材质
local colGlow = Color(70, 200, 70)
local matGlow = Material("sprites/glow04_noz")
-- 眼睛发光点相对头部骨骼的偏移
local vecEyeLeft = Vector(5, -4, -1.2)
local vecEyeRight = Vector(5, -4, 1.2)

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/bloatedzombie"
-- 图标颜色（深绿色）
CLASS.IconColor = Color(10, 94, 0)

-- 皮肤材质（藤壶皮肤）
local matSkin = Material("Models/Barnacle/barnacle_sheet")

-- ==== PrePlayerDraw - 绘制前覆盖藤壶皮肤材质并施加暗绿色调 ====
function CLASS:PrePlayerDraw(pl)
	render_ModelMaterialOverride(matSkin)
	render_SetColorModulation(0.16, 0.3, 0.12)
end

-- ==== PostPlayerDraw - 绘制后恢复材质，并在眼睛位置渲染发光点 ====
function CLASS:PostPlayerDraw(pl)
	render_ModelMaterialOverride()
	render_SetColorModulation(1, 1, 1)

	-- 第一人称且未启用本地绘制、或处于出生保护时跳过发光点
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	-- 在眼睛骨骼位置绘制绿色发光精灵
	local pos, ang = pl:GetBonePositionMatrixed(14)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
