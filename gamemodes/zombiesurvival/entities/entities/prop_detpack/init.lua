-- ============================================================================
-- init.lua - 遥控炸药包（服务端）
-- 负责：布防、认领/引爆流程、大范围爆炸伤害，以及玩家离线/换队时解除所有权
-- ============================================================================
INC_SERVER()

-- ==== RefreshDetpackOwners - 清除玩家名下的所有炸药包 ====
-- 玩家掉线或换队时，将其名下未引爆的炸药包所有权置空（防止他人无法引爆）
local function RefreshDetpackOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_detpack")) do
		if ent:IsValid() and ent:GetOwner() == pl then
			ent:SetOwner(NULL)
		end
	end
end
hook.Add("PlayerDisconnected", "Detpack.PlayerDisconnected", RefreshDetpackOwners)
hook.Add("OnPlayerChangedTeam", "Detpack.OnPlayerChangedTeam", RefreshDetpackOwners)

-- 警示音（嘀声）节流计时
ENT.NextBlip = 0

-- ==== Initialize - 初始化炸药包 ====
-- 记录放置时间、设置 C4 模型与静态物理，并放入碎片触发器碰撞组
function ENT:Initialize()
	self.CreateTime = CurTime()

	self:SetModel("models/weapons/w_c4_planted.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
end

-- ==== AltUse - 右键收起炸药包 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== OnTakeDamage - 受击处理 ====
-- 单次受击伤害 ≥ 9 且攻击者非人类时强制引爆（僵尸踩踏/击打会引爆）
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if dmginfo:GetDamage() <= 0 then return end

	-- 未引爆且单次伤害达到阈值时引爆（人类攻击不触发）
	if not self.Exploded and dmginfo:GetDamage() >= 9 then
		local attacker = dmginfo:GetAttacker()
		if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
			self.ForceExplode = true
			self:Explode()
		end
	end
end

-- ==== Use - 玩家使用（认领）炸药包 ====
-- 布防期后，人类可认领无主或属于自己的炸药包，并获得引爆遥控器
function ENT:Use(activator, caller)
	-- 已爆炸/已被引爆/使用者非人类/已被别的炸药包覆盖材质时拒绝认领
	if self.Exploded or self:GetExplodeTime() ~= 0 or not activator:IsPlayer() or activator:Team() ~= TEAM_HUMAN or self:GetMaterial() ~= "" then return end

	-- 无主炸药包或本人自己的炸药包可以认领
	if self:GetOwner() == activator or not self:GetOwner():IsValid() then
		self:SetOwner(activator)

		-- 没有引爆遥控器则发放并切换过去
		if not activator:HasWeapon("weapon_zs_detpackremote") then
			activator:Give("weapon_zs_detpackremote")
		end
		activator:SelectWeapon("weapon_zs_detpackremote")
	end
end

-- ==== Explode - 引爆炸药包 ====
-- 对半径 256 单位内造成 480 点范围伤害，并播放爆炸音效/尘土粒子/灼烧痕迹
function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if owner:IsValidHuman() then
		local pos = self:GetPos()

		-- 以炸药包位置为中心的大范围高额爆炸伤害（来源记为自己）
		util.BlastDamagePlayer(self, owner, pos, 256, 480, DMG_ALWAYSGIB)

		-- 在爆炸点下方地面留下灼烧痕迹
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetNormal(self:GetUp() * -1)
		util.Effect("decal_scorch", effectdata)

		-- 三连爆炸音效与尘土粒子（每次叠加音量）
		for i=1, 3 do
			self:EmitSound("npc/env_headcrabcanister/explosion.wav", 75 + i * 5, 100)
		end
		for i=1, 2 do
			ParticleEffect("dusty_explosion_rockets", pos, angle_zero)
		end
	end
end

-- ==== Think - 每帧驱动引爆流程 ====
-- 引爆后立即移除；已设定引爆时间时：到点爆炸，未到点则周期性播放嘀声警示
function ENT:Think()
	-- 爆炸完成，移除实体
	if self.Exploded then
		self:Remove()
		return
	end

	-- 已被遥控引爆：到点爆炸，倒计时期间每 0.4 秒播一次 C4 嘀声
	if self:GetExplodeTime() ~= 0 then
		if CurTime() >= self:GetExplodeTime() then
			self:Explode()
		elseif self.NextBlip <= CurTime() then
			self.NextBlip = CurTime() + 0.4
			self:EmitSound("weapons/c4/c4_beep1.wav")
		end
	end

	self:NextThink(CurTime())
	return true
end

-- ==== OnPackedUp - 收起完成回调 ====
-- 返还炸药包武器与 1 发弹药后移除自身
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon("weapon_zs_detpack")
	pl:GiveAmmo(1, "sniperpenetratedround")

	self:Remove()
end

-- ==== SetExplodeTime - 设定引爆时间 ====
-- 布防期内禁止设置（防开局秒炸），过布防期后写入引爆时间戳
function ENT:SetExplodeTime(time)
	if self.CreateTime + self.ArmTime > CurTime() then return end

	self:SetDTFloat(0, time)
end
