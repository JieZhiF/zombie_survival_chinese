-- 本文件主要负责在服务器端扩展实体（Entity）的功能，添加了大量关于路障、钉子系统、治疗、部署物、自定义伤害处理和实体交互的游戏逻辑。

-- IsDoorLocked 检查门是否被锁定
-- HealPlayer 处理对玩家的治疗逻辑，优先治疗流血和中毒，并计算治疗者的得分
-- GetDefaultBarricadeHealth 获取一个道具作为路障时的默认生命值，基于其物理质量和体积
-- HitFence 处理实体撞击栅栏类物体的物理逻辑，防止穿透或卡住
-- FakePropBreak 创建一个临时的实体来模拟原实体破碎的效果
-- SetBarricadeHealth 设置路障的当前生命值
-- SetMaxBarricadeHealth 设置路障的最大生命值
-- SetBarricadeRepairs 设置路障已被修理的次数
-- GhostAllPlayersInMe 使实体在一段时间内对所有玩家变为非碰撞，以防卡住玩家
-- AddUselessDamage 为路障添加"无效伤害"（此伤害在被修复时不会提供分数）
-- RemoveUselessDamage 移除路障的"无效伤害"
-- ClearUselessDamage 清除路障所有的"无效伤害"
-- ItemCreated 当一个可拾取物品被创造时调用，用于管理地图上掉落物品的数量上限
-- FireOutput 触发一个实体的自定义输出，类似于Hammer地图编辑器的I/O系统
-- AddOnOutput 为实体添加一个自定义输出事件
-- FindByNameHammer 根据名称查找实体，支持!self、!activator等特殊目标
-- IsNailed 检查实体是否被钉子钉住
-- IsNailedToWorld 检查实体是否被直接钉在世界上
-- IsNailedToWorldHierarchy 检查实体是否通过一个或多个约束层级被钉在世界上
-- GetNailFrozen 获取实体是否因被钉住而物理冻结
-- IsNailFrozen 与GetNailFrozen功能相同
-- SetNailFrozen 设置实体是否因被钉住而物理冻结
-- GetAllConstrainedEntities 获取所有通过物理约束连接到此实体的实体
-- PackUp 允许玩家开始打包回收一个可部署的实体
-- GetPropsInContraption 获取一个由多个道具组成的构造体中的道具数量
-- HumanNearby 检查附近是否有存活的人类玩家
-- ResetLastBarricadeAttacker 更新路障的最后攻击者信息，并为僵尸玩家记录对路障造成的伤害
-- SetPhysicsAttacker 重写物理攻击者设置，用于追踪func_physbox的攻击者
-- DamageNails 处理对被钉住的路障的伤害，将伤害分配给路障本身和钉子
-- GetNails 获取附着在该实体上的所有钉子实体
-- GetLivingNails 获取附着在该实体上所有未损坏的钉子实体
-- NumLivingNails 获取附着在该实体上未损坏钉子的数量
-- GetFirstNail 获取附着在该实体上的第一个有效钉子
-- RemoveNail 移除连接到此实体的一个钉子
-- RemoveNextFrame 在下一帧或指定时间后移除该实体
-- TemporaryBarricadeObject 当玩家靠近时，临时将实体标记为路障以改变碰撞规则
-- RecalculateNailBonuses 根据存活的钉子数量重新计算路障的生命值加成
-- SetupDeployableSkillHealth 根据部署物所有者的技能来设置部署物的生命值
-- DealProjectileTraceDamage 为自定义抛射物处理命中实体后的伤害计算
-- ProjectileTraceAhead 为抛射物在当前位置前方进行一次射线检测，用于提前命中判断
-- CachedInvisibleEntities (Timer) 定时缓存所有隐形或应被忽略追踪的实体，以优化可见性检查的性能

-- 获取实体（Entity）的元表，用于在服务器端扩展功能
local meta = FindMetaTable("Entity")

-- 检查门是否被锁定
-- 通过读取实体的保存表（SaveTable）中的m_bLocked字段来判断
function meta:IsDoorLocked()
	return self:GetSaveTable().m_bLocked
end

-- 处理对玩家的治疗逻辑
-- 优先治疗流血和中毒，然后治疗缺失生命值，最后计算治疗者的得分
-- 参数：pl-被治疗玩家, amount-治疗量, pointmul-得分倍率, nobymsg-是否不显示消息, poisononly-是否只治疗中毒
function meta:HealPlayer(pl, amount, pointmul, nobymsg, poisononly)
	local healed, rmv = 0, 0
	local health, maxhealth = pl:Health(), pl:IsSkillActive(SKILL_D_FRAIL) and math.floor(pl:GetMaxHealth() * 0.25) or pl:GetMaxHealth()
	local missing_health = maxhealth - health
	local poison = pl:GetPoisonDamage()
	local bleed = pl:GetBleedDamage()

	local healrec = (pl.HealingReceived or 1) - (pl:GetPhantomHealth() > 0.5 and 0.5 or 0) - (pl:GetStatus("sickness") and 0.5 or 0)
	local healmul = self.MedicHealMul or 1
	local multiplier = healmul + healrec - 1
	local regamount = healmul * amount

	amount = amount * multiplier

	-- 优先治疗流血
	if not poisononly and bleed > 0 then
		rmv = math.min(amount, bleed)
		pl:AddBleedDamage(-rmv)
		healed = healed + rmv
		amount = amount - rmv
	end

	-- 其次治疗中毒
	if poison > 0 and amount > 0 then
		rmv = math.min(amount, poison)
		pl:AddPoisonDamage(-rmv)
		healed = healed + rmv
		amount = amount - rmv
	end

	-- 最后治疗缺失生命值（增加过量治疗判定）
	if not poisononly and amount > 0 then
		if self:IsSkillActive(SKILL_OVERMEDIC) then
			-- 过量治疗：直接恢复所有剩余治疗量，允许超过最大生命值
			rmv = amount
			pl:SetHealth(health + rmv)
			healed = healed + rmv
			amount = 0
		elseif missing_health > 0 then
			-- 常规治疗：不能超过最大生命值
			rmv = math.min(amount, missing_health)
			pl:SetHealth(health + rmv)
			healed = healed + rmv
			amount = amount - rmv
		end
	end

	pointmul = (pointmul or 1) / (math.max(healed, regamount) / regamount)

	if healed > 0 and self:IsPlayer() then
		gamemode.Call("PlayerHealedTeamMember", self, pl, healed, self:GetActiveWeapon(), pointmul, nobymsg, 1)
		pl:SetPhantomHealth(math.max(0, pl:GetPhantomHealth() - healed))
	end

	return healed
end

-- 特定模型的生命值缩放系数表
local healthpropscalar = {
	["models/props_c17/door01_left.mdl"] = 0.7
}

-- 获取一个道具作为路障时的默认生命值
-- 基于其物理质量和体积，乘以全局系数，再经过模型缩放和范围限制
function meta:GetDefaultBarricadeHealth()
	local mass = 2
	if self._OriginalMass then
		mass = self._OriginalMass
	else
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			mass = phys:GetMass()
		end
	end

	local mdl = string.lower(self:GetModel())
	local scalar = healthpropscalar[mdl] or 1

	return math.Clamp((mass * GAMEMODE.BarricadeHealthMassFactor + self:GetVolume() * GAMEMODE.BarricadeHealthVolumeFactor) * scalar, GAMEMODE.BarricadeHealthMin, GAMEMODE.BarricadeHealthMax)
end

-- 处理实体撞击栅栏类物体的物理逻辑
-- 如果实体撞到了可穿透的物体（如栅栏），则将其位置固定在命中点并恢复速度，防止穿透或卡住
function meta:HitFence(data, phys)
	local pos = phys:GetPos()
	local vel = data.OurOldVelocity
	local endpos = data.HitPos + vel:GetNormalized()
	-- 检测是否撞到了栅栏或可穿透物体（固体掩码能挡住但射击掩码不能）
	if util.TraceLine({start = pos, endpos = endpos, mask = MASK_SOLID, filter = self}).Hit and not util.TraceLine({start = pos, endpos = endpos, mask = MASK_SHOT, filter = self}).Hit then
		self:SetPos(data.HitPos)
		phys:SetPos(data.HitPos)
		phys:SetVelocityInstantaneous(vel)

		return true
	end

	return false
end

-- 创建一个临时实体来模拟原实体破碎的效果
-- 用于在路障被破坏时生成视觉效果
function meta:FakePropBreak()
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

-- 设置路障的当前生命值（网络同步到客户端）
function meta:SetBarricadeHealth(m)
	self:SetDTFloat(1, m)
end

-- 设置路障的最大生命值（网络同步到客户端）
function meta:SetMaxBarricadeHealth(m)
	self:SetDTFloat(2, m)
end

-- 设置路障已被修理的次数（网络同步到客户端）
function meta:SetBarricadeRepairs(m)
	self:SetDTFloat(3, m)
end

-- 使实体在一段时间内对所有玩家变为非碰撞状态，以防卡住玩家
-- 创建一个point_propnocollide实体来实现此效果
function meta:GhostAllPlayersInMe(timeout, allowrepeat)
	if not allowrepeat then
		if self.GhostedBefore then return end
		self.GhostedBefore = true
	end

	-- 如果已经是非碰撞状态则无需处理
	if self.PreHoldCollisionGroup and self.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS_TRIGGER then return end

	local ent = ents.Create("point_propnocollide")
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		ent:Spawn()
		if timeout then
			ent:SetTimeOut(CurTime() + timeout)
		end
		ent:SetTeam(TEAM_HUMAN)

		ent:SetProp(self)

		return ent
	end
end

-- 为路障添加"无效伤害"
-- 此伤害在被修复时不会为玩家提供分数，用于防止滥用
function meta:AddUselessDamage(damage)
	self.UselessDamage = (self.UselessDamage or 0) + damage
end

-- 移除指定量的"无效伤害"
-- 返回实际移除的伤害值
function meta:RemoveUselessDamage(damage)
	if self.UselessDamage then
		damage = math.min(self.UselessDamage, damage)
		self.UselessDamage = self.UselessDamage - damage

		return damage
	end

	return 0
end

-- 清除路障所有的"无效伤害"
function meta:ClearUselessDamage()
	self.UselessDamage = nil
end

-- 物品排序函数：按清理优先级和创建时间排序
local function SortItems(a, b)
	if a.CleanupPriority == b.CleanupPriority then
		return a.Created < b.Created
	end

	return a.CleanupPriority < b.CleanupPriority
end

-- 检查并清理掉落的物品
-- 当地图上掉落物品数量超过上限时，移除最旧的物品
local function CheckItemCreated(self)
	if not self:IsValid() or self.PlacedInMap then return end

	local tab = {}
	for _, ent in pairs(ents.FindByClass("prop_ammo")) do
		if not ent.PlacedInMap then
			table.insert(tab, ent)
		end
	end
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do
		if not ent.PlacedInMap then
			table.insert(tab, ent)
		end
	end

	if #tab > GAMEMODE.MaxDroppedItems then
		table.sort(tab, SortItems)
		for i = 1, GAMEMODE.MaxDroppedItems do
			tab[i]:Remove()
		end
	end
end

-- 当可拾取物品被创造时调用
-- 记录创建时间并安排清理检查以控制掉落物品数量
function meta:ItemCreated()
	self.Created = self.Created or CurTime()
	timer.Simple(0, function() CheckItemCreated(self) end)
end

-- 触发实体的自定义输出，类似Hammer地图编辑器的I/O系统
-- 遍历所有注册的输出事件并执行对应的输入
function meta:FireOutput(outpt, activator, caller, args)
	local intab = self[outpt]
	if intab then
		for key, tab in pairs(intab) do
			local param = ((tab.args == "") and args) or tab.args
			for __, subent in pairs(self:FindByNameHammer(tab.entityname, activator, caller)) do
				local delay = tonumber(tab.delay)
				if delay == nil or delay <= 0 then
					subent:Input(tab.input, activator, caller, param)
				else
					-- 支持延迟执行
					local inp = tab.input
					timer.Simple(delay, function() if subent:IsValid() then subent:Input(inp, activator, caller, param) end end)
				end
			end
		end
	end
end

-- 为实体添加一个自定义输出事件
-- value格式：实体名,输入,参数,延迟,重复次数
function meta:AddOnOutput(key, value)
	self[key] = self[key] or {}
	local tab = string.Explode(",", value)
	table.insert(self[key], {entityname=tab[1], input=tab[2], args=tab[3], delay=tab[4], reps=tab[5]})
end

-- 根据名称查找实体，支持特殊目标：!self（自身）、!activator（激活者）、!caller（调用者）
function meta:FindByNameHammer(name, activator, caller)
	if name == "!self" then return {self} end
	if name == "!activator" then return {activator} end
	if name == "!caller" then return {caller} end
	return ents.FindByName(name)
end

-- 检查实体是否被钉子钉住
function meta:IsNailed()
	if self:IsValid() and self.Nails then
		for _, nail in pairs(self.Nails) do
			if nail and nail:IsValid() and (nail:GetAttachEntity() == self or nail:GetBaseEntity() == self) then
				return true
			end
		end
	end

	return false
end

-- 检查实体是否被直接钉在世界上（钉子附着在世界实体上）
-- 可选参数hierarchy表示是否递归检查连接的实体
function meta:IsNailedToWorld(hierarchy)
	if self:IsNailed() then
		for _, nail in pairs(self.Nails) do
			if nail:GetAttachEntity():IsWorld() then
				return true
			end
		end
	end

	if hierarchy then
		for _, ent in pairs(self:GetAllConstrainedEntities()) do
			if ent ~= self and ent:IsValid() and ent:IsNailedToWorld() then return true end
		end
	end

	return false
end

-- 检查实体是否通过约束层级被钉在世界上
function meta:IsNailedToWorldHierarchy()
	return self:IsNailedToWorld(true)
end

-- 获取实体是否因被钉住而物理冻结
function meta:GetNailFrozen()
	return self.m_NailFrozen
end

-- 别名：IsNailFrozen等同于GetNailFrozen
meta.IsNailFrozen = meta.GetNailFrozen

-- 设置实体是否因被钉住而物理冻结
-- 冻结时禁用物理运动，解冻时恢复
function meta:SetNailFrozen(frozen)
	if frozen then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() then
			self.m_NailFrozen = true
			phys:EnableMotion(false)
		end
	elseif self:IsNailFrozen() then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			self.m_NailFrozen = false
			phys:EnableMotion(true)
			phys:Wake()
		end
	end
end

-- 获取所有通过物理约束连接到此实体的实体（返回表）
function constraint.GetAllConstrainedEntitiesOrdered(ent)
	local allcons = constraint.GetAllConstrainedEntities(ent)

	local tab = {}

	if allcons then
		for k, v in pairs(allcons) do
			table.insert(tab, v)
		end
	end

	return tab
end

-- 获取所有通过物理约束连接的实体
-- 如果没有约束，则返回包含自身的表
function meta:GetAllConstrainedEntities()
	local allcons = constraint.GetAllConstrainedEntitiesOrdered(self)
	if not allcons or #allcons == 0 then
		return {self}
	end

	return allcons
end

-- 允许玩家开始打包回收一个可部署实体
-- 创建"packup"状态效果并设置其属性
function meta:PackUp(pl)
	if not self.CanPackUp then return end

	local cur = pl:GetStatus("packup")
	if cur and cur:IsValid() then return end

	local status = pl:GiveStatus("packup")
	if status:IsValid() then
		status:SetPackUpEntity(self)
		status:SetEndTime(CurTime() + (self.PackUpTime or 3) * (not self.IgnorePackTimeMul and pl.DeployablePackTimeMul or 1))

		if self.GetObjectOwner then
			local owner = self:GetObjectOwner()
			-- 如果不是管理员且不是自己的部署物，标记为非所有者
			if owner:IsValid() and owner:Team() == TEAM_HUMAN and owner ~= pl and not gamemode.Call("PlayerIsAdmin", pl) then
				status:SetNotOwner(true)
			end
		end
	end
end

-- 获取一个由多个道具组成的构造体中的道具数量
function meta:GetPropsInContraption()
	local allcons = constraint.GetAllConstrainedEntities(self)
	if not allcons or #allcons == 0 then
		return 1
	end

	return #allcons
end

-- 检查附近是否有存活的人类玩家
-- 检测范围：512单位半径（262144平方单位）
function meta:HumanNearby()
	for _, pl in pairs(team.GetPlayers(TEAM_HUMAN)) do
		if pl:Alive() and self:GetPos():DistToSqr(pl:GetPos()) <= 262144 then
			return true
		end
	end
end

-- 更新路障的最后攻击者信息
-- 如果攻击者是僵尸玩家，记录对路障造成的伤害（仅在有人类附近时）
function meta:ResetLastBarricadeAttacker(attacker, dmginfo)
	if attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD then
		self.m_LastDamagedByZombie = CurTime()

		if self:HumanNearby() then
			local dmg = math.ceil(dmginfo:GetDamage())
			attacker.BarricadeDamage = attacker.BarricadeDamage + dmg
			if attacker.LifeBarricadeDamage ~= nil then
				attacker:AddLifeBarricadeDamage(dmg)
				GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_ZOMBIECLASS, attacker:GetZombieClassTable().Name, "BarricadeDamage", dmg)
			end
		end
	end
end

-- 重写物理攻击者设置函数
-- 用于追踪func_physbox的攻击者，以便正确归因伤害
meta.OldSetPhysicsAttacker = meta.SetPhysicsAttacker
function meta:SetPhysicsAttacker(ent)
	if string.sub(self:GetClass(), 1, 12) == "func_physbox" and ent:IsValid() then
		self.PBAttacker = ent
		self.NPBAttacker = CurTime() + 5
	end
	self:OldSetPhysicsAttacker(ent)
end

-- 处理对被钉住的路障的伤害
-- 将伤害分配给路障本身和钉子，处理各种伤害减免和效果
-- 返回true表示覆盖默认行为
function meta:DamageNails(attacker, inflictor, damage, dmginfo)
	if not self:IsNailed() or self.m_NailsDontAbsorb then return end

	-- 检查是否有存活的钉子，以及实体是否为被钉住的一部分
	local nails = self:GetLivingNails()
	local isattach = false
	for i, nail in ipairs(nails) do
		isattach = self == nail:GetAttachEntity() or isattach
	end

	if self:GetBarricadeHealth() <= 0 and not isattach then return end

	-- 检查是否可以伤害钉子
	if not gamemode.Call("CanDamageNail", self, attacker, inflictor, damage, dmginfo) then
		if dmginfo then
			dmginfo:SetDamage(0)
			dmginfo:SetDamageType(DMG_GENERIC)
		end

		return true
	end

	-- 防止物理伤害（如抛射物撞击）对路障造成伤害
	if damage < 0 or dmginfo:GetDamageType() == DMG_CRUSH then
		if dmginfo then
			dmginfo:SetDamage(0)
		end

		return true
	end

	-- 处理强化效果：减少伤害并将减免量转化为增强者的点数
	if self.ReinforceEnd and CurTime() < self.ReinforceEnd and self.ReinforceApplier and self.ReinforceApplier:IsValidLivingHuman() then
		local applier = self.ReinforceApplier
		local multi = 0.92
		local dmgbefore = damage * 0.08
		local points = dmgbefore / 8

		dmginfo:SetDamage(dmginfo:GetDamage() * multi)
		damage = damage * multi

		applier.PropDef = (applier.PropDef or 0) + dmgbefore
		applier:AddPoints(points)
	end

	-- 逃生模式下的伤害缩放
	if gamemode.Call("IsEscapeDoorOpen") then
		local multi = gamemode.Call("GetEscapeStage") * 1.5

		dmginfo:SetDamage(dmginfo:GetDamage() * multi)
		damage = damage * multi
	end

	-- 更新最后攻击者信息
	self:ResetLastBarricadeAttacker(attacker, dmginfo)

	if #nails <= 0 then return end

	-- 处理攻击者的特殊效果
	if attacker:IsPlayer() then
		-- 出生保护期间伤害加倍
		if attacker.SpawnProtection then
			damage = damage * 5
			dmginfo:SetDamage(damage)
			self:AddUselessDamage(damage)
		end

		GAMEMODE:DamageFloater(attacker, self, dmginfo:GetDamagePosition(), dmginfo:GetDamage())
	end

	-- 应用伤害到路障和钉子
	self:SetBarricadeHealth(self:GetBarricadeHealth() - damage)
	for i, nail in ipairs(nails) do
		nail:OnDamaged(damage, attacker, inflictor, dmginfo)
	end

	-- 非僵尸造成的伤害标记为"无用伤害"（修复时不提供分数）
	if not attacker:IsZombie() then
		self:AddUselessDamage(damage)
	end

	attacker.LastBarricadeHit = CurTime()

	if dmginfo then dmginfo:SetDamage(0) end

	-- 如果路障生命值归零，处理破坏效果
	if self:GetBarricadeHealth() <= 0 then
		if self:GetModel() ~= "" and self:GetModel() ~= "models/error.mdl" then
			-- 无名实体且体积较小时直接破碎
			if self:GetName() == "" and self:GetVolume() < 100 then
				self:Fire("break", "", 0.01)
				self:Fire("kill", "", 0.05)
			else
				-- 大实体或有名字的实体使用env_propbroken
				local ent = ents.Create("env_propbroken")
				if ent:IsValid() then
					ent:Spawn()
					ent:AttachTo(self)
				end
			end
		end

		-- 移除所有钉子
		for _, nail in pairs(nails) do
			self:RemoveNail(nail, nil, nil, true)
		end
	end

	return true
end

-- 获取附着在该实体上的所有钉子实体（有效版本）
function meta:GetNails()
	local tab = {}

	if self.Nails then
		for _, nail in pairs(self.Nails) do
			if nail and nail:IsValid() then
				table.insert(tab, nail)
			end
		end
	end

	return tab
end

-- 获取附着在该实体上所有未损坏的钉子实体（健康值大于0）
function meta:GetLivingNails()
	local tab = {}

	if self.Nails then
		for _, nail in pairs(self.Nails) do
			if nail and nail:IsValid() and nail:GetNailHealth() > 0 then
				table.insert(tab, nail)
			end
		end
	end

	return tab
end

-- 获取附着在该实体上未损坏钉子的数量
function meta:NumLivingNails()
	local amount = 0

	if self.Nails then
		for _, nail in pairs(self.Nails) do
			if nail and nail:IsValid() and nail:GetNailHealth() > 0 then
				amount = amount + 1
			end
		end
	end

	return amount
end

-- 获取附着在该实体上的第一个有效钉子
-- 优先返回附着在无效实体上的钉子，然后返回第一个有效钉子
function meta:GetFirstNail()
	if self.Nails then
		for i, nail in ipairs(self.Nails) do
			if nail and nail:IsValid() and not nail:GetAttachEntity():IsValid() then return nail end
		end
		for i, nail in ipairs(self.Nails) do
			if nail and nail:IsValid() then return nail end
		end
	end
end

-- 查找给定钉子所属的实体（钉子所有者）
local function GetNailOwner(nail, filter)
	for _, ent in pairs(ents.GetAll()) do
		if ent and ent ~= filter and ent.Nails and ent:IsValid() then
			for __, n in pairs(ent.Nails) do
				if n == nail then
					return ent
				end
			end
		end
	end

	return game.GetWorld()
end

-- 移除连接到此实体的一个钉子
-- 处理约束移除、颜色更新、钉子列表清理和重新计算加成
function meta:RemoveNail(nail, dontremoveentity, removedby, forceremoveconstraint)
	if not self:IsNailed() then return end

	if not nail then
		nail = self:GetFirstNail()
	end

	if not nail or not nail:IsValid() then return end

	local cons = nail:GetNailConstraint()
	local othernails = 0
	-- 检查是否还有其他钉子共享同一个约束
	if not forceremoveconstraint then
		for _, othernail in pairs(ents.FindByClass("prop_nail")) do
			if othernail ~= nail and not nail.m_IsRemoving and othernail:GetNailConstraint():IsValid() and othernail:GetNailConstraint() == cons then
				othernails = othernails + 1
			end
		end
	end

	-- 如果是最后一个钉子，移除约束并更新颜色
	if othernails == 0 and cons:IsValid() then
		if self.PropHealth and self:GetBarricadeHealth() > 0 then
			local repairs_frac = self:GetBarricadeRepairs() / self:GetMaxBarricadeRepairs()

			if repairs_frac < 0.5 then
				self.PropHealth = math.min(self.PropHealth, self:GetBarricadeHealth())

				local brit = math.Clamp(self.PropHealth / self.TotalHealth, 0, 1)
				local col = self:GetColor()
				col.r = 255
				col.g = 255 * brit
				col.b = 255 * brit
				self:SetColor(col)
			end
		end
		cons:Remove()
	end

	-- 找到钉子关联的另一个实体并在其列表中移除
	local ent2 = GetNailOwner(nail, self)

	for i, n in ipairs(self.Nails) do
		if n == nail then
			table.remove(self.Nails, i)
			break
		end
	end

	if ent2 and ent2.Nails then
		for i, n in ipairs(ent2.Nails) do
			if n == nail then
				table.remove(ent2.Nails, i)
				ent2:TemporaryBarricadeObject()
				break
			end
		end
	end

	self:TemporaryBarricadeObject()

	-- 触发钉子移除事件
	gamemode.Call("OnNailRemoved", nail, self, ent2, removedby)

	if not dontremoveentity then
		nail:Remove()
		nail.m_IsRemoving = true
	end

	-- 重新计算加成并更新碰撞规则
	self:RecalculateNailBonuses()
	self:CollisionRulesChanged()

	if ent2 and ent2:IsValid() then
		ent2:CollisionRulesChanged()
	end

	return true
end

-- 在下一帧或指定时间后移除该实体
function meta:RemoveNextFrame(time)
	self.Removing = true
	self:Fire("kill", "", time or 0.01)
end

-- 临时路障定时器回调函数
-- 检查实体范围内是否还有玩家，如果没有则取消路障标记
local function barricadetimer(self, timername)
	if self:IsValid() then
		for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
			if e and e:IsValid() and e:IsPlayer() and e:Alive() then
				return
			end
		end

		self.IsBarricadeObject = nil
		self:CollisionRulesChanged()
	end

	timer.Remove(timername)
end

-- 当玩家靠近时，临时将实体标记为路障以改变碰撞规则
-- 这样玩家就无法穿过该实体了
function meta:TemporaryBarricadeObject()
	if self.IsBarricadeObject then return end

	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e and e:IsValid() and e:IsPlayer() and e:Alive() then
			self.IsBarricadeObject = true
			self:CollisionRulesChanged()

			local timername = "TemporaryBarricadeObject"..self:GetCreationID()
			timer.Create(timername, 0, 0, function() barricadetimer(self, timername) end)

			return
		end
	end
end

-- 根据存活的钉子数量重新计算路障的生命值加成
-- 每个额外钉子提供额外生命值
function meta:RecalculateNailBonuses()
	local max_health = self:GetMaxBarricadeHealth()
	if max_health == 0 then return end

	local num_extra_nails = math.Clamp(self:NumLivingNails() - 1, 0, 3)
	local repairs_frac = self:GetBarricadeRepairs() / self:GetMaxBarricadeRepairs()

	self.OriginalMaxHealth = self.OriginalMaxHealth or max_health
	self.OriginalMaxBarricadeRepairs = self.OriginalMaxBarricadeRepairs or max_repairs

	local health = self:GetBarricadeHealth()
	local new_max_health = self.OriginalMaxHealth + num_extra_nails * GAMEMODE.ExtraHealthPerExtraNail
	self:SetMaxBarricadeHealth(new_max_health)
	self:SetBarricadeHealth(health / max_health * new_max_health)

	self:SetBarricadeRepairs(repairs_frac * self:GetMaxBarricadeRepairs())
end

-- 根据部署物所有者的技能来设置部署物的生命值
-- 应用所有者的"部署物生命倍率"修正
function meta:SetupDeployableSkillHealth(extramodifier)
	local owner = self:GetObjectOwner()
	local newmaxhealth = self.MaxHealth or self:GetMaxObjectHealth()
	local currentmaxhealth = self:GetMaxObjectHealth()

	if owner:IsValid() then
		newmaxhealth = newmaxhealth * owner:GetTotalAdditiveModifier("DeployableHealthMul", extramodifier)
	end

	newmaxhealth = math.ceil(newmaxhealth)
	self:SetMaxObjectHealth(newmaxhealth)
	self:SetObjectHealth(self:GetObjectHealth() / currentmaxhealth * newmaxhealth)
end

-- 为自定义抛射物处理命中实体后的伤害计算
function meta:DealProjectileTraceDamage(damage, tr, owner)
	local ent = tr.Entity

	local damageinfo = DamageInfo()
	damageinfo:SetDamageType(DMG_BULLET)
	damageinfo:SetDamage(damage)
	damageinfo:SetDamagePosition(tr.HitPos)
	damageinfo:SetAttacker(owner)
	damageinfo:SetInflictor(self:ProjectileDamageSource())

	local vel
	if ent:IsPlayer() then
		-- 记录命中组和头部命中标记
		ent:SetLastHitGroup(tr.HitGroup)
		if tr.HitGroup == HITGROUP_HEAD then
			ent:SetWasHitInHead()
		end

		-- 缓存玩家当前速度
		vel = ent:GetVelocity()
	end

	ent:DispatchTraceAttack(damageinfo, tr, tr.Normal)

	-- 恢复玩家速度（防止击退叠加）
	if vel and ent:IsPlayer() and owner ~= ent then
		ent:SetLocalVelocity(vel)
	end
end

-- 投射物提前检测的厚度（用于碰撞箱宽度）
GM.ProjectileThickness = 3

-- 为抛射物在当前位置前方进行一次射线检测，用于提前命中判断
-- 特别用于检测僵尸或僵尸构造物
function meta:ProjectileTraceAhead(phys)
	if not self.Touched then
		local vel = self.PreVel or phys:GetVelocity()
		if self.PreVel then self.PreVel = nil end

		local velnorm = vel:GetNormalized()

		-- 计算检测距离（基于速度和帧时间）
		local ahead = (vel:LengthSqr() * FrameTime()) / 1200
		local fwd = velnorm * ahead
		local start = self:GetPos() - fwd
		local side = vel:Angle():Right() * GAMEMODE.ProjectileThickness

		local proj_trace = {mask = MASK_SHOT, filter = {self, team.GetPlayers(TEAM_HUMAN)}}

		-- 在投射物的两侧各进行一次检测
		proj_trace.start = start - side
		proj_trace.endpos = start - side + fwd

		local tr = util.TraceLine(proj_trace)

		proj_trace.start = start + side
		proj_trace.endpos = start + side + fwd

		local tr2 = util.TraceLine(proj_trace)
		local trs = {tr, tr2}

		-- 如果任一侧检测到僵尸或僵尸构造物，则标记为已触碰
		for _, trace in pairs(trs) do
			if trace.Entity then
				local ent = trace.Entity

				if ent:IsValidLivingZombie() or ent.ZombieConstruction then
					self.Touched = trace
				end

				break
			end
		end
	end
end

-- 定时缓存所有隐形或应被忽略追踪的实体
-- 用于优化TrueVisible函数的性能
GM.CachedInvisibleEntities = {}
timer.Create("CachedInvisibleEntities", 1, 0, function()
	if not GAMEMODE then return end
	GAMEMODE.CachedInvisibleEntities = {}

	local invisents = player.GetAll()
	for _, ent in pairs(ents.GetAll()) do
		if ent.IgnoreTraces or ent.NoBlockExplosions then
			invisents[#invisents + 1] = ent
		end
	end

	GAMEMODE.CachedInvisibleEntities = invisents
end)
