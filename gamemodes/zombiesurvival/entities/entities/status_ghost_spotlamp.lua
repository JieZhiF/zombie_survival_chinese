-- ============================================================================
-- status_ghost_spotlamp.lua - 探照灯放置虚影状态（共享）
-- 负责：基于 status_ghost_base 的探照灯专用虚影配置——放置时预览
--       探照灯模型，限定放置距离与墙面法线角度，放置生成 prop_spotlamp
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status_ghost_base"

-- 虚影预览模型：组合式探照灯
ENT.GhostModel = Model("models/props_combine/combine_light001a.mdl")
-- 虚影模型的固定朝向
ENT.GhostRotation = Angle(270, 180, 0)
-- 虚影相对命中点的高度偏移（0 = 贴墙放置）
ENT.GhostHitNormalOffset = 0
-- 确认放置时生成的实体
ENT.GhostEntity = "prop_spotlamp"
-- 放置后切换到的武器（探照灯本体）
ENT.GhostWeapon = "weapon_zs_spotlamp"
-- 最大放置距离（单位）
ENT.GhostDistance = 200
-- 墙面法线限制：法线与视线夹角余弦最小值（限制太斜的墙面）
ENT.GhostLimitedNormal = 0.75
