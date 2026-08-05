-- ============================================================================
-- prop_manhack_saw/shared.lua - 电锯人形机器人（共享定义）
-- 负责：定义电锯机械体的基础属性：模型、血量、飞行/转向参数、
--       撞击伤害与反弹、高速自伤等平衡数值
-- ============================================================================
ENT.Type = "anim"
ENT.Base = "prop_manhack"

-- 实体模型：manhack 机械飞虫模型
ENT.Model = "models/manhack.mdl"
-- 命中判定半径（单位）
ENT.HitBoxSize = 12.5
-- 物理质量
ENT.Mass = 80
-- 生成时携带的武器（电锯）
ENT.WeaponClass = "weapon_zs_manhack_saw"
-- 对应的遥控器武器
ENT.ControllerClass = "weapon_zs_manhackcontrol_saw"
-- 弹药类型
ENT.AmmoType = "manhack_saw"

-- 飞行加速度
ENT.Acceleration = 219
-- 最大飞行速度
ENT.MaxSpeed = 200
-- 转向速度
ENT.TurnSpeed = 30
-- 闲置状态下的空气阻力系数（用于减速）
ENT.IdleDrag = 0.2

-- 最大生命值
ENT.MaxHealth = 170
-- 两次撞击伤害的最小间隔（秒）
ENT.HitCooldown = 0.15
-- 撞击对目标造成的伤害
ENT.HitDamage = 22.5
-- 击中肉体时的反弹速度
ENT.BounceFleshVelocity = 30
-- 击中墙壁/地面时的反弹速度
ENT.BounceVelocity = 75
-- 触发自伤所需的最低飞行速度比例
ENT.SelfDamageSpeed = 0.9
-- 自伤伤害倍率（超速撞击时按该比例对自身造成伤害）
ENT.SelfDamageMul = 0.08
