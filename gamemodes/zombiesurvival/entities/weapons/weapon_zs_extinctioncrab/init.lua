-- ============================================================================
-- weapon_zs_extinctioncrab/init.lua - 灭绝螃蟹（服务器端逻辑）
-- 负责：爪击碎块投掷与落地践踏的范围伤害处理
-- ============================================================================
INC_SERVER()

-- ==== ThrowGibs - 爪击生效：投掷碎块弹体造成伤害 ====
function SWEP:ThrowGibs()
	local owner = self:GetOwner()

	-- 记录最近一次远程攻击时间（供母本逻辑判断）
	owner.LastRangedAttack = CurTime()

	-- 生成碎块弹体实体
	local ent = ents.Create("projectile_extinctioncrab")
	if ent:IsValid() then
		ent:SetPos(owner:GetShootPos())
		ent:SetAngles(AngleRand())
		ent:SetOwner(owner)
		ent:Spawn()

		-- 赋予弹体初速度与随机旋转
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(owner:GetAimVector() * 600)
			phys:AddAngleVelocity(VectorRand() * 360)
		end
	end
end

-- ==== PoundAttackProcess - 落地践踏：对周围造成震地伤害 ====
function SWEP:PoundAttackProcess()
	-- 落地后 0.4 秒内不触发
	if CurTime() < self.PoundAttackStart + 0.4 then return end

	local owner = self:GetOwner()
	local pos = owner:GetPos() + Vector(0, 0, 2)

	-- 开启延迟补偿，保证伤害判定准确
	owner:LagCompensation(true)

	-- 播放碎裂音效与屏幕震动
	owner:EmitSound("physics/concrete/concrete_break3.wav", 77, 70)

	util.ScreenShake(pos, 5, 5, 1, 300)

	-- 生成扬尘特效
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0, 0, 1))
	util.Effect("ThumperDust", effectdata, true, true)

	-- 两段范围伤害：近圈重击 + 远圈轻伤（期间开启无敌防止自伤）
	owner:GodEnable()
	util.BlastDamageEx(self, owner, pos, 112, 25, DMG_CLUB)
	util.BlastDamageEx(self, owner, pos, 22, 40, DMG_CLUB)
	owner:GodDisable()

	owner:LagCompensation(false)
end
