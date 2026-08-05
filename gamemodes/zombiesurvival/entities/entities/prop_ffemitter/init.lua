-- ============================================================================
-- prop_ffemitter - 力场发射器实体（服务端）
-- 负责：部署时在前方生成力场区域，管理弹药与血量，承受攻击损毁，支持存入脉冲弹药与打包回收
-- ============================================================================
INC_SERVER()

-- 玩家断线或更换队伍时，清除其名下所有力场发射器的归属（防止遗留所有权）
local function RefreshFFOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_ffemitter")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:SetObjectOwner(NULL)
		end
	end
end
hook.Add("PlayerDisconnected", "ForceField.PlayerDisconnected", RefreshFFOwners)
hook.Add("OnPlayerChangedTeam", "ForceField.OnPlayerChangedTeam", RefreshFFOwners)

-- ==== Initialize - 初始化模型/物理/使用方式，在前方生成力场区域实体并设置发射器血量 ====
function ENT:Initialize()
	self:SetModel("models/props_lab/lab_flourescentlight002b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	self:CollisionRulesChanged()

	-- 固定发射器本体，不参与物理运动
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	-- 在发射器前方偏移位置生成力场区域实体，并建立双向引用
	local ent = ents.Create("prop_ffemitterfield")
	if ent:IsValid() then
		self.Field = ent

		ent:SetPos(self:GetPos() + self:GetForward() * 48 + self:GetUp() * -26)
		ent:SetAngles(self:GetAngles())
		ent:SetOwner(self)
		ent:Spawn()

		ent:SetEmitter(self)
	end

	-- 初始血量 150
	self:SetMaxObjectHealth(150)
	self:SetObjectHealth(self:GetMaxObjectHealth())
end

-- ==== OnRemove - 移除发射器时连带移除其生成的力场区域 ====
function ENT:OnRemove()
	if self.Field and self.Field:IsValid() then
		self.Field:Remove()
	end
end

-- ==== SetObjectHealth - 同步血量；血量为零时触发摧毁流程：通知拥有者、生成碎裂残骸与爆炸特效 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 通知拥有该发射器的人类玩家"部署物已丢失"
		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self)
		end

		-- 生成一个临时物理残骸，模拟被打碎的效果
		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			ent:SetModel(self:GetModel())
			ent:SetMaterial(self:GetMaterial())
			ent:SetAngles(self:GetAngles())
			ent:SetPos(self:GetPos())
			ent:SetSkin(self:GetSkin() or 0)
			ent:SetColor(self:GetColor())
			ent:Spawn()
			ent:Fire("break", "", 0)
			ent:Fire("kill", "", 0.1)
		end

		-- 在发射器中心播放爆炸特效
		local effectdata = EffectData()
			effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		util.Effect("Explosion", effectdata, true, true)
	end
end

-- ==== OnTakeDamage - 承受攻击：物理伤害照常结算，仅非人类攻击者造成的伤害扣除发射器血量 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	-- 人类造成的攻击不扣血（免疫友军破坏），其他来源正常扣血并记录攻击者
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
	end
end

-- ==== Use - 使用交互：无主时认领发射器；有主时玩家可将脉冲弹药存入发射器（上限 MaxAmmo） ====
function ENT:Use(activator, caller)
	if self.Destroyed or not activator:IsPlayer() or activator:Team() ~= TEAM_HUMAN or self:GetMaterial() ~= "" then return end

	if self:GetObjectOwner():IsValid() then
		-- 已认领：按玩家设置决定是否允许存入弹药，每次最多存入 15 发脉冲弹药
		if activator:GetInfo("zs_nousetodeposit") == "0" then
			local curammo = self:GetAmmo()
			local togive = math.min(math.min(15, activator:GetAmmoCount("pulse")), self.MaxAmmo - curammo)
			if togive > 0 then
				self:SetAmmo(curammo + togive)
				activator:RemoveAmmo(togive, "pulse")
				activator:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)
				self:EmitSound("npc/scanner/combat_scan1.wav", 60, 250)
			end
		end
	else
		-- 无主：由使用玩家认领并播报归属消息
		self:SetObjectOwner(activator)
		self:GetObjectOwner():SendDeployableClaimedMessage(self)
	end
end

-- ==== AltUse - 右键使用：打包收起发射器 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：归还发射器武器与弹药，将当前状态记录进打包物品列表后移除 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_ffemitter")
	pl:GiveAmmo(1, "slam")

	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())
	pl:GiveAmmo(self:GetAmmo(), "pulse")

	self:Remove()
end

-- ==== Think - 已进入摧毁状态的发射器在下一帧立即移除 ====
function ENT:Think()
	if self.Destroyed then
		self:Remove()
	end
end
