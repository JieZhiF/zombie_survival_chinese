-- ============================================================================
-- init.lua - 武器箱道具（服务器）：购买界面、归属与耐久管理
-- 负责：人类可认领并打开军械库菜单购买武器，受击掉耐久，归零时碎裂销毁
-- ============================================================================
INC_SERVER()

-- 玩家掉线/换队时清空其持有的所有武器箱归属
local function RefreshCrateOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_arsenalcrate")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:SetObjectOwner(NULL)
		end
	end
end
hook.Add("PlayerDisconnected", "ArsenalCrate.PlayerDisconnected", RefreshCrateOwners)
hook.Add("OnPlayerChangedTeam", "ArsenalCrate.OnPlayerChangedTeam", RefreshCrateOwners)

-- ==== Initialize - 初始化：静态生成并设定 400 点耐久 ====
function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	self:CollisionRulesChanged()

	-- 固定不动（不可被物理推走）
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetMaxObjectHealth(400)
	self:SetObjectHealth(self:GetMaxObjectHealth())
end

-- ==== KeyValue - Hammer 键值处理：支持覆盖最大/当前耐久 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "maxcratehealth" then
		value = tonumber(value)
		if not value then return end

		self:SetMaxObjectHealth(value)
	elseif key == "cratehealth" then
		value = tonumber(value)
		if not value then return end

		self:SetObjectHealth(value)
	end
end

-- ==== AcceptInput - 地图输入处理：设置当前/最大耐久 ====
function ENT:AcceptInput(name, activator, caller, args)
	if name == "setcratehealth" then
		self:KeyValue("cratehealth", args)
		return true
	elseif name == "setmaxcratehealth" then
		self:KeyValue("maxcratehealth", args)
		return true
	end
end

-- ==== SetObjectHealth - 写入耐久：归零时通知持有者并生成碎裂残骸 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 通知持有者其部署物已丢失
		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self)
		end

		-- 生成一个同外观的物理残骸并触发碎裂动画
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
	end
end

-- ==== OnTakeDamage - 受击处理：非人类攻击者造成的伤害扣减耐久 ====
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		-- 记录最后攻击者（用于攻击者结算）并扣减耐久
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
	end
end

-- ==== Use - 使用交互：人类认领武器箱并打开军械库购买菜单 ====
function ENT:Use(activator, caller)
	local ishuman = activator:Team() == TEAM_HUMAN and activator:Alive()

	-- 无人认领时由使用的人类认领
	if not self.NoTakeOwnership and not self:GetObjectOwner():IsValid() and ishuman then
		self:SetObjectOwner(activator)
		self:GetObjectOwner():SendDeployableClaimedMessage(self)
	end

	-- 可购买阶段打开军械库菜单，否则提示不能购买
	if gamemode.Call("PlayerCanPurchase", activator) then
		activator:SendLua("GAMEMODE:OpenArsenalMenu()")
	elseif ishuman then
		activator:CenterNotify(COLOR_RED, translate.ClientGet(activator, "you_cant_purchase_now"))
	end
end

-- ==== AltUse - 右键交互：打包收起武器箱 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：返还武器箱武器与弹药并移除实体 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_arsenalcrate")
	pl:GiveAmmo(1, "airboatgun")

	-- 记录打包道具及其剩余耐久，供再次部署
	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())

	self:Remove()
end

-- ==== Think - 每帧检测：销毁标记后移除实体 ====
function ENT:Think()
	if self.Destroyed then
		self:Remove()
	end
end
