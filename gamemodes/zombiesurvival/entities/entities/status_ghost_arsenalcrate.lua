-- ============================================================================
-- status_ghost_arsenalcrate - 军械箱放置幽灵预览状态实体（共享端）
-- 负责：配置幽灵预览的模型/旋转/放置距离，并声明放置后生成的实体与对应武器
-- ============================================================================

-- 同时加载到客户端（幽灵预览需要客户端渲染与交互）
AddCSLuaFile()

-- 实体类型：动画实体
ENT.Type = "anim"
-- 母类：幽灵状态基类（负责预览渲染与放置交互）
ENT.Base = "status_ghost_base"

-- 幽灵预览模型：军械箱木箱模型
ENT.GhostModel = Model("models/Items/item_item_crate.mdl")
-- 幽灵预览模型的旋转角度
ENT.GhostRotation = Angle(270, 0, 0)
-- 命中法线偏移量（贴墙/贴地放置时沿法线方向的位移补偿）
ENT.GhostHitNormalOffset = 0
-- 放置时生成的实际实体：军械箱
ENT.GhostEntity = "prop_arsenalcrate"
-- 放置后切换到的对应武器：军械箱武器
ENT.GhostWeapon = "weapon_zs_arsenalcrate"
-- 幽灵预览与玩家之间的最大放置距离
ENT.GhostDistance = 128
-- 限制放置的法线阈值（命中面法线角度超过该值不允许放置）
ENT.GhostLimitedNormal = 0.75
