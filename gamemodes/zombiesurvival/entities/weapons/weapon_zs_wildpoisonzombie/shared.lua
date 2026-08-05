-- ============================================================================
-- weapon_zs_wildpoisonzombie/shared.lua - 野生毒僵尸武器（共享端）
-- 负责：定义毒僵尸近战伤害、毒液投掷速度与攻击音效
-- ============================================================================

-- 定义母本类引用（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_poisonzombie")

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_wildpoisonzombie")

-- 近战攻击伤害
SWEP.MeleeDamage = 35
-- 毒液弹投掷速度
SWEP.PoisonThrowSpeed = 420

-- ==== PlayAttackSound - 播放攻击音效 ====
function SWEP:PlayAttackSound()
	-- 毒僵尸警告音（2 种随机，低音调）
	self:EmitSound("npc/zombie_poison/pz_warn"..math.random(2)..".wav", 74, math.random(88, 95), 0.5, CHAN_AUTO)
	-- 蚁狮守卫愤怒音（3 种随机，中音调）
	self:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 74, math.random(112, 115), 0.5, CHAN_AUTO)
end
