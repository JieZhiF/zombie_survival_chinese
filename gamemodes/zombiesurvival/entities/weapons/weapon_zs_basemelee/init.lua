INC_SERVER()

AddCSLuaFile("animations.lua")

----------------------------------------------------
-- 处理近战命中实体时的逻辑
-- tr                -> TraceResult 命中信息
-- hitent            -> 被命中的实体
-- damagemultiplier  -> 伤害倍率
----------------------------------------------------

-- 命中实体（主要用于物理交互）
function SWEP:ServerMeleeHitEntity(tr, hitent, damagemultiplier)
	if not IsValid(hitent) then return end

	-- 如果目标是可移动的物理对象，设置攻击者
	if hitent:GetMoveType() == MOVETYPE_VPHYSICS then
		local phys = hitent:GetPhysicsObject()
		if IsValid(phys) and phys:IsMoveable() then
			hitent:SetPhysicsAttacker(self:GetOwner())
		end
	end
end

-- 命中实体后（命中结算阶段，处理特殊效果）
function SWEP:ServerMeleePostHitEntity(tr, hitent, damagemultiplier)
	local owner = self:GetOwner()
	if not IsValid(owner) or not IsValid(hitent) then return end

	-- 检查玻璃武器技能是否生效
	if owner:IsSkillActive(SKILL_GLASSWEAPONS) 
		and not self.NoGlassWeapons
		and owner.GlassWeaponShouldBreak
		and hitent:IsPlayer() then
		
		-- 播放破碎特效
		local effectdata = EffectData()
		effectdata:SetOrigin(owner:EyePos())
		effectdata:SetEntity(owner)
		util.Effect("weapon_shattered", effectdata, true, true)

		-- 移除当前武器（玻璃武器碎裂）
		owner:StripWeapon(self:GetClass())
	end
end

-- 命中血肉目标的额外效果（溅血）
function SWEP:ServerHitFleshEffects(hitent, tr, damagemultiplier)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local damage = (self.MeleeDamage or 25) * (damagemultiplier or 1)

	-- 如果击中的是友军，则不触发血液效果
	if IsValid(hitent) and hitent:IsPlayer() and hitent:Team() == owner:Team() then return end

	-- 生成血液效果（位置、方向、数量根据伤害值变化）
	util.Blood(
		tr.HitPos, 
		math.Rand(damage * 0.25, damage * 0.6),                      -- 血液数量
		(tr.HitPos - owner:GetShootPos()):GetNormalized(),           -- 喷射方向
		math.min(400, math.Rand(damage * 6, damage * 12)),           -- 最大距离限制
		true                                                         -- 永久血迹
	)
end
