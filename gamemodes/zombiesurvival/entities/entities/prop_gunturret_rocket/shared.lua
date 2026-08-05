-- ============================================================================
-- prop_gunturret_rocket/shared.lua - 火箭炮塔（共享属性）
-- 负责：定义火箭炮塔的武器/弹药/伤害/血量配置及开火音效，继承通用炮塔 prop_gunturret
-- ============================================================================

-- 继承通用炮塔基类（含生命、弹药、瞄准、自动开火等逻辑）
ENT.Base = "prop_gunturret"

-- 对应的炮塔武器（火箭炮）
ENT.SWEP = "weapon_zs_gunturret_rocket"

-- 弹药类型：冲击地雷（与武器共用弹药池）
ENT.AmmoType = "impactmine"
-- 两次开火间隔（秒）
ENT.FireDelay = 2
-- 单次齐射弹数
ENT.NumShots = 1
-- 单发火箭伤害
ENT.Damage = 97
-- 不循环播放开火音效（每次单独播放）
ENT.PlayLoopingShootSound = false
-- 发射散布角（度）
ENT.Spread = 0.75
-- 弹药上限
ENT.MaxAmmo = 30
-- 炮塔最大生命值
ENT.MaxHealth = 225
-- 每次补给（使用键）给予的弹药量
ENT.AmmoGivePerUse = 5

-- ==== PlayShootSound - 播放开火音效：高频啸声 + 榴弹发射声叠加 ====
function ENT:PlayShootSound()
	self:EmitSound("weapons/stinger_fire1.wav", 80, math.random(148, 153), 0.8)
	self:EmitSound("weapons/grenade_launcher1.wav", 80, math.random(86, 92), 0.7, CHAN_WEAPON + 20)
end
