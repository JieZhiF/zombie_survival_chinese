-- ============================================================================
-- status_ghost_zapper_arc - 电弧陷阱放置预览状态
-- 负责：人类玩家持有电弧陷阱武器（weapon_zs_zapper_arc）时，
--       显示放置位置的幽灵预览实体（prop_zapper_arc）
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 实体类型：动画实体，继承电弧幽灵基类
ENT.Type = "anim"
ENT.Base = "status_ghost_zapper"

-- 实际放置时生成的实体
ENT.GhostEntity = "prop_zapper_arc"
-- 关联的武器（放置该武器的玩家获得此状态）
ENT.GhostWeapon = "weapon_zs_zapper_arc"
