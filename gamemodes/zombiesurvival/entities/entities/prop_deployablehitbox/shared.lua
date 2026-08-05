-- ============================================================================
-- prop_deployablehitbox/shared.lua - 可部署物命中箱（共享定义）
-- 负责：作为可部署物（炮塔/特斯拉塔等）的隐藏受击盒体：忽略近战/子弹/
--       射线直击，将伤害转交给父实体；命中箱可打包收起
-- ============================================================================

-- 实体类型：动画实体（不渲染）
ENT.Type = "anim"

-- 忽略近战攻击（伤害转发由父实体处理）
ENT.IgnoreMelee = true
-- 忽略子弹命中
ENT.IgnoreBullets = true
-- 忽略普通射线命中（避免占用命中判定）
ENT.IgnoreTraces = true

-- 允许打包收起（按使用键收起整个可部署物）
ENT.CanPackUp = true

-- 碰撞盒最小角（相对自身原点）
ENT.BoxMin = Vector(-8, -8, 0)
-- 碰撞盒最大角
ENT.BoxMax = Vector(8, 8, 8)

-- ==== ShouldNotCollide - 碰撞豁免：人类投射物/玩家/武器/无碰撞组实体不碰撞 ====
function ENT:ShouldNotCollide(ent)
	-- 人类玩家射出的投射物穿体而过（避免误挡友军火力）
	if ent:IsProjectile() then
		local owner = ent:GetOwner()
		if owner:IsValid() and owner:IsHuman() then return true end
	end

	-- 玩家、掉落武器与无碰撞组实体（装饰/特效）均不与其碰撞
	local colgroup = ent:GetCollisionGroup()
	if colgroup == COLLISION_GROUP_PLAYER or colgroup == COLLISION_GROUP_WEAPON or colgroup == COLLISION_GROUP_NONE then
		return true
	end

	return false
end

-- ==== GetObjectOwner - 返回真正拥有者：转发父实体（可部署物本体）的拥有者 ====
function ENT:GetObjectOwner()
	local parent = self:GetParent()
	if parent:IsValid() then return parent:GetObjectOwner() end

	return NULL
end
