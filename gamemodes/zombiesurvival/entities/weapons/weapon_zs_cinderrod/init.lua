-- ============================================================================
-- init.lua - 余烬棒（爆破型能量武器）服务端逻辑
-- 负责：命中点溅射爆破与点燃结算、开火时对自身产生爆炸（自伤机制）
-- ============================================================================

-- 服务端 realm 守卫：仅服务端加载本文件（替代 if SERVER then 写法）
INC_SERVER()

-- ==== BulletCallback - 子弹命中回调：命中点溅射爆破并概率点燃目标 ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	-- 仅人类玩家射出的子弹生效
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then
		local pos = tr.HitPos
		-- 在命中点造成 82 半径爆炸，伤害为子弹伤害的 75%
		for ent, dmg in pairs(util.BlastDamageExAlloc(attacker:GetActiveWeapon(), attacker, pos, 82, dmginfo:GetDamage() * 0.75, DMG_ALWAYSGIB)) do
			-- 25% 概率点燃受波及的亡灵（或射手自己），燃烧时长与所受伤害成正比
			if math.random(4) == 1 and ent:IsValidLivingPlayer() and (ent:Team() == TEAM_UNDEAD or ent == attacker) then
				ent:Ignite(dmg / 14)
				ent:SetNWFloat("FireDieTime", CurTime() + dmg / 14)
				-- 把附着在该目标身上的火焰实体记到射手名下（击杀归属）
				for __, fire in pairs(ents.FindByClass("entityflame")) do
					if fire:IsValid() and fire:GetParent() == ent then
						fire:SetOwner(attacker)
						fire:SetPhysicsAttacker(attacker)
						fire.AttackerForward = attacker
					end
				end
			end
		end

		-- 播放命中点爆炸特效
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("Explosion", effectdata, true, true)
	end
end

-- ==== PrimaryAttack - 开火：发射余烬弹后对自身位置产生爆炸（自伤） ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	-- 设置开火冷却
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	-- 播放音效、消耗弹药并按扩散发射弹丸
	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	-- 在持枪者脚下产生 50 半径、55 伤害的爆炸（会伤及自身，需拉开距离使用）
	local owner = self:GetOwner()
	if owner:IsValid() then
		local pos = owner:GetPos()

		util.BlastDamagePlayer(self, owner, pos, 50, 55, DMG_ALWAYSGIB)

		-- 播放自身位置爆炸特效
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("Explosion", effectdata, true, true)
	end
end
