-- ============================================================================
-- init.lua - 补给弹药箱（服务端）：放置、补给、受损与打包回收
-- 负责：玩家放置后可供同队人类补充弹药，属主/血量经 DT 同步，破坏后留下残骸
-- ============================================================================
INC_SERVER()

-- 清理指定玩家对全部弹药箱的属主标记（断线/换队时释放所有权）
local function RefreshCrateOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_resupplybox")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:SetObjectOwner(NULL)
		end
	end
end
hook.Add("PlayerDisconnected", "ResupplyBox.PlayerDisconnected", RefreshCrateOwners)
hook.Add("OnPlayerChangedTeam", "ResupplyBox.OnPlayerChangedTeam", RefreshCrateOwners)

-- ==== Initialize - 初始化：设置模型、静态物理与 400 点血量 ====
function ENT:Initialize()
	self:SetModel("models/Items/ammocrate_ar2.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 与世界碰撞组一致，避免被其他物理物体推挤
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)
	self:SetPlaybackRate(1)

	self:CollisionRulesChanged()

	-- 冻结物理体，使弹药箱固定不动
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:SetMaxObjectHealth(400)
	self:SetObjectHealth(self:GetMaxObjectHealth())
end

-- ==== KeyValue - 解析 Hammer 地图键值（血量相关） ====
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

-- ==== AcceptInput - 处理地图输入：设置弹药箱血量 ====
function ENT:AcceptInput(name, activator, caller, args)
	if name == "setcratehealth" then
		self:KeyValue("cratehealth", args)
		return true
	elseif name == "setmaxcratehealth" then
		self:KeyValue("maxcratehealth", args)
		return true
	end
end

-- ==== SetObjectHealth - 设置血量：归零时生成物理残骸并通知属主 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 属主为存活人类时发送"已丢失部署物"提示
		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self)
		end

		-- 生成一个同外观的物理箱子并立刻击碎，模拟弹药箱被打爆的残骸
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

-- ==== OnTakeDamage - 受伤处理：仅非人类攻击者能扣减弹药箱血量 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	-- 人类玩家（队友）伤害无效；僵尸等非人类攻击才扣血并记录攻击者
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
	end
end

-- ==== AltUse - 右键交互：打包收起弹药箱 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：归还补给箱武器与一格弹药 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_resupplybox")
	pl:GiveAmmo(1, "helicoptergun")

	-- 记录打包物品（含当前血量）供再次放置
	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())

	self:Remove()
end

-- ==== Think - 每帧处理：移除已损毁的箱子并播放关闭动画 ====
function ENT:Think()
	if self.Destroyed then
		self:Remove()
	elseif self.Close and CurTime() >= self.Close then
		-- 补给结束后恢复开启状态并播放箱盖关闭音效
		self.Close = nil
		self:ResetSequence("open")
		self:EmitSound("items/ammocrate_close.wav")
	end
end

-- ==== Use - 使用交互：人类玩家认领并补充弹药 ====
function ENT:Use(activator, caller)
	-- 仅存活的人类玩家在波次进行中可使用
	if activator:Team() ~= TEAM_HUMAN or not activator:Alive() or GAMEMODE:GetWave() <= 0 then return end

	-- 无属主时由首个使用者认领
	if not self:GetObjectOwner():IsValid() then
		self:SetObjectOwner(activator)
		self:GetObjectOwner():SendDeployableClaimedMessage(self)
	end

	local owner = self:GetObjectOwner()
	local resup = activator:Resupply(owner, self)

	-- 成功补给时播放箱盖开启动画与音效
	if resup and not self.Close then
		self:ResetSequence("close")
		self:EmitSound("items/ammocrate_open.wav")
	end
	-- 3 秒后自动关闭箱盖
	self.Close = CurTime() + 3
end
