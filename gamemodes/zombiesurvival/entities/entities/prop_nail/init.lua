-- ============================================================================
-- prop_nail - 路障钉子实体（服务端）
-- 负责：实现钉子的放置/焊接/路障血量初始化/输入处理/移除回收等完整服务端逻辑
-- ============================================================================
INC_SERVER()

-- 下次播放受力音效的时间（限频用）
ENT.m_NextStrainSound = 0

-- 玩家首次出生时，将属于该玩家（按 SteamID64 匹配）的钉子重新指定放置者
hook.Add("PlayerInitialSpawn", "NailPlayerInitialSpawn", function(pl)
	local uid = pl:SteamID64()

	for _, nail in pairs(ents.FindByClass("prop_nail")) do
		if nail:GetOwnerUID() == uid then
			nail:SetDeployer(pl)
		end
	end
end)

-- ==== Initialize - 初始化模型与默认属性（不可移除标记/血量覆盖/血量倍率） ====
function ENT:Initialize()
	self:SetModel("models/crossbow_bolt.mdl")
	self:SetModelScale(0.75)
	self.m_NailUnremovable = self.m_NailUnremovable or false
	self.HealthOveride = self.HealthOveride or -1
	self.HealthMultiplier = self.HealthMultiplier or 1
end

-- ==== OnDamaged - 钉子受击时按伤害量限频播放金属受力音效，音调随血量降低而升高 ====
function ENT:OnDamaged(damage, attacker, inflictor, dmginfo)
	-- 限频播放：冷却时间随单次伤害增大而变长（最多 1 秒）
	if CurTime() >= self.m_NextStrainSound then
		self.m_NextStrainSound = CurTime() + math.min(damage * 0.025, 1)
		self:EmitSound("physics/metal/metal_box_impact_hard"..math.random(3)..".wav", math.Clamp(damage * 2.5, 60, 80), math.min(255, 150 + (1 - (self:GetNailHealth() / self:GetMaxNailHealth())) * 100))
	end
end

-- ==== AttachTo - 将钉子钉在基座与附着实体之间：登记钉子列表、建立父级绑定并初始化路障血量 ====
function ENT:AttachTo(baseent, attachent, physbone, physbone2)
	self:SetBaseEntity(baseent)
	self:SetAttachEntity(attachent, physbone, physbone2)

	-- 在双方实体的钉子列表上登记本钉子
	if not baseent.Nails then baseent.Nails = {} end
	if not attachent.Nails then attachent.Nails = {} end

	table.insert(baseent.Nails, self)
	table.insert(attachent.Nails, self)

	-- 以父实体方式绑定到基座，随其移动
	self:SetParentPhysNum(physbone or 0)
	self:SetParent(baseent)

	-- 更新双方的碰撞规则（影响路障行为）
	if baseent:IsValid() then
		baseent:CollisionRulesChanged()
	end
	if attachent:IsValid() then
		attachent:CollisionRulesChanged()
	end

	-- 首次钉入（路障血量仍为 0）时按覆盖值/倍率初始化路障血量与修理次数
	if baseent:GetBarricadeHealth() == 0 then
		local health = baseent:GetDefaultBarricadeHealth()
		if self.HealthOveride and self.HealthOveride > 0 then health = self.HealthOveride end
		health = health * (self.HealthMultiplier or 1)
		baseent:SetMaxBarricadeHealth(health)
		baseent:SetBarricadeHealth(health)
		baseent:SetBarricadeRepairs(baseent:GetMaxBarricadeRepairs())
	end

	-- 重算钉子数量带来的路障加成
	baseent:RecalculateNailBonuses()
end

-- ==== SetAttachEntity - 建立基座与附着实体间的焊接约束并记录约束引用 ====
function ENT:SetAttachEntity(ent, physbone1, physbone2)
	self.m_AttachEntity = ent

	local baseent = self:GetBaseEntity()
	if not baseent:IsValid() then return end

	-- 创建焊接约束；若基座已存在同目标的旧约束则复用旧约束
	local cons = constraint.Weld(baseent, ent, physbone1 or 0, physbone2 or 0, 0, true)
	if cons ~= nil then
		for _, oldcons in pairs(constraint.FindConstraints(baseent, "Weld")) do
			if oldcons.Ent1 == ent or oldcons.Ent2 == ent then
				cons = oldcons.Constraint
				break
			end
		end
	end

	-- 约束随钉子移除而自动删除，并在短暂延迟后重新评估道具冻结状态
	cons:DeleteOnRemove(self)
	self:SetNailConstraint(cons)

	if baseent:IsValid() then
		baseent:CollisionRulesChanged()
	end
	if ent and ent:IsValid() then
		ent:CollisionRulesChanged()
	end

	timer.Simple(0.1, function() GAMEMODE:EvaluatePropFreeze() end)

	return cons
end

-- ==== SetNailConstraint - 记录钉子关联的焊接约束 ====
function ENT:SetNailConstraint(const)
	self.m_Constraint = const
end

-- ==== GetNailConstraint - 获取钉子关联的焊接约束 ====
function ENT:GetNailConstraint()
	return self.m_Constraint or NULL
end

-- ==== SetOwnerUID - 记录放置者的 SteamID64 ====
function ENT:SetOwnerUID(uid)
	self.OwnerUID = uid
end

-- ==== GetOwnerUID - 读取放置者的 SteamID64 ====
function ENT:GetOwnerUID()
	return self.OwnerUID
end

-- ==== SetDeployer - 设置放置者：支持字符串（名字）与玩家实体两种形式 ====
function ENT:SetDeployer(pl)
	if not pl then return end

	-- 字符串形式：按名字记录，同时清空实体拥有者与 UID
	if type(pl) == "string" then
		self:SetDTString(0, pl)
		self:SetOwner(NULL)
		self:SetOwnerUID(nil)
	elseif pl:IsValid() then
		-- 玩家实体形式：记录名字、拥有者与 SteamID64
		self:SetDTString(0, "")
		self:SetOwner(pl)
		self:SetOwnerUID(pl:SteamID64())
	end
end

-- ==== SetNewHealth - 直接设置基座路障的当前血量 ====
function ENT:SetNewHealth(health)
	baseent = self:GetBaseEntity()
	baseent:SetBarricadeHealth(health)
end

-- ==== AcceptInput - 处理 Hammer 输入：attachto/nailto/setname/sethealth/不可移除开关等 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "attachto" then
		-- 将钉子父级绑定到指定名字的实体
		local ent = ents.FindByName(args)[1]
		if ent and ent:IsValid() then
			self:SetParent(ent)
		end

		return true
	elseif name == "nailto" then
		-- 将钉子钉到指定名字的实体上（worldspawn 视为世界）
		if self:GetParent():IsValid() then
			local ent = args == "worldspawn" and game.GetWorld() or ents.FindByName(args)[1]
			if ent then
				self:AttachTo(self:GetParent(), ent)
			end
		end

		return true
	elseif name == "setname" or name == "setdeployer" then
		self:SetDeployer(args)

		return true
	elseif name == "sethealth" then
		self:SetNewHealth(args)

		return true
	elseif name == "setunremoveable" or name == "setunremovable" then
		-- 设置钉子是否不可移除（1 为不可移除）
		self.m_NailUnremovable = tonumber(args) == 1

		return true
	elseif name == "toggleunremoveable" or name == "toggleunremovable" then
		-- 切换钉子是否不可移除
		self.m_NailUnremovable = not self.m_NailUnremovable

		return true
	end
end

-- ==== OnRemove - 钉子移除时从基座与附着实体上解除钉接 ====
function ENT:OnRemove()
	-- 防止移除过程中的递归调用
	if self.m_IsRemoving then return end

	local baseent = self:GetBaseEntity()
	if baseent:IsValid() and not baseent:IsWorld() then
		baseent:RemoveNail(self, nil, nil, true)
	end
	local attachent = self:GetAttachEntity()
	if attachent:IsValid() and not attachent:IsWorld() then
		attachent:RemoveNail(self, nil, nil, true)
	end
end

-- ==== KeyValue - 解析 Hammer 键值：不可移除标记/血量覆盖/血量倍率 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "unremoveable" or key == "unremovable" then
		self.m_NailUnremovable = tonumber(value) == 1
	elseif key == "healthoverride" then
		self.HealthOveride = tonumber(value)
	elseif key == "healthmultiplier" then
		self.HealthMultiplier = tonumber(value)
	end
end
