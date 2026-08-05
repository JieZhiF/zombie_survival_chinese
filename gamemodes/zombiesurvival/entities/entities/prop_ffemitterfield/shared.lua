-- ============================================================================
-- prop_ffemitterfield - 力场区域实体（共享端）
-- 负责：声明实体属性与网络变量，定义投射物/玩家/武器穿过的碰撞豁免规则
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- 可打包收起；打包所需时间（秒）
ENT.CanPackUp = true
ENT.PackUpTime = 3

-- 不可被钉子解冻；不可钉上钉子
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true
-- 免疫子弹/近战/射线伤害（伤害统一由发射器本体承担）
ENT.IgnoreBullets = true
ENT.IgnoreMelee = true
ENT.IgnoreTraces = true
-- 标记：命中本区域的投射物其状态 AOE 效果会被熄灭（如毒云被力场吸收）
ENT.FizzleStatusAOE = true

-- 网络变量：关联的发射器实体引用（类型 Entity，网络槽 0）
AccessorFuncDT(ENT, "Emitter", "Entity", 0)
-- 网络变量：上次受击时间戳（类型 Float，网络槽 0）
AccessorFuncDT(ENT, "LastDamaged", "Float", 0)

-- ==== ShouldNotCollide - 定义碰撞豁免：人类投射物、弹药耗尽僵尸的投射物、玩家/武器/默认碰撞组均直接穿过 ====
function ENT:ShouldNotCollide(ent)
	if ent:IsProjectile() then
		local owner = ent:GetOwner()
		if owner:IsValid() then
			-- 人类发射的投射物直接穿过；僵尸投射物仅在发射器弹药耗尽时穿过
			if owner:IsHuman() then
				return true
			elseif self:GetEmitter():IsValid() and self:GetEmitter().GetAmmo and self:GetEmitter():GetAmmo() < 1 then
				return true
			end
		end
	end

	-- 玩家、武器与默认碰撞组实体不产生碰撞（力场本体可被自由穿越）
	local colgroup = ent:GetCollisionGroup()
	if colgroup == COLLISION_GROUP_PLAYER or colgroup == COLLISION_GROUP_WEAPON or colgroup == COLLISION_GROUP_NONE then
		return true
	end

	return false
end
