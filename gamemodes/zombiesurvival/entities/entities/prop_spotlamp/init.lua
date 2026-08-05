-- ============================================================================
-- init.lua - 探照灯道具（服务器）：投影灯生成、耐久与打包管理
-- 负责：生成投影光柱，受击掉耐久，归零时爆炸销毁，可被打包带走
-- ============================================================================
INC_SERVER()

-- 玩家掉线/换队时清空其持有的所有探照灯归属
local function RefreshCrateOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_spotlamp")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:SetObjectOwner(NULL)
		end
	end
end
hook.Add("PlayerDisconnected", "SpotLamp.PlayerDisconnected", RefreshCrateOwners)
hook.Add("OnPlayerChangedTeam", "SpotLamp.OnPlayerChangedTeam", RefreshCrateOwners)

-- ==== Initialize - 初始化：静态生成、设定耐久并创建投影光柱 ====
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_light001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	self:CollisionRulesChanged()

	-- 固定不动（不可被物理推走）
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetMaxObjectHealth(100)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	-- 生成投影光柱并挂到灯体上（淡蓝白色、50 度光锥、无阴影）
	local ent = ents.Create("env_projectedtexture")
	if ent:IsValid() then
		ent:SetPos(self:GetSpotLightPos())
		ent:SetAngles(self:GetSpotLightAngles())
		ent:SetKeyValue("enableshadows", 0)
		ent:SetKeyValue("farz", 1500)
		ent:SetKeyValue("nearz", 8)
		ent:SetKeyValue("lightfov", 50)
		ent:SetKeyValue("lightcolor", "200 220 255 255")
		ent:SetParent(self)
		ent:Spawn()
		ent:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")
	end
end

-- ==== KeyValue - Hammer 键值处理：支持覆盖最大/当前耐久 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "maxobjecthealth" then
		value = tonumber(value)
		if not value then return end

		self:SetMaxObjectHealth(value)
	elseif key == "objecthealth" then
		value = tonumber(value)
		if not value then return end

		self:SetObjectHealth(value)
	end
end

-- ==== AcceptInput - 地图输入处理：设置当前/最大耐久 ====
function ENT:AcceptInput(name, activator, caller, args)
	if name == "setobjecthealth" then
		self:KeyValue("objecthealth", args)
		return true
	elseif name == "setmaxobjecthealth" then
		self:KeyValue("maxobjecthealth", args)
		return true
	end
end

-- ==== SetObjectHealth - 写入耐久：归零时触发爆炸特效 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 灯体中心播放爆炸特效
		local effectdata = EffectData()
			effectdata:SetOrigin(self:LocalToWorld(self:OBBCenter()))
		util.Effect("Explosion", effectdata, true, true)
	end
end

-- ==== OnTakeDamage - 受击处理：非人类攻击者造成的伤害扣减耐久 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
		-- 记录最后攻击者（用于攻击者结算）
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
	end
end

-- ==== AltUse - 右键交互：打包收起探照灯 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：返还探照灯武器与弹药并移除实体 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_spotlamp")
	pl:GiveAmmo(1, "spotlamp")

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
