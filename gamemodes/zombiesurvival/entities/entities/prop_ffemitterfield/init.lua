-- ============================================================================
-- prop_ffemitterfield - 力场区域实体（服务端）
-- 负责：拦截来袭投射物，以发射器弹药抵消伤害并给拥有者加分，弹药耗尽后力场失能
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化模型与物理，启用自定义碰撞检测并设为可穿透碰撞组 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/props_junk/TrashDumpster02b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetCustomCollisionCheck(true)
	self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	-- 固定力场本体，不参与物理运动
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
end

-- ==== OnTakeDamage - 仅投射物伤害计入：以发射器弹药抵消伤害，弹药耗尽时通知拥有者 ====
function ENT:OnTakeDamage(dmginfo)
	local inflictor = dmginfo:GetInflictor():IsValid() and dmginfo:GetInflictor() or dmginfo:GetAttacker()
	if dmginfo:GetDamage() <= 0 or not inflictor:IsProjectile() then return end

	local attacker = dmginfo:GetAttacker()
	-- 人类阵营投射物不消耗弹药（友军攻击免疫）
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		local emitter = self:GetEmitter()
		if emitter and emitter:IsValid() and emitter.GetAmmo and emitter:GetAmmo() > 0 then
			-- 记录受击时间（驱动客户端红色脉冲）并播放焊接受击音效
			self:SetLastDamaged(CurTime())
			self:EmitSound("ambient/energy/weld2.wav", 65, 255, 0.6)

			-- 弹药消耗 = 伤害/10，加上次未整除的小数进位累积；不足时按 0 封底
			local ammousage = (dmginfo:GetDamage() / 10) + (emitter.CarryOver or 0)
			local floor = math.floor(ammousage)
			local owner = emitter:GetObjectOwner()

			emitter.CarryOver = ammousage - floor
			emitter:SetAmmo(math.max(emitter:GetAmmo() - floor, 0))

			-- 给发射器拥有者按伤害 2% 加分；弹药耗尽时通知其弹药告罄
			if owner:IsValidLivingHuman() then
				owner:AddPoints(dmginfo:GetDamage() * 0.02)

				if emitter:GetAmmo() == 0 then
					owner:SendDeployableOutOfAmmoMessage(emitter)
				end
			end
		end
	end
end
