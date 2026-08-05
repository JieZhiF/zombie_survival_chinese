-- ========== 获取Player元表用于扩展玩家方法 ==========

local meta = FindMetaTable("Player")

-- ========== 添加库存物品 ==========

-- 向玩家库存中添加指定物品（增加数量/首次获得）
function meta:AddInventoryItem(item)
	if not GAMEMODE:IsInventoryItem(item) then return false end

	self.ZSInventory[item] = self.ZSInventory[item] and self.ZSInventory[item] + 1 or 1

	-- 如果是饰品，重新应用所有饰品效果
	if GAMEMODE:GetInventoryItemType(item) == INVCAT_TRINKETS then
		self:ApplyTrinkets()
	end

	-- 通知客户端更新该物品数量
	net.Start(NET_MSG.INVENTORYITEM)
		net.WriteString(item)
		net.WriteUInt(self.ZSInventory[item], 8)
	net.Send(self)

	return true
end

-- ========== 移除库存物品 ==========

-- 从玩家库存中移除一个指定物品（减少数量或置nil）
function meta:TakeInventoryItem(item)
	if not self:HasInventoryItem(item) then return false end

	-- 如果数量为1，则将键设为nil以清理表
	local setnil = self.ZSInventory[item] == 1
	self.ZSInventory[item] = self.ZSInventory[item] - 1

	if setnil then
		self.ZSInventory[item] = nil
	end

	-- 如果是饰品，重新应用饰品效果
	if GAMEMODE:GetInventoryItemType(item) == INVCAT_TRINKETS then
		self:ApplyTrinkets()
	end

	-- 通知客户端更新
	net.Start(NET_MSG.INVENTORYITEM)
		net.WriteString(item)
		net.WriteUInt(self.ZSInventory[item] or 0, 8)
	net.Send(self)

	return true
end

-- ========== 清空玩家库存 ==========

-- 彻底清除玩家所有库存物品并重置饰品效果
function meta:WipePlayerInventory()
	if not self.ZSInventory or table.Count(self.ZSInventory) == 0 then return end

	self.ZSInventory = {}
	self:ApplyTrinkets()

	net.Start(NET_MSG.WIPEINVENTORY)
	net.Send(self)
end

-- ========== 处理客户端合成请求 ==========

-- 接收客户端发送的合成请求网络消息
net.Receive(NET_MSG.TRYCRAFT, function(len, pl)
	local component = net:ReadString()
	local weapon = net:ReadString()

	pl:TryAssembleItem(component, weapon)
end)

-- ========== 玩家尝试合成物品 ==========

-- 核心合成逻辑：验证组件和基础武器，执行合成操作
function meta:TryAssembleItem(component, heldclass)
	local heldwep, desiassembly = self:GetWeapon(heldclass)
	-- 检查持有的武器是否属于库存物品类型
	local heldwepiitype = GAMEMODE:GetInventoryItemType(heldclass) ~= -1

	-- 如果是库存物品类型，检查玩家是否拥有该物品
	if heldwepiitype then
		if not self:HasInventoryItem(heldclass) then
			self:CenterNotify(COLOR_RED, "You don't have the item to craft this with.")
			self:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
			return
		end
	else
		-- 否则检查是否持有效武器
		if not heldwep or not heldwep:IsValid() then
			self:CenterNotify(COLOR_RED, "You don't have the weapon to craft this with.")
			self:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
			return
		end
	end

	-- 在合成配方表中查找匹配的合成项
	for assembly, reqs in pairs(GAMEMODE.Assemblies) do
		local reqcomp, reqweapon = reqs[1], reqs[2]
		if reqcomp == component and reqweapon == heldclass then
			desiassembly = assembly
			break
		end
	end

	-- 未找到匹配的合成配方
	if not desiassembly then
		self:CenterNotify(COLOR_RED, "You can't make anything with this component and your currently held weapon.")
		self:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	-- 检查合成结果是否为库存物品类型
	local invitemresult = GAMEMODE:GetInventoryItemType(desiassembly) ~= -1

	local desitable
	-- 如果结果是库存物品，则消耗组件并给予结果
	if invitemresult then
		if not self:TakeInventoryItem(component) then return end

		self:AddInventoryItem(desiassembly)
		self:CenterNotify(COLOR_LIMEGREEN, translate.ClientGet(self, "crafting_successful"), color_white, "   ("..GAMEMODE.ZSInventoryItemData[desiassembly].PrintName..")")
	else
		-- 否则是武器类结果，给予玩家武器
		desitable = weapons.Get(desiassembly)
		-- 检查是否已拥有（对于AmmoIfHas类型武器）
		if (not desitable.AmmoIfHas and self:HasWeapon(desiassembly)) or not self:TakeInventoryItem(component) then return end

		-- 如果是AmmoIfHas类型的武器，给予1发弹药
		if desitable.AmmoIfHas then
			self:GiveAmmo(1, desitable.Primary.Ammo)
		end
		self:GiveEmptyWeapon(desiassembly)
		self:SelectWeapon(desiassembly)
		self:UpdateAltSelectedWeapon()

		self:CenterNotify(COLOR_LIMEGREEN, translate.ClientGet(self, "crafting_successful"), color_white, "   ("..desitable.PrintName..")")
	end

	-- 消耗基础材料（库存物品或实际武器）
	if heldwepiitype then
		self:TakeInventoryItem(heldclass)
	else
		heldwep:EmptyAll(true)
		if heldwep.AmmoIfHas then
			self:RemoveAmmo(1, heldwep.Primary.Ammo)
		end
		self:StripWeapon(heldclass)
	end
	-- 播放合成成功音效
	self:SendLua("surface.PlaySound(\"buttons/lever"..math.random(5)..".wav\")")

	-- 统计追踪：记录该武器的合成次数
	GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, desiassembly, "Crafts", 1)
end

-- ========== 按类型丢弃库存物品 ==========

-- 创建物理实体并弹出指定类型的库存物品（ZombieEscape模式下禁用）
function meta:DropInventoryItemByType(itype)
	if GAMEMODE.ZombieEscape then return end
	if not self:HasInventoryItem(itype) then return end

	local ent = ents.Create("prop_invitem")
	if ent:IsValid() then
		ent:SetInventoryItemType(itype)
		ent:Spawn()
		ent.DroppedTime = CurTime()

		self:TakeInventoryItem(itype)
		self:UpdateAltSelectedWeapon()

		return ent
	end
end

-- ========== 丢弃所有库存物品 ==========

-- 循环遍历玩家所有库存物品，逐个创建物理实体丢弃
function meta:DropAllInventoryItems()
	local vPos = self:GetPos()
	local vVel = self:GetVelocity()
	local zmax = self:OBBMaxs().z * 0.75
	for invitem, count in pairs(self:GetInventoryItems()) do
		for i = 1, count do
			local ent = self:DropInventoryItemByType(invitem)
			if ent and ent:IsValid() then
				ent:SetPos(vPos + Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(2, zmax)))
				ent:SetAngles(VectorRand():Angle())
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:AddAngleVelocity(Vector(math.Rand(-720, 720), math.Rand(-720, 720), math.Rand(-720, 720)))
					phys:ApplyForceCenter(phys:GetMass() * (math.Rand(32, 328) * VectorRand():GetNormalized() + vVel))
				end
			end
		end
	end
end

-- ========== 给予其他玩家库存物品 ==========

-- 将一个库存物品从自己转移给其他玩家
function meta:GiveInventoryItemByType(itype, plyr)
	if GAMEMODE.ZombieEscape then return end
	if not self:HasInventoryItem(itype) then return end

	-- 饰品限制：目标玩家不能已有同类型饰品
	if GAMEMODE:GetInventoryItemType(itype) == INVCAT_TRINKETS and plyr:HasInventoryItem(itype) then
		self:CenterNotify(COLOR_RED, translate.ClientGet(self, "they_already_have_this_trinket"))
		return
	end

	self:TakeInventoryItem(itype)
	self:UpdateAltSelectedWeapon()

	-- 通知目标玩家接收物品
	net.Start(NET_MSG.INVGIVEN)
		net.WriteString(itype)
		net.WriteEntity(self)
	net.Send(plyr)

	plyr:AddInventoryItem(itype)
end

-- ========== 检查物品是否为库存物品 ==========

function GM:IsInventoryItem(item)
	return self.ZSInventoryItemData[item]
end

-- ========== 获取玩家库存表 ==========

function meta:GetInventoryItems()
	return self.ZSInventory
end

-- ========== 检查玩家是否拥有物品 ==========

function meta:HasInventoryItem(item)
	return self.ZSInventory[item]
end
