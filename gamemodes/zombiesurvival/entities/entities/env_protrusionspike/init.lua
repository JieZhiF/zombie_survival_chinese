-- ============================================================================
-- env_protrusionspike/init.lua - 突起尖刺环境实体（服务器端）
-- 负责：生成时立刻对周围僵尸造成范围伤害（默认 113.4，可覆盖）与
--       寒冷型腿部减速，随后在 0.75 秒内消失（快速突刺的机关效果）
-- ============================================================================

-- 服务器端加载入口（INC_SERVER 系列约定写法）
INC_SERVER()

-- ==== Initialize - 尖刺初始化 ====
function ENT:Initialize()
	-- 机关尖刺不绘制阴影
	self:DrawShadow(false)
	-- 使用岩石碎片模型配合半透明着色表现尖刺
	self:SetModel("models/props_wasteland/rockcliff06d.mdl")
	self:SetMaterial("models/shadertest/shader2")
	self:SetColor(Color(30, 150, 255, 255))
	-- 无实体碰撞（仅作为伤害区域表现，不阻挡移动）
	self:PhysicsInit(SOLID_NONE)

	-- 生成瞬间立即触发范围伤害
	self:Explode()

	-- 0.75 秒后销毁（突刺短暂显现后收回）
	self:Fire("kill", "", 0.75)
end

-- ==== Explode - 范围伤害结算 ====
-- 以尖刺上方 36 单位为圆心，对范围内的存活僵尸造成伤害与减速
function ENT:Explode()
	local pos = self:GetPos()
	local owner = self:GetOwner()
	local rad = 36

	-- 收集爆炸范围内的实体
	for _, ent in pairs(util.BlastAlloc(self, owner, pos + Vector(0, 0, rad), rad)) do
		-- 仅伤害存活的僵尸，且需通过伤害门槛（PlayerShouldTakeDamage）、排除施放者自己
		if ent:IsValidLivingZombie() and gamemode.Call("PlayerShouldTakeDamage", ent, owner) and ent ~= owner then
			-- 造成溺水类型的范围伤害（默认 113.4，可由 Damage 属性覆盖）
			ent:TakeSpecialDamage(self.Damage or 113.4, DMG_DROWN, owner, self, pos)
			-- 附加寒冷型腿部减速
			ent:AddLegDamageExt(18, owner, self, SLOWTYPE_COLD)
		end
	end
end
