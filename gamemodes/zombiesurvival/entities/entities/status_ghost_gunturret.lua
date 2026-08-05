-- ============================================================================
-- status_ghost_gunturret.lua - 炮台放置虚影（共享）：预览炮台摆放位置
-- 负责：声明炮台虚影的模型/旋转/距离等放置参数（判定逻辑在 status_ghost_base）
-- ============================================================================
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 基类为放置虚影基类（提供有效性判定、跟随放置与绘制）
ENT.Base = "status_ghost_base"

-- 虚影模型：地面炮台
ENT.GhostModel = Model("models/Combine_turrets/Floor_turret.mdl")
-- 虚影模型初始旋转角
ENT.GhostRotation = Angle(270, 0, 0)
-- 放置成功后生成的实体类
ENT.GhostEntity = "prop_gunturret"
-- 对应武器类（持有该武器时虚影才存在）
ENT.GhostWeapon = "weapon_zs_gunturret"
-- 距放置者的最大放置距离
ENT.GhostDistance = 130
-- 不要求平坦地面（允许放置在斜坡上）
ENT.GhostFlatGround = false
-- 虚影实体类前缀（检测附近同类实体以限制数量）
ENT.GhostEntityWildCard = "prop_gunturret"
-- 不检查虚影是否嵌入障碍物道具（炮台允许放在障碍物上）
ENT.GhostNotBarricadeProp = true
