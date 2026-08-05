-- ============================================================================
-- boss_giga_shadow_child/shared.lua - 巨兽暗影血娃 (Giga Shadow Child) 共享定义
-- 负责：职业属性（继承巨兽血娃）、小BOSS标记、受伤音效（双端加载）
-- ============================================================================

-- 继承巨兽血娃 (Giga Gore Child) 的基础属性
CLASS.Base = "boss_giga_gore_child"

-- 职业显示名称
CLASS.Name = "Giga Shadow Child"
-- 翻译键名
CLASS.TranslationName = "class_giga_shadow_child"
-- 描述文本键名
CLASS.Description = "description_giga_shadow_child"
-- 控制帮助文本键名
CLASS.Help = "controls_giga_shadow_child"

-- 非普通BOSS
CLASS.Boss = false
-- 小BOSS标记（可在僵尸商店购买）
CLASS.MiniBoss = true
-- 隐藏职业（不在常规职业列表中显示）
CLASS.Hidden = true

-- 生命值
CLASS.Health = 2000
-- 移动速度
CLASS.Speed = 235

-- 击杀得分
CLASS.Points = 35

-- 绑定的武器
CLASS.SWEP = "weapon_zs_gigashadowchild"

-- 覆写模型（骷髅模型）
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 不隐藏主模型（覆写模型与主模型叠加显示）
CLASS.NoHideMainModel = true

-- 缓存字符串格式化与随机数函数
local string_format = string.format
local math_random = math.random

-- ==== PlayPainSound - 播放受伤音效（随机播放哭泣声，带 2 秒冷却） ====
function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("ambient/creatures/town_scared_sob%d.wav", math_random(2)), 70, math_random(50, 60))
	pl.NextPainSound = CurTime() + 2

	return true
end
