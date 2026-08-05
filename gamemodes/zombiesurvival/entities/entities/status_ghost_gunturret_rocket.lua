-- ============================================================================
-- status_ghost_gunturret_rocket.lua - 火箭炮塔放置虚影（共享）
-- 负责：声明火箭炮塔虚影对应的实体与武器（判定/绘制逻辑继承自
--       status_ghost_gunturret 与 status_ghost_base）
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 基类为炮塔虚影类（提供模型、放置距离等参数及放置逻辑）
ENT.Base = "status_ghost_gunturret"

-- 放置成功后生成的实体类：火箭炮塔
ENT.GhostEntity = "prop_gunturret_rocket"
-- 对应武器类（持有该武器时虚影才存在）
ENT.GhostWeapon = "weapon_zs_gunturret_rocket"
