-- ============================================================================
-- prop_invitem/init.lua - 库存道具实体（服务器）
-- 负责：地图上摆放的道具：人类玩家按 E 拾取后加入其库存；支持通过
--       KeyValue/AcceptInput 配置道具类型、强制拾取与永不移除
-- ============================================================================
INC_SERVER()
-- 同步客户端动画文件（拾取/移除动画）
AddCSLuaFile("cl_animations.lua")

-- 清理优先级：1（低优先级，先于其他物体被清理）
ENT.CleanupPriority = 1

-- ==== Initialize - 初始化：物理属性、拾取方式与初始状态 ====
function ENT:Initialize()
	-- 道具自身血量：200（被破坏后移除）
	self.ObjHealth = 200
	-- 是否强制拾取（由 AcceptInput 设置，默认否）
	self.Forced = self.Forced or false
	-- 是否永不移除（由 KeyValue 设置，默认否）
	self.NeverRemove = self.NeverRemove or false
	-- 是否固定不动（不启用物理运动，默认否）
	self.Restrained = self.Restrained or false

	-- 初始化 vphysics 物理并设为碎片触发碰撞组
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	-- 按 E 键触发 Use
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("material")
		-- Restrained 时道具固定不动
		phys:EnableMotion(not self.Restrained)
		phys:SetMass(45)
		phys:Wake()
	end

	-- 通知子类/客户端生成对应的展示模型
	self:ItemCreated()
end

-- ==== Use - 按 E 使用：尝试把道具交给触发者 ====
function ENT:Use(activator, caller)
	self:GiveToActivator(activator, caller)
end

-- ==== GiveToActivator - 拾取校验并把道具加入拾取者库存 ====
function ENT:GiveToActivator(activator, caller)
	-- 拾取条件：玩家、存活、人类阵营、非移除中；未强制拾取时按住
	-- 工具键或处于其他玩家的拾取保护期内则拒绝
	if  not activator:IsPlayer()
		or not activator:Alive()
		or activator:Team() ~= TEAM_HUMAN
		or self.Removing
		or (activator:KeyDown(GAMEMODE.UtilityKey) and not self.Forced)
		or self.NoPickupsTime and CurTime() < self.NoPickupsTime and self.NoPickupsOwner ~= activator then

		return
	end

	local itype = self:GetInventoryItemType()
	if not itype then
		return
	end

	-- 饰品类别：已拥有时提示并拒绝重复拾取
	local itypecat = GAMEMODE:GetInventoryItemType(itype)
	if itypecat == INVCAT_TRINKETS and activator:HasInventoryItem(itype) then
		activator:CenterNotify(COLOR_RED, translate.ClientGet(activator, "you_already_have_this_trinket"))
		return
	end

	-- 加入库存并通知客户端播放拾取动画
	activator:AddInventoryItem(itype)

	net.Start(NET_MSG.INVITEM)
		net.WriteString(itype)
	net.Send(activator)

	-- 默认拾取后移除；NeverRemove 时保留
	if not self.NeverRemove then self:RemoveNextFrame() end
end

-- ==== KeyValue - 读取 Hammer 键值：道具类型与是否永不移除 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "invitemtype" then
		self:SetInventoryItemType(value)
	elseif key == "neverremove" then
		self.NeverRemove = tonumber(value) == 1
	end
end

-- ==== AcceptInput - 处理 GiveToActivator 输入：强制交给指定玩家 ====
function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	if name == "givetoactivator" then
		self.Forced = true
		self:GiveToActivator(activator,caller)
		return true
	end
end

-- ==== OnTakeDamage - 受伤处理：非人类攻击削减道具血量，归零移除 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	-- 永不移除的道具免疫破坏
	if self.NeverRemove then return end
	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	-- 人类玩家的攻击不削减道具血量
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then return end

	self.ObjHealth = self.ObjHealth - dmginfo:GetDamage()
	if self.ObjHealth <= 0 then
		self:RemoveNextFrame()
	end
end
