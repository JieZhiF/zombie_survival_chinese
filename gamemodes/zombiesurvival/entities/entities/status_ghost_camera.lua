-- ============================================================================
-- status_ghost_camera.lua - 摄像机幽灵放置状态（共享单文件）
-- 负责：定义放置摄像机的幽灵预览参数：模型、朝向、距离与放置实体/武器
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status_ghost_base"

-- 幽灵预览模型：吸顶灯（旋转 90 度后近似摄像机造型）
ENT.GhostModel = Model("models/props_c17/light_domelight02_off.mdl")
ENT.GhostRotation = Angle(90, 0, 0)
ENT.GhostNoTraceRot = Angle(270, 0, 0)
-- 幽灵贴墙偏移：无需偏移（贴合表面放置）
ENT.GhostHitNormalOffset = 0
-- 实际放置的实体与对应武器
ENT.GhostEntity = "prop_camera"
ENT.GhostWeapon = "weapon_zs_camera"
-- 不要求水平地面，可放置于任意表面
ENT.GhostFlatGround = false
-- 与目标表面保持 32 单位距离
ENT.GhostDistance = 32
-- 显示放置方向箭头（指向上方）
ENT.GhostArrow = true
ENT.GhostArrowUp = true
