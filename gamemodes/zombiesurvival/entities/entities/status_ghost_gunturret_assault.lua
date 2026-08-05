-- ============================================================================
-- status_ghost_gunturret_assault - 突击炮塔放置幽灵预览状态实体（共享端）
-- 负责：声明放置后生成的实际实体与对应武器
-- ============================================================================

-- 同时加载到客户端（幽灵预览需要客户端渲染与交互）
AddCSLuaFile()

-- 实体类型：动画实体
ENT.Type = "anim"
-- 母类：炮塔放置幽灵基类（负责预览渲染与放置交互）
ENT.Base = "status_ghost_gunturret"

-- 放置时生成的实际实体：突击炮塔
ENT.GhostEntity = "prop_gunturret_assault"
-- 放置后切换到的对应武器：突击炮塔武器
ENT.GhostWeapon = "weapon_zs_gunturret_assault"
