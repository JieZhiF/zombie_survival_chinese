-- ============================================================================
-- status_arsenalpack - 军械包（Arsenal Pack）状态实体（共享端）
-- 负责：声明实体类型，并标记各类伤害与交互豁免（近战/子弹/射线/钉子）
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- 免疫近战攻击伤害
ENT.IgnoreMelee = true
-- 免疫子弹伤害
ENT.IgnoreBullets = true
-- 不会被射线（trace）命中
ENT.IgnoreTraces = true
-- 无法被钉子（nail）钉住
ENT.NoNails = true
