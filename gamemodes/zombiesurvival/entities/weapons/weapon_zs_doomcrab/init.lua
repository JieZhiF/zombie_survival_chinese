-- ============================================================================
-- weapon_zs_doomcrab/init.lua - 僵尸近战武器「末日蟹钳」（Doomcrab）服务器端
-- 负责：抛射骨块远程攻击与重击地面（范围伤害+震屏+扬尘）逻辑
-- ============================================================================

INC_SERVER()

-- ==== ThrowGibs - 远程攻击：向瞄准方向抛出一块旋转的骨块投射物 ====
function SWEP:ThrowGibs()
	local owner = self:GetOwner()

	-- 记录玩家最近一次远程攻击时间（供 AI/冷却判断）
	owner.LastRangedAttack = CurTime()

	-- 生成骨块投射物（projectile_doomcrab），带随机旋转
	local ent = ents.Create("projectile_doomcrab")
	if ent:IsValid() then
		ent:SetPos(owner:GetShootPos())
		ent:SetAngles(AngleRand())
		ent:SetOwner(owner)
		ent:Spawn()

		-- 以 600 单位/秒的速度沿瞄准方向抛出，并附加随机旋转角速度
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(owner:GetAimVector() * 600)
			phys:AddAngleVelocity(VectorRand() * 360)
		end
	end
end

-- ==== PoundAttackProcess - 重击攻击结算：延迟 0.4 秒后造成范围伤害 ====
function SWEP:PoundAttackProcess()
	-- 重击起手后 0.4 秒才生效
	if CurTime() < self.PoundAttackStart + 0.4 then return end

	local owner = self:GetOwner()
	local pos = owner:GetPos() + Vector(0, 0, 2)

	owner:LagCompensation(true)

	-- 播放地面破裂音效与屏幕震动
	owner:EmitSound("physics/concrete/concrete_break3.wav", 77, 70)

	util.ScreenShake(pos, 5, 5, 1, 300)

	-- 生成冲击扬尘特效（对所有人可见、强制创建）
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0, 0, 1))
	util.Effect("ThumperDust", effectdata, true, true)

	-- 短暂无敌后造成双重范围伤害（内圈 112、外圈 22），避免误伤自身
	owner:GodEnable()
	util.BlastDamageEx(self, owner, pos, 112, 25, DMG_CLUB)
	util.BlastDamageEx(self, owner, pos, 22, 40, DMG_CLUB)
	owner:GodDisable()

	owner:LagCompensation(false)
end
