-- ============================================================================
-- status_ghost_remantler - 重装器（Remantler）幽灵放置状态实体（单文件）
-- 负责：继承幽灵放置基类，配置重装器的放置预览：幽灵模型/朝向/对应实体/放置距离与法线限制
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 实体类型：动画实体
ENT.Type = "anim"
-- 基础实体：status_ghost_base（通用放置幽灵基类）
ENT.Base = "status_ghost_base"

-- 幽灵预览模型（电源箱模型）
ENT.GhostModel = Model("models/props_lab/powerbox01a.mdl")
-- 幽灵模型的旋转角度
ENT.GhostRotation = Angle(270, 180, 0)
-- 确认放置时实际生成的目标实体
ENT.GhostEntity = "prop_remantler"
-- 与目标实体对应的放置武器
ENT.GhostWeapon = "weapon_zs_remantler"
-- 允许放置的最大距离（英寸）
ENT.GhostDistance = 128
-- 放置面法线的最小点积（限制可放置的坡度，越接近 1 要求地面越平）
ENT.GhostLimitedNormal = 0.75
-- 幽灵相对命中面的法线方向偏移距离
ENT.GhostHitNormalOffset = 23
