-- ============================================================================
-- status_ghost_zapper.lua - 电击器幽灵放置状态（共享单文件）
-- 负责：定义放置电击器（prop_zapper）的幽灵预览参数：模型、朝向、距离与偏移
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status_ghost_base"

-- 幽灵预览模型：接线盒模型（旋转 270 度贴合墙面）
ENT.GhostModel = Model("models/props_c17/utilityconnecter006c.mdl")
ENT.GhostRotation = Angle(270, 0, 0)
-- 实际放置的实体与对应武器
ENT.GhostEntity = "prop_zapper"
ENT.GhostWeapon = "weapon_zs_zapper"
-- 距目标表面 120 单位处放置
ENT.GhostDistance = 120
-- 沿表面法线向外偏移 25 单位（避免模型嵌入墙体）
ENT.GhostHitNormalOffset = 25
-- 电击器不属于路障类道具（不被钉子/路障系统限制）
ENT.GhostNotBarricadeProp = true
-- 通配符：限制区域内已放置的同类型实体数量
ENT.GhostEntityWildCard = "prop_zapper"
