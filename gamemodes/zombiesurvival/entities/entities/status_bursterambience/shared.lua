-- ============================================================================
-- status_bursterambience/shared.lua - 化学爆裂者氛围实体（共享）
-- 负责：声明以 status_ambience_base 为基类的氛围挂件：拥有者为
--       "Chem Burster" 职业时保留
-- ============================================================================

-- 实体类型：动画实体（生命周期由基类统一管理）
ENT.Type = "anim"

-- 基类：氛围实体基类，负责按职业名匹配拥有者并设置模型
ENT.Base = "status_ambience_base"
-- 匹配的僵尸职业名：拥有者为 "Chem Burster" 时保留本实体
ENT.AmbienceClassNames = {"Chem Burster"}
