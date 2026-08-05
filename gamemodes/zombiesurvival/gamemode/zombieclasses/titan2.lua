-- ============================================================================
-- 泰坦2 (Titan2) — 僵尸职业
-- 继承自：titan
-- 特点：泰坦的变体、更高血量速度、隐藏、暗色材质渲染
-- ============================================================================

-- 基础职业为"泰坦"
CLASS.Base = "titan"

-- 职业显示名称
CLASS.Name = "Titan2"
-- 翻译键名
CLASS.TranslationName = "class_titan_b"
-- 描述/帮助文本键名（复用泰坦）
-- 描述文本键名（复用泰坦）
CLASS.Description = "description_titan"
-- 控制帮助文本键名（复用泰坦）
CLASS.Help = "controls_titan"

-- 生命值
CLASS.Health = 900
-- 移动速度
CLASS.Speed = 145
-- 不可复活
CLASS.Revives = false
-- 隐藏
CLASS.Hidden = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_titan_b"

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 出现波次
CLASS.Wave = 5 / 6

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/zombie"
-- 图标颜色（深灰色）
CLASS.IconColor = Color(0.271, 0.271, 0.271)

-- 属性：无摔落伤害
CLASS.NoFallDamage = true
-- 未解锁
CLASS.Unlocked = false
-- 不可装死
CLASS.CanFeignDeath = false
-- 可嘲讽
CLASS.CanTaunt = true

-- 语音音调
CLASS.VoicePitch = 1.0
-- 模型缩放
CLASS.ModelScale = 1.45
-- 质量
CLASS.Mass = 500
-- 视角偏移
CLASS.ViewOffset = DEFAULT_VIEW_OFFSET * CLASS.ModelScale
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = DEFAULT_VIEW_OFFSET_DUCKED * CLASS.ModelScale
-- 台阶高度
CLASS.StepSize = 25
-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 36)}

-- 皮肤材质
local matSkin = Material("models/Zombie_Classic/Zombie_Classic_sheet.vtf")

-- 绘制前：覆盖皮肤材质并调制暗色
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.271, 0.271, 0.271)
end

-- 绘制后：恢复材质与颜色
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
