-- ============================================================================
-- status_ambience_coolwisp/shared.lua - 冷焰妖灵氛围实体（共享）
-- 负责：声明以 status_ambience_base 为基类的氛围挂件：拥有者为
--       "Cool Wisp" 职业时保留，并附加悬浮光球模型
-- ============================================================================

-- 实体类型：动画实体（生命周期由基类统一管理）
ENT.Type = "anim"

-- 基类：氛围实体基类，负责按职业名匹配拥有者并设置模型
ENT.Base = "status_ambience_base"
-- 附加的视觉挂件模型：悬浮光球
ENT.AmbienceModel = "models/dav0r/hoverball.mdl"
-- 匹配的僵尸职业名：拥有者为 "Cool Wisp" 时保留本实体
ENT.AmbienceClassNames = {"Cool Wisp"}
