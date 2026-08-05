-- ============================================================================
-- 初始死者 (Initial Dead) — 僵尸职业
-- 继承自：freshdead
-- 特点：初始第一波使用的僵尸、快速、高血量、隐藏职业、
--       红色发光眼睛
-- ============================================================================

-- 基础职业为"新鲜死者"
CLASS.Base = "freshdead"

-- 职业显示名称
CLASS.Name = "Initial Dead"
-- 翻译键名
CLASS.TranslationName = "class_initial_dead"
-- 描述/帮助（空，隐藏职业）
CLASS.Description = ""
-- 控制帮助文本键名（空）
CLASS.Help = ""

-- 初始可用/隐藏
CLASS.Wave = 0
-- 初始解锁
CLASS.Unlocked = true
-- 隐藏（不直接可选）
CLASS.Hidden = true

-- 生命值
CLASS.Health = 180
-- 移动速度
CLASS.Speed = 230

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 可嘲讽
CLASS.CanTaunt = true

-- 使用玩家之前的模型
CLASS.UsePreviousModel = true

-- 绑定的武器（复用新鲜死者武器）
CLASS.SWEP = "weapon_zs_freshdead"

-- 服务端：被击杀时不做特殊处理
if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fresh_dead"

-- 渲染变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 红色发光眼睛
local colGlow = Color(255, 0, 0)
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(5, -3.5, -1)
local vecEyeRight = Vector(5, -3.5, 1)

-- 覆盖模型绘制后：绘制红色发光眼睛
function CLASS:PostPlayerDrawOverrideModel(pl)
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() then return end

	local id = pl:LookupBone("ValveBiped.Bip01_Head1")
	if id and id > 0 then
		local pos, ang = pl:GetBonePositionMatrixed(id)
		if pos then
			render_SetMaterial(matGlow)
			render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
			render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
		end
	end
end
