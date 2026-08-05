-- ============================================================================
-- prop_remantler/init.lua - 拆解器（服务器）
-- 负责：可部署的武器拆解/强化台：人类玩家使用后打开拆解菜单；拥有者
--       可提取已拆解所得废料；有耐久与每玩家 0.75 秒使用冷却
-- ============================================================================
INC_SERVER()

-- ==== RefreshRemantlerOwners - 拥有者断线/换队时清除其名下拆解器的所有权 ====
local function RefreshRemantlerOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_remantler")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:SetObjectOwner(NULL)
		end
	end
end
-- 玩家断线与换队时触发所有权清理
hook.Add("PlayerDisconnected", "Remantler.PlayerDisconnected", RefreshRemantlerOwners)
hook.Add("OnPlayerChangedTeam", "Remantler.OnPlayerChangedTeam", RefreshRemantlerOwners)

-- ==== Initialize - 初始化：容器状态、固定物理与耐久 ====
function ENT:Initialize()
	-- 内部存放的拆解产物（武器/材料）
	self.Contents = {}
	-- 每个玩家的使用冷却记录（SteamID -> 时间戳）
	self.NextUse = {}

	self:SetModel("models/props_lab/powerbox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 世界碰撞组：不与其他物理物体互相推挤
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	self:CollisionRulesChanged()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		-- 固定放置
		phys:EnableMotion(false)
	end

	-- 耐久上限 200
	self:SetMaxObjectHealth(200)
	self:SetObjectHealth(self:GetMaxObjectHealth())
end

-- ==== SetObjectHealth - 设置耐久；归零时爆炸并移除 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	-- 耐久归零且未触发过摧毁流程时执行摧毁
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 通知拥有者部署物已丢失
		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self)
		end

		-- 生成破碎残骸并延时清除
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

		local pos = self:LocalToWorld(self:OBBCenter())

		-- 播放爆炸特效
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("Explosion", effectdata, true, true)
	end
end

-- ==== OnTakeDamage - 受伤处理：非人类阵营攻击者造成耐久损失 ====
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	-- 仅非人类阵营的攻击削减耐久
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
	end
end

-- ==== AltUse - 右键打包收起 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：归还武器、弹药与已存废料 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_remantler")
	pl:GiveAmmo(1, "remantler")

	-- 记录打包物品（含剩余耐久与废料）供再次部署
	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth(), self:GetScraps())

	self:Remove()
end

-- ==== Think - 已摧毁则移除自身 ====
function ENT:Think()
	if self.Destroyed then
		self:Remove()
	end
end

-- ==== Use - 使用：认领、提取废料或打开拆解菜单 ====
function ENT:Use(activator, caller)
	-- 仅限存活的人类玩家使用
	if activator:Team() ~= TEAM_HUMAN or not activator:Alive() then return end

	-- 每个玩家 0.75 秒使用冷却
	local uid = activator:SteamID64()
	if self.NextUse[uid] and CurTime() < self.NextUse[uid] then return end
	self.NextUse[uid] = CurTime() + 0.75

	local owner = self:GetObjectOwner()
	-- 尚无拥有者：当前玩家认领
	if not owner:IsValid() then
		self:SetObjectOwner(activator)
		self:GetObjectOwner():SendDeployableClaimedMessage(self)
		return
	end

	local currentwep = activator:GetActiveWeapon()
	local currentwepclass = currentwep:GetClass()
	local heldtbl = weapons.Get(currentwepclass)

	-- 拥有者提取全部废料
	if activator == owner and self:GetScraps() > 0 then
		local amount = self:GetScraps()
		self:SetScraps(0)

		-- 通知并发放废料弹药
		net.Start(NET_MSG.AMMOPICKUP)
			net.WriteUInt(amount, 16)
			net.WriteString("scrap")
		net.Send(activator)

		activator:GiveAmmo(amount, "scrap")

		-- 缩短提取操作的使用冷却
		self.NextUse[uid] = CurTime() + 0.05
		return
	end

	-- 持有可拆解/可强化武器时播放提示音
	if (heldtbl.AllowQualityWeapons or heldtbl.PermitDismantle) then
		activator:SendLua("surface.PlaySound(\"ambient/misc/shutter1.wav\")")
	end

	-- 打开客户端拆解菜单
	activator:SendLua("GAMEMODE:OpenRemantlerMenu(MySelf:NearestRemantler())")
end
