-- ============================================================================
-- 强化骷髅 (Reinforced Skeleton) — 隐藏召唤职业
-- 继承自骷髅游荡者，由死神 BOSS 通过“婴儿逻辑”投掷的骷髅巢穴召唤
-- ============================================================================

-- 继承骷髅游荡者的基础属性
CLASS.Base = "skeletal_shambler"

-- 职业显示名称
CLASS.Name = "Reinforced Skeleton"
-- 翻译键名
CLASS.TranslationName = "class_reinforced_skeleton"
-- 描述文本键名
CLASS.Description = "description_reinforced_skeleton"
-- 控制帮助文本键名
CLASS.Help = "controls_reinforced_skeleton"

-- 隐藏（只能由死神召唤，不可直接选择）
CLASS.Hidden = true
-- 初始解锁（重生逻辑需要）
CLASS.Unlocked = true
-- 出场波次
CLASS.Wave = 0

-- 生命值（强化）
CLASS.Health = 300
-- 移动速度（强化）
CLASS.Speed = 170

-- 击杀得分（按强化后血量计算）
CLASS.Points = CLASS.Health / GM.SkeletonPointRatio
