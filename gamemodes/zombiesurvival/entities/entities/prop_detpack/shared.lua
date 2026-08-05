-- ============================================================================
-- shared.lua - 遥控炸药包（共享）
-- 负责：定义炸药包的属性（可收起、不可加固、爆炸延迟/布防时间）与数据访问接口
-- ============================================================================
-- 基于 anim 实体类型
ENT.Type = "anim"

-- 允许右键收起
ENT.CanPackUp = true
-- 收起所需时间（秒）
ENT.PackUpTime = 2

-- 不可被钉子解冻、不可被钉子加固
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

-- 第 0 波（准备阶段）不受道具伤害，防止开局误炸
ENT.NoPropDamageDuringWave0 = true

-- 引爆后到实际爆炸的延迟（秒）
ENT.ExplosionDelay = 1.5
-- 布防时间（秒）：放置后这段时间内无法引爆
ENT.ArmTime = 10

-- ==== GetExplodeTime - 读取引爆时间（DT 浮点槽 0）====
-- 0 表示尚未被引爆
function ENT:GetExplodeTime()
	return self:GetDTFloat(0)
end

-- ==== SetObjectOwner - 设置放置者（复用实体 Owner）====
function ENT:SetObjectOwner(owner)
	self:SetOwner(owner)
end

-- ==== GetObjectOwner - 读取放置者（复用实体 Owner）====
function ENT:GetObjectOwner()
	return self:GetOwner()
end
