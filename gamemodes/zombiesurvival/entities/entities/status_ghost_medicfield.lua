-- ============================================================================
-- status_ghost_medicfield.lua - 医疗场幽灵放置预览（共享）
-- 负责：配置医疗场（prop_medicfield）放置时的幽灵预览参数：预览模型、
--       旋转、放置距离、缩放及非路障属性标记
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型，继承幽灵放置预览基类 status_ghost_base
ENT.Type = "anim"
ENT.Base = "status_ghost_base"

-- 预览模型：使用烟囱模型作为医疗场的占位外形
ENT.GhostModel = Model("models/props/de_nuke/smokestack01.mdl")
-- 预览模型的旋转角度
ENT.GhostRotation = Angle(270, 0, 0)
-- 实际放置时生成的实体类名
ENT.GhostEntity = "prop_medicfield"
-- 触发本预览的幽灵武器（手持该武器时显示预览）
ENT.GhostWeapon = "weapon_zs_medicfield"
-- 预览放置的最大距离（以玩家为基准）
ENT.GhostDistance = 120
-- 命中点法线方向的偏移量，使预览紧贴表面
ENT.GhostHitNormalOffset = 12
-- 预览模型缩放比例
ENT.GhostScale = 0.55
-- 标记：不可放置在路障上（与普通路障物区分）
ENT.GhostNotBarricadeProp = true
-- 通配符匹配：与同名实体比较时使用的类名
ENT.GhostEntityWildCard = "prop_medicfield"
