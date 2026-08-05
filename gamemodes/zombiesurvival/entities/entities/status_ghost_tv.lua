-- ============================================================================
-- status_ghost_tv.lua - 电视机放置虚影（共享）
-- 负责：声明电视虚影的模型/旋转/距离等放置参数（判定逻辑在 status_ghost_base）
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 基类为放置虚影基类（提供有效性判定、跟随放置与绘制）
ENT.Base = "status_ghost_base"

-- 虚影模型：老式显像管电视
ENT.GhostModel = Model("models/props_c17/tv_monitor01.mdl")
-- 虚影模型初始旋转角
ENT.GhostRotation = Angle(0, 0, 0)
-- 无碰撞体时的回退旋转角（贴墙放置时使用）
ENT.GhostNoTraceRot = Angle(0, 180, 0)
-- 放置命中法线偏移量（初始定义，后被下方值覆盖）
ENT.GhostHitNormalOffset = 0
-- 放置成功后生成的实体类：电视
ENT.GhostEntity = "prop_tv"
-- 对应武器类（持有该武器时虚影才存在）
ENT.GhostWeapon = "weapon_zs_tv"
-- 不要求平坦地面（可贴在任意表面）
ENT.GhostFlatGround = false
-- 距放置者的最大放置距离
ENT.GhostDistance = 32
-- 放置命中法线偏移量：沿表面法线推出 1 单位（避免嵌入墙体）
ENT.GhostHitNormalOffset = 1
-- 显示朝向箭头指示器（指示放置朝向）
ENT.GhostArrow = true
-- 箭头不朝上（贴墙放置时指向水平方向）
ENT.GhostArrowUp = false
