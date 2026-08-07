-- ============================================================================
-- shared.lua - 冰冻炮塔（共享）：定义炮塔平衡参数与开火音效
-- 负责：冰冻炮塔的冷冻速率/弹药等参数配置，以及开火音效的重写
-- ============================================================================

-- 继承普通炮塔基类，复用索敌、转向、部署与放置校验逻辑
ENT.Base = "prop_gunturret"

-- 对应的放置武器：玩家携带该武器时才能放置此炮塔
ENT.SWEP = "weapon_zs_gunturret_freeze"

-- 弹药类型（与弹药箱/补给系统匹配的标识）
ENT.AmmoType = "pulse"
-- 照射节拍（秒）：高频节拍，冷冻平滑累积
ENT.FireDelay = 0.05
-- 每拍消耗弹药数（小数累积，由服务端累积取整；每秒消耗 = AmmoPerShot / FireDelay）
ENT.AmmoPerShot = 0.25
-- 冰冻累积速率（秒/秒）：锁定目标期间每秒累积的冰冻时长
-- （每拍施加 FreezeRate × FireDelay，最终值按僵尸抗性缩放）
ENT.FreezeRate = 3
-- 冷冻光束射程（单位）
ENT.BeamRange = 512
-- 不使用循环开火音效（冰冻炮塔每次开火单独播放音效）
ENT.PlayLoopingShootSound = false
-- 索敌距离（单位），超出此范围的僵尸不攻击
ENT.SearchDistance = 512
-- 最大弹药量
ENT.MaxAmmo = 300

-- ==== PlayShootSound - 重写开火音效：玻璃碎裂冰冻音（节流，避免高频轰炸） ====
function ENT:PlayShootSound()
	if CurTime() < (self.NextShootSound or 0) then return end
	self.NextShootSound = CurTime() + 0.3

	self:EmitSound("physics/glass/glass_impact_bullet"..math.random(4)..".wav", 70, math.random(80, 90), 0.86, CHAN_AUTO)
end