-- ============================================================================
-- init.lua - 监控摄像头道具（服务端）
-- 负责：初始化静态摄像头本体与命中箱，管理血量、受击摧毁与右键收起
-- ============================================================================
INC_SERVER()

-- ==== Initialize - 初始化摄像头 ====
-- 设置模型与静态物理，初始化血量，并创建子命中箱实体
function ENT:Initialize()
	self:DrawShadow(false)
	self:SetModel("models/props_c17/light_domelight02_off.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	-- 初始化血量上限与当前血量
	self:SetMaxObjectHealth(self.MaxHealth)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	-- 创建可被子弹命中的命中箱子实体并挂为子实体
	local ent = ents.Create("prop_hitbox_camera")
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetOwner(self)
		ent:SetParent(self)
		ent:Spawn()

		self:DeleteOnRemove(ent)
		self.Hitbox = ent
	end
end

-- ==== SetObjectHealth - 设置血量并在归零时摧毁 ====
-- 血量降至 0 时播放碎裂音效、生成破碎的猎头机器人模型，并通知放置者
function ENT:SetObjectHealth(health)
	self:SetDTFloat(3, health)

	-- 血量归零且尚未标记摧毁：执行摧毁流程
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		self:EmitSound("npc/manhack/gib.wav")

		-- 生成一个猎头机器人物理模型并立即破碎（模拟摄像头被砸碎）
		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			ent:SetPos(self:WorldSpaceCenter())
			ent:SetAngles(self:GetAngles())
			ent:SetModel("models/manhack.mdl")
			ent:Spawn()

			ent:Fire("break")
			ent:Fire("kill", "", 0.05)
		end

		-- 放置者在线时提示其部署物已丢失
		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self)
		end

		self:Remove()
	end
end

-- ==== AltUse - 右键收起摄像头 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 收起完成回调 ====
-- 返还摄像头武器、1 发摄像机弹药，并把剩余血量记录进背包物品后移除自身
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.SWEP)
	pl:GiveAmmo(1, "camera")

	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())

	self:Remove()
end

-- ==== OnTakeDamage - 受击处理 ====
-- 人类以外的攻击者伤害会扣除摄像头血量（人类攻击视为物理推击不扣血）
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
	end
end

-- ==== SetMaxObjectHealth - 写入最大血量（DT 整数槽 1）====
function ENT:SetMaxObjectHealth(health)
	self:SetDTInt(1, health)
end

-- ==== ClearObjectOwner - 清空放置者 ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end

-- ==== SetObjectOwner - 写入放置者（DT 实体槽 1）====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(1, ent)
end
