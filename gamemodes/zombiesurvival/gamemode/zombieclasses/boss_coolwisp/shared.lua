-- ============================================================================
-- boss_coolwisp/shared.lua - 寒冰鬼火 (Cool Wisp) BOSS 共享定义
-- 负责：职业属性（继承鬼火）、BOSS标记、免疫冰冻、破碎音效（双端加载）
-- ============================================================================

-- 继承鬼火 (Will o' Wisp) 的基础属性
CLASS.Base = "boss_willowisp"

-- 职业显示名称
CLASS.Name = "Cool Wisp"
-- 翻译键名
CLASS.TranslationName = "class_coolwisp"
-- 描述文本键名
CLASS.Description = "description_coolwisp"
-- 控制帮助文本键名
CLASS.Help = "controls_coolwisp"

-- 标记为BOSS
CLASS.Boss = true

-- 绑定的武器
CLASS.SWEP = "weapon_zs_coolwisp"

-- 生命值
CLASS.Health = 900

-- 击杀得分
CLASS.Points = 20

-- 免疫冰冻效果
CLASS.ResistFrost = true

-- 死亡音效（扫描机器人能量爆炸）
CLASS.DeathSounds = {Sound("npc/scanner/cbot_energyexplosion1.wav")}

-- 缓存随机数与字符串格式化函数
local math_random = math.random
local string_format = string.format
local math_Rand = math.Rand

-- ==== PlayPainSound - 播放受伤音效（随机玻璃破碎声，带 0.75 秒冷却） ====
function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("physics/glass/glass_impact_bullet%d.wav", math_random(4)), 75, math_Rand(105, 128))
	pl.NextPainSound = CurTime() + 0.75

	return true
end
