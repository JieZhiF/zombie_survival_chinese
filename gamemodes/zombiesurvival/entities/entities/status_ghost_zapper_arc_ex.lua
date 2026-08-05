-- ============================================================================
-- status_ghost_zapper_arc_ex.lua - 电弧特斯拉塔（扩展）放置虚影（共享）
-- 负责：声明电弧塔虚影对应的实体与武器（判定/绘制逻辑继承自
--       status_ghost_zapper 与 status_ghost_base）
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 基类为特斯拉塔虚影类（提供模型、放置距离等参数及放置逻辑）
ENT.Base = "status_ghost_zapper"

-- 放置成功后生成的实体类：电弧特斯拉塔（扩展版）
ENT.GhostEntity = "prop_zapper_arc_ex"
-- 对应武器类（持有该武器时虚影才存在）
ENT.GhostWeapon = "weapon_zs_zapper_arc_ex"
