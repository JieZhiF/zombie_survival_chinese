-- ============================================================================
-- prop_zapper/init.lua - 电击陷阱（服务器）
-- 负责：可部署的自动电击装置：消耗弹药自动索敌（优先头部蟹，次选低
--       血量僵尸），造成电击伤害与腿部伤害；拥有者断线/换队时清除
--       所有权，耐久归零时爆炸并散落一半脉冲弹药
-- ============================================================================
INC_SERVER()

-- ==== RefreshZapperOwners - 拥有者断线/换队时清除其名下所有电击陷阱的所有权 ====
local function RefreshZapperOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_zapper*")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:ClearObjectOwner()
		end
	end
end
-- 玩家断线与换队时触发所有权清理
hook.Add("PlayerDisconnected", "Zapper.PlayerDisconnected", RefreshZapperOwners)
hook.Add("OnPlayerChangedTeam", "Zapper.OnPlayerChangedTeam", RefreshZapperOwners)

-- ==== Initialize - 初始化：模型、固定物理与耐久 ====
function ENT:Initialize()
	-- 使用接线盒模型并缩小 0.75 倍
	self:SetModel("models/props_c17/utilityconnecter006c.mdl")
	self:SetModelScale(0.75, 0)
	self:PhysicsInit(SOLID_VPHYSICS)
	-- 世界碰撞组：不与其他物理物体互相推挤
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	self:CollisionRulesChanged()

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		-- 固定放置
		phys:EnableMotion(false)
		phys:Wake()
	end

	-- 耐久上限 150
	self:SetMaxObjectHealth(150)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	-- 下一次索敌检查时间
	self.NextZapCheck = CurTime()
end

-- ==== SetObjectHealth - 设置耐久；归零时爆炸、散落弹药并移除 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(1, health)
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

		-- 散落一半的脉冲弹药（每堆最多 50 发），随机方向抛射
		local amount = math.ceil(self:GetAmmo() * 0.5)
		while amount > 0 do
			local todrop = math.min(amount, 50)
			amount = amount - todrop
			ent = ents.Create("prop_ammo")
			if ent:IsValid() then
				local heading = VectorRand():GetNormalized()
				ent:SetAmmoType("pulse")
				ent:SetAmmo(todrop)
				ent:SetPos(pos + heading * 8)
				ent:SetAngles(VectorRand():Angle())
				ent:Spawn()

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:ApplyForceOffset(heading * math.Rand(8000, 32000), pos)
				end
			end
		end
	end
end

-- ==== OnTakeDamage - 受伤处理：非人类阵营攻击者造成耐久损失 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	self:TakePhysicsDamage(dmginfo)

	local attacker = dmginfo:GetAttacker()
	-- 仅非人类阵营的攻击削减耐久
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
	end
end

-- ==== Use - 使用：认领电击器或存入脉冲弹药 ====
function ENT:Use(activator, caller)
	-- 移除中/非玩家/已被破坏（材质被替换）时拒绝使用
	if self.Removing or not activator:IsPlayer() or self:GetMaterial() ~= "" then return end

	if activator:Team() == TEAM_HUMAN then
		if self:GetObjectOwner():IsValid() then
			-- 已有拥有者：存入脉冲弹药（未关闭 zs_nousetodeposit 选项时）
			if activator:GetInfo("zs_nousetodeposit") == "0" then
				local curammo = self:GetAmmo()
				local togive = math.min(math.min(50, activator:GetAmmoCount("pulse")), self.MaxAmmo - curammo)
				if togive > 0 then
					self:SetAmmo(curammo + togive)
					activator:RemoveAmmo(togive, "pulse")
					activator:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)
					self:EmitSound("npc/scanner/combat_scan1.wav", 60, 250)
				end
			end
		else
			-- 尚无拥有者：当前玩家认领
			self:SetObjectOwner(activator)
			self:GetObjectOwner():SendDeployableClaimedMessage(self)
		end
	end
end

-- ==== AltUse - 右键打包收起 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnPackedUp - 打包完成：归还武器、部署弹药与剩余脉冲弹药 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.SWEP)
	pl:GiveAmmo(1, self.DeployableAmmo)

	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())
	pl:GiveAmmo(self:GetAmmo(), "pulse")

	self:Remove()
end

-- ==== FindZapperTarget - 索敌：在范围内找存活僵尸，优先头部蟹与低血量 ====
function ENT:FindZapperTarget(pos, owner)
	local target
	local targethealth = 99999
	local isheadcrab

	-- 遍历范围 135 单位（可被拥有者范围加成放大）内的实体
	for k, ent in pairs(ents.FindInSphere(pos, 135 * (owner.FieldRangeMul or 1))) do
		if ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive then
			isheadcrab = ent:IsHeadcrab()
			-- 头部蟹优先（直接锁定），否则选择血量最低且视线可达的目标
			if (isheadcrab or ent:Health() < targethealth) and TrueVisibleFiltered(pos, ent:NearestPoint(pos), self, ent) then
				targethealth = ent:Health()
				target = ent

				if isheadcrab then
					break
				end
			end
		end
	end

	return target
end

-- ==== Think - 主循环：冷却结束且有弹药时自动索敌并电击 ====
function ENT:Think()
	-- 已摧毁：移除自身
	if self.Destroyed then
		self:Remove()
		return
	end

	-- 冷却未结束：跳过本次
	if CurTime() < self:GetNextZap() or CurTime() < self.NextZapCheck then return end

	local curammo = self:GetAmmo()
	local owner = self:GetObjectOwner()
	-- 弹药 ≥ 2 且有有效拥有者才开火
	if curammo >= 2 and owner:IsValid() then
		self.NextZapCheck = CurTime() + 0.4

		local pos = self:LocalToWorld(Vector(0, 0, 24))
		local target = self:FindZapperTarget(pos, owner)

		if target then
			-- 每次电击消耗 2 发弹药
			self:SetAmmo(curammo - 2)
			-- 弹药耗尽时提醒拥有者
			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			-- 电击冷却 3 秒（可被拥有者延迟加成调整）
			self:SetNextZap(CurTime() + 3 * (owner.FieldDelayMul or 1))

			-- 对目标施加腿部伤害与减速
			target:AddLegDamageExt(self.LegDamage, owner, self, SLOWTYPE_PULSE)

			-- 伤害结算期间应用得分倍率
			if self.PointsMultiplier then
				POINTSMULTIPLIER = self.PointsMultiplier
			end
			target:TakeSpecialDamage(self.Damage, DMG_SHOCK, owner, self)
			if self.PointsMultiplier then
				POINTSMULTIPLIER = nil
			end

			-- 播放电弧特效与电击音效
			local effectdata = EffectData()
				effectdata:SetOrigin(target:WorldSpaceCenter())
				effectdata:SetStart(pos)
				effectdata:SetEntity(self)
			util.Effect("tracer_zapper", effectdata)

			self:EmitSound("ambient/levels/labs/electric_explosion5.wav", 80, 200)
		end
	end

	-- 每帧续约 Think
	self:NextThink(CurTime())
	return true
end
