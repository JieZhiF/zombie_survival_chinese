-- ============================================================================
-- shared.lua - 脉冲炮塔（共享）：定义炮塔平衡参数与开火音效
-- 负责：脉冲炮塔的伤害/射速/弹药等参数配置，以及开火音效的重写
-- ============================================================================

-- 继承普通炮塔基类，复用索敌、转向、部署与放置校验逻辑
ENT.Base = "prop_gunturret"

-- 对应的放置武器：玩家携带该武器时才能放置此炮塔
ENT.SWEP = "weapon_zs_gunturret_pulse"

-- 弹药类型（与弹药箱/补给系统匹配的标识）
ENT.AmmoType = "pulse"
-- 开火间隔（秒）
ENT.FireDelay = 0.20
-- 每次开火发射的炮弹数量
ENT.NumShots = 1
-- 单发炮弹基础伤害
ENT.Damage = 30
-- 不使用循环开火音效（脉冲炮塔每次开火单独播放音效）
ENT.PlayLoopingShootSound = false
-- 炮弹散射角度（度），越大弹道越分散
ENT.Spread = 2
-- 索敌距离（单位），超出此范围的僵尸不攻击
ENT.SearchDistance = 300
-- 最大弹药量
ENT.MaxAmmo = 300

-- ==== PlayShootSound - 重写开火音效：播放电磁轨道炮的充能爆发音效 ====
function ENT:PlayShootSound()
	self:EmitSound("weapons/zs_rail/rail.wav", 70, math.random(80, 90), 0.86, CHAN_AUTO)
end