-- ============================================================================
-- status_ghost_repairfield - 修复场放置预览状态
-- 负责：人类玩家持有修复场武器（weapon_zs_repairfield）时，
--       显示放置位置的幽灵预览实体（prop_repairfield）
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 实体类型：动画实体，继承幽灵放置基类
ENT.Type = "anim"
ENT.Base = "status_ghost_base"

-- 幽灵预览使用的模型（烟囱管道模型作为修复场的占位外观）
ENT.GhostModel = Model("models/props/de_nuke/smokestack01.mdl")
-- 幽灵模型的旋转角度（绕 X 轴旋转 270 度使模型竖直）
ENT.GhostRotation = Angle(270, 0, 0)
-- 实际放置时生成的实体
ENT.GhostEntity = "prop_repairfield"
-- 关联的武器（放置该武器的玩家获得此状态）
ENT.GhostWeapon = "weapon_zs_repairfield"
-- 幽灵放置的最大距离
ENT.GhostDistance = 120
-- 幽灵贴附表面时离命中点的高度偏移
ENT.GhostHitNormalOffset = 12
-- 幽灵模型的缩放比例
ENT.GhostScale = 0.55
-- 不允许放置在路障类道具上（放置面校验用）
ENT.GhostNotBarricadeProp = true
-- 已放置实体的通配符名（用于查询同类实体数量限制）
ENT.GhostEntityWildCard = "prop_repairfield"
