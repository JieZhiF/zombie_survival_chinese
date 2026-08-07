-- ============================================================================
-- status_ghost_gunturret_pulse.lua - 脉冲炮塔放置预览（幽灵实体）
-- 负责：玩家手持脉冲炮塔武器瞄准地面时显示半透明预览，落点合法则生成真实炮塔
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 继承通用幽灵炮塔预览基类，复用合法性检测、线框材质与跟随渲染逻辑
ENT.Base = "status_ghost_gunturret"

-- 放置确认后生成的真实炮塔实体
ENT.GhostEntity = "prop_gunturret_pulse"
-- 仅当玩家携带该武器时才显示此预览
ENT.GhostWeapon = "weapon_zs_gunturret_freeze"