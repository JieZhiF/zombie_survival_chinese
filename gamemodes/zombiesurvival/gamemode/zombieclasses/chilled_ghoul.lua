-- ============================================================================
-- 寒冰食尸鬼 (Frigid Ghoul) — 僵尸职业
-- 继承自：ghoul
-- 特点：冰霜抗性、冰蓝色渲染、发光眼睛（青色）、初始解锁
-- ============================================================================

-- 基础职业为"食尸鬼"
CLASS.Base = "ghoul"

-- 职业显示名称
CLASS.Name = "Frigid Ghoul"
-- 翻译键名
CLASS.TranslationName = "class_chilled_ghoul"
-- 描述文本键名
CLASS.Description = "description_chilled_ghoul"
-- 控制帮助文本键名
CLASS.Help = "controls_chilled_ghoul"

-- 进阶版本
CLASS.BetterVersion = "Frigid Revenant"

-- 出现波次（初始）
CLASS.Wave = 0
-- 初始解锁
CLASS.Unlocked = true

-- 生命值
CLASS.Health = 220
-- 移动速度
CLASS.Speed = 175

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 冰霜抗性
CLASS.ResistFrost = true
-- 冰冻抗性（去掉百分号的数值）：0 = 免疫冰冻 buff
CLASS.FreezeResistance = 0

-- 绑定的武器
CLASS.SWEP = "weapon_zs_chilledghoul"

-- 自定义受伤音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 75, math.Rand(137, 143))
	pl.NextPainSound = CurTime() + 0.5
	return true
end

-- 自定义死亡音效
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_die1.wav", 75, math.Rand(120, 128))
	return true
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标（复用食尸鬼图标，淡蓝色）
CLASS.Icon = "zombiesurvival/killicons/ghoul"
-- 图标颜色（淡蓝色）
CLASS.IconColor = Color(20, 20, 250)

-- 渲染变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 发光颜色（青色）
local colGlow = Color(60, 220, 220)
local matSkin = Material("Models/humans/corpse/corpse1.vtf")
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前：覆盖皮肤材质并调制冰蓝色
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.2, 0.5, 0.95)
end

-- 绘制后恢复并绘制发光眼睛
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
