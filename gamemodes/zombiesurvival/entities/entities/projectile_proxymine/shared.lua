-- ============================================================================
-- shared.lua - 感应地雷投射物（共享）：声明实体类型与爆炸/武装参数
-- 负责：定义地雷的引爆延迟、武装时间以及爆炸时间的 DT 存取
-- ============================================================================
-- 动画实体类型（带物理模拟的投射物）
ENT.Type = "anim"

-- 探测到僵尸后到引爆的延迟（秒）
ENT.ExplosionDelay = 0.7
-- 落地后需要经过的武装时间（秒），武装前不会引爆
ENT.ArmTime = 8

-- 第 0 波（准备阶段）期间不伤害场景道具
ENT.NoPropDamageDuringWave0 = true

-- ==== ShouldNotCollide - 碰撞过滤：玩家不阻挡地雷飞行 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer()
end

-- ==== SetExplodeTime - 写入预定引爆时间（DT 同步到客户端） ====
function ENT:SetExplodeTime(time)
	self:SetDTFloat(0, time)
end

-- ==== GetExplodeTime - 读取预定引爆时间（0 表示尚未触发） ====
function ENT:GetExplodeTime()
	return self:GetDTFloat(0)
end
