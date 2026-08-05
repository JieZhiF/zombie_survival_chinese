-- ============================================================================
-- status_ghost_ffemitter.lua - 火焰喷射器建造预览（幽灵实体，共享）
-- 负责：声明火焰喷射器（prop_ffemitter）建造时的放置预览参数——预览
--       模型、放置角度修正、互斥检测范围与方向指示箭头
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型（附着于拥有者，跟随视线移动）
ENT.Type = "anim"
-- 继承通用建造预览基类，复用放置校验与渲染逻辑
ENT.Base = "status_ghost_base"

-- 预览模型：荧光灯管造型（对应火焰喷射器本体外观）
ENT.GhostModel = Model("models/props_lab/lab_flourescentlight002b.mdl")
-- 命中世界表面时施加的模型角度修正
ENT.GhostRotation = Angle(0, 0, 0)
-- 未命中任何物体（悬空预览）时施加的模型角度修正
ENT.GhostNoTraceRot = Angle(90, 0, 0)
-- 实际要建造的实体类名（放置校验与同类互斥检测的依据）
ENT.GhostEntity = "prop_ffemitter"
-- 关联的建造武器（用于取消建造等交互）
ENT.GhostWeapon = "weapon_zs_ffemitter"
-- 放置检测半径：范围内已存在同类实体则禁止放置
ENT.GhostDistance = 70
-- 命中点沿法线向内偏移的距离，避免模型与墙面重叠
ENT.GhostHitNormalOffset = 2.9
-- 模型旋转轴函数（绕视线方向的该轴旋转对齐）
ENT.GhostRotateFunction = "Forward"
-- 不做路障内嵌检测（允许紧贴路障放置）
ENT.GhostNotBarricadeProp = true
-- 显示放置方向指示箭头
ENT.GhostArrow = true
-- 指示箭头朝上（对应火焰向上喷射的方向）
ENT.GhostArrowUp = true
