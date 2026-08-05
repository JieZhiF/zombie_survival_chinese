-- ============================================================================
-- status_ghost_resupplybox.lua - 补给箱放置幽灵状态（共享定义）
-- 负责：定义补给箱部署前的放置预览：幽灵模型与朝向、
--       实际生成的实体/武器关联、最大放置距离与表面法线限制
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status_ghost_base"

-- 幽灵预览模型：弹药箱
ENT.GhostModel = Model("models/Items/ammocrate_ar2.mdl")
-- 预览模型旋转角度
ENT.GhostRotation = Angle(270, 0, 0)
-- 放置位置相对命中面的法线偏移量
ENT.GhostHitNormalOffset = 16
-- 确认放置后实际生成的实体
ENT.GhostEntity = "prop_resupplybox"
-- 对应的部署武器
ENT.GhostWeapon = "weapon_zs_resupplybox"
-- 最大放置距离
ENT.GhostDistance = 256
-- 可放置表面的最小法线向上分量（坡度限制）
ENT.GhostLimitedNormal = 0.75
