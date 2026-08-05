-- ============================================================================
-- prop_weapon/init.lua - 地面武器实体（服务器端）
-- 负责：掉落武器的物理/血量初始化、玩家拾取判定、弹药转移与地图键值解析
-- ============================================================================

INC_SERVER()
-- 客户端动画文件（随实体加载）
AddCSLuaFile("cl_animations.lua")

-- 清理优先级（服务器清理实体时的顺序）
ENT.CleanupPriority = 1

-- ==== Initialize - 初始化 ====
-- 初始化拾取相关标记、物理碰撞与物品生成回调
function ENT:Initialize()
	-- 武器对象血量（被僵尸破坏所需的伤害量）
	self.ObjHealth = 200
	-- 拾取计数/强制拾取/永不移除/忽略使用等状态标记（默认值）
	self.IgnorePickupCount = self.IgnorePickupCount or false
	self.Forced = self.Forced or false
	self.NeverRemove = self.NeverRemove or false
	self.IgnoreUse = self.IgnoreUse or false
	self.Empty = self.Empty or false
	self.Restrained = self.Restrained or false

	-- 按武器定义初始化物理（未指定盒体物理时用默认 VPHYSICS）
	local weptab = weapons.Get(self:GetWeaponType())
	if weptab and not weptab.BoxPhysicsMax then
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	-- 允许简单按 E 使用
	self:SetUseType(SIMPLE_USE)

	-- 配置刚体：默认材质、是否可动（受约束时固定）、质量与唤醒
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("material")
		phys:EnableMotion(not self.Restrained)
		phys:SetMass(45)
		phys:Wake()
	end

	-- 触发物品创建回调（供子类/附加逻辑挂钩）
	self:ItemCreated()
end

-- ==== SetupPhysics - 自定义盒体物理 ====
-- 武器定义指定盒体尺寸时，改用盒体碰撞（更贴合武器模型）
function ENT:SetupPhysics(weptab)
	if weptab.BoxPhysicsMax then
		self:PhysicsInitBox(weptab.BoxPhysicsMin, weptab.BoxPhysicsMax)
		self:SetCollisionBounds(weptab.BoxPhysicsMin, weptab.BoxPhysicsMax)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end
end

-- ==== MakeInvItemConvert - 转换为背包道具 ====
-- 把地面武器转换为对应饰品类型的背包道具实体
function ENT:MakeInvItemConvert(class)
	local ent = ents.Create("prop_invitem")
	if ent:IsValid() then
		-- 从武器类名提取饰品类型（去掉 weapon_zs_t_ 前缀）；失败则不转换
		if not ent:SetInventoryItemType("trinket_"..string.sub(class, 13)) then return end

		ent:Spawn()
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())

		-- 转换成功后移除自身
		self:RemoveNextFrame()
	end
end

-- ==== SetClip1 - 设置主弹匣 ====
-- 存储掉落时的主弹药数（拾取时转移给玩家）
function ENT:SetClip1(ammo)
	self.m_Clip1 = tonumber(ammo) or self:GetClip1()
end

-- ==== GetClip1 - 读取主弹匣 ====
function ENT:GetClip1()
	return self.m_Clip1 or 0
end

-- ==== SetClip2 - 设置副弹匣 ====
-- 存储掉落时的副弹药数
function ENT:SetClip2(ammo)
	self.m_Clip2 = tonumber(ammo) or self:GetClip2()
end

-- ==== GetClip2 - 读取副弹匣 ====
function ENT:GetClip2()
	return self.m_Clip2 or 0
end

-- ==== SetShouldRemoveAmmo - 设置拾取后是否消耗弹药 ====
function ENT:SetShouldRemoveAmmo(bool)
	self.m_DontRemoveAmmo = not bool
end

-- ==== GetShouldRemoveAmmo - 读取是否消耗弹药 ====
function ENT:GetShouldRemoveAmmo()
	return not self.m_DontRemoveAmmo
end

-- ==== Use - 使用交互 ====
-- 玩家按 E 时尝试拾取武器
function ENT:Use(activator, caller)
	if self.IgnoreUse then return end
	self:GiveToActivator(activator, caller)
end

-- ==== GiveToActivator - 武器交给玩家 ====
-- 拾取判定：人类存活/非强制模式下不按键/冷却期内非专属者，然后转移弹药或直接给予
function ENT:GiveToActivator(activator, caller)
	-- 拾取前提校验：有效存活人类、非移除中、非按住使用键（除非强制）、冷却期内仅限专属者
	if  not activator:IsPlayer()
		or not activator:Alive()
		or activator:Team() ~= TEAM_HUMAN
		or self.Removing
		or (activator:KeyDown(GAMEMODE.UtilityKey) and not self.Forced)
		or self.NoPickupsTime and CurTime() < self.NoPickupsTime and self.NoPickupsOwner ~= activator then

		self:Input("OnPickupFailed", activator)
		return
	end

	-- 武器类型无效时拾取失败
	local weptype = self:GetWeaponType()
	if not weptype then
		self:Input("OnPickupFailed", activator)
		return
	end

	-- 玩家已拥有该武器：只转移弹药（特定武器类型或不受拾取上限限制时）
	if activator:HasWeapon(weptype) and (self.Forced or not GAMEMODE.MaxWeaponPickups) then
		local weptab = weapons.Get(weptype)
		if not (weptab and weptab.NoPickupIfHas) then
			local wep = activator:GetWeapon(weptype)
			if wep:IsValid() then
				local primary = wep:ValidPrimaryAmmo()
				local secondary = wep:ValidSecondaryAmmo()

				-- 地图预设且该武器只补弹药时，给满弹匣
				if weptab.AmmoIfHas and self.PlacedInMap then
					self:SetClip1(1)
					self:SetClip2(1)
				end

				-- 转移主/副弹药并把地面弹匣清零
				if primary then activator:GiveAmmo(self:GetClip1(), primary) self:SetClip1(0) end 
				if secondary then activator:GiveAmmo(self:GetClip2(), secondary) self:SetClip2(0) end

				-- 纯弹药型武器拾取后移除自身（除非设置永不移除）
				if weptab.AmmoIfHas then
					self:Input("OnPickupPassed", activator)
					if not self.NeverRemove then self:RemoveNextFrame() end
				end
				return
			end
		end
	end

	-- 给予新武器：受地图预设/拾取上限约束（单人局不受限）
	if not self.PlacedInMap or not GAMEMODE.MaxWeaponPickups or (activator.WeaponPickups or 0) < GAMEMODE.MaxWeaponPickups or team.NumPlayers(TEAM_HUMAN) <= 1 then
		-- 地图预设且非空武器时给予满配武器，否则给予空武器
		local wep = (self.PlacedInMap and not self.Empty) and activator:Give(weptype) or activator:GiveEmptyWeapon(weptype)
		if wep and wep:IsValid() and wep:GetOwner():IsValid() then
			-- 转移地面武器中保存的弹药
			if self:GetShouldRemoveAmmo() then
				wep:SetClip1(self:GetClip1())
				wep:SetClip2(self:GetClip2())
			end

			-- 地图预设且未忽略拾取计数时累计拾取次数（限制囤武器）
			if self.PlacedInMap and not self.IgnorePickupCount then
				activator.WeaponPickups = (activator.WeaponPickups or 0) + 1
			end
			self:Input("OnPickupPassed", activator)
			if not self.NeverRemove then self:RemoveNextFrame() end
		else
			-- 给予失败（背包满等）
			self:Input("OnPickupFailed", activator)
		end
	else
		-- 超过拾取上限：拒绝并提示玩家
		self:Input("OnPickupFailed", activator)
		activator:CenterNotify(COLOR_RED, translate.ClientGet(activator, "you_decide_to_leave_some"))
	end
end

-- ==== KeyValue - 键值处理 ====
-- 解析地图 Hammer 键值：武器类型/拾取与移除行为标记/输出定义
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "weapontype" then
		self:SetWeaponType(value)
	elseif key == "ignorepickupcount" then
		self.IgnorePickupCount = tonumber(value) == 1
	elseif key == "neverremove" then
		self.NeverRemove = tonumber(value) == 1
	elseif key == "ignoreuse" then
		self.IgnoreUse = tonumber(value) == 1
	elseif key == "empty" then
		self.Empty = tonumber(value) == 1
	elseif key == "restrained" then
		self.Restrained = tonumber(value) == 1
	elseif string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	end
end

-- ==== AcceptInput - 输入处理 ====
-- 响应动态修改/拾取触发等输入
function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	-- 强制交给指定玩家
	if name == "givetoactivator" then
		self.Forced = true
		self:GiveToActivator(activator,caller)
		return true
	-- 动态设置：永不移除/忽略拾取计数/忽略使用/武器类型/空弹匣
	elseif name == "setneverremove" then
		self.NeverRemove = tonumber(arg) == 1
		return true
	elseif name == "setignorepickupcount" then
		self.IgnorePickupCount = tonumber(arg) == 1
		return true
	elseif name == "setignoreuse" then
		self.IgnoreUse = tonumber(arg) == 1
		return true
	elseif name == "setweapontype" then
		self:SetWeaponType(arg)
		return true
	elseif name == "setempty" then
		self.Empty = tonumber(arg) == 1
	-- "on" 前缀输入转发为输出
	elseif string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	end
end

-- ==== OnTakeDamage - 受到伤害 ====
-- 物理伤害 + 耐久血量；人类攻击不损耗耐久，耐久归零后移除
function ENT:OnTakeDamage(dmginfo)
	-- 零伤害直接忽略
	if dmginfo:GetDamage() <= 0 then return end

	-- 永不移除的武器免疫伤害移除
	if self.NeverRemove then return end
	-- 应用物理伤害（推动武器）
	self:TakePhysicsDamage(dmginfo)

	-- 人类攻击者不损耗武器耐久（防止友军误拆）
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then return end

	-- 扣减耐久，归零后移除
	self.ObjHealth = self.ObjHealth - dmginfo:GetDamage()
	if self.ObjHealth <= 0 then
		self:RemoveNextFrame()
	end
end
