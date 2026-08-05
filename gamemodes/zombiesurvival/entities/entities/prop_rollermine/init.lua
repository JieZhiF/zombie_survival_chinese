-- ============================================================================
-- prop_rollermine/init.lua - 滚动地雷（服务器）
-- 负责：遥控移动/撞击伤害/耐久管理/销毁爆炸；支持技能加成、
--       背包打包回收、入水自损与碰撞残骸生成
-- ============================================================================
INC_SERVER()

-- 入水伤害的结算节流时间戳
ENT.NextWaterDamage = 0
-- 遥控跳跃的冷却时间戳
ENT.NextJump = 0

-- ==== Initialize - 初始化：设置模型与物理、血量同步、命中盒与可见性钩子 ====
function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetUseType(SIMPLE_USE)

	self:PhysicsInit(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(self.Mass)
		phys:EnableDrag(false)
		phys:EnableMotion(true)
		phys:Wake()
		phys:SetBuoyancyRatio(0.8)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
	end

	self:StartMotionController()

	-- 初始化血量同步字段
	self:SetMaxObjectHealth(self.MaxHealth)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	self.LastThink = CurTime()
	self.NextTouch = {}

	self:UseClientSideAnimation(true)

	-- 创建自定义命中盒（fhb），用于精确的撞击判定
	local ent = ents.Create("fhb")
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetParent(self)
		ent:SetOwner(self)
		ent.Size = self.HitBoxSize
		ent:Spawn()
		ent.IgnoreMelee = false
	end

	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()

	-- 控制者视角可见性：保证遥控时地雷始终加载
	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end

-- ==== SetupPlayerSkills - 技能加成：调整血量/速度/加速度，装载技能附加模型 ====
function ENT:SetupPlayerSkills()
	local owner = self:GetObjectOwner()
	local newmaxhealth = self.MaxHealth
	local currentmaxhealth = self:GetMaxObjectHealth()
	local defaults = scripted_ents.Get(self:GetClass())
	local hitdamage = defaults.HitDamage
	local maxspeed = defaults.MaxSpeed
	local acceleration = defaults.Acceleration
	local loaded = false

	-- 按拥有者的技能/加成倍率缩放基础属性
	if owner:IsValid() then
		newmaxhealth = newmaxhealth * owner:GetTotalAdditiveModifier("ControllableHealthMul")
		maxspeed = maxspeed * (owner.ControllableSpeedMul or 1)
		acceleration = acceleration * (owner.ControllableHandlingMul or 1)
		loaded = owner:IsSkillActive(SKILL_LOADEDHULL)
	end

	newmaxhealth = math.ceil(newmaxhealth)

	-- 按比例迁移当前血量到新的上限
	self:SetMaxObjectHealth(newmaxhealth)
	self:SetObjectHealth(self:GetObjectHealth() / currentmaxhealth * newmaxhealth)

	self.HitDamage = hitdamage
	self.MaxSpeed = maxspeed
	self.Acceleration = acceleration

	-- 装载技能：附加丙烷罐模型作为视觉与爆炸来源
	if loaded then
		if not IsValid(self.LoadedProp) then
			local ent = ents.Create("prop_dynamic_override")
			if ent:IsValid() then
				ent:SetModel("models/props_junk/propane_tank001a.mdl")
				ent:SetModelScale(0.5, 0)
				ent:SetParent(self)
				ent:SetOwner(self)
				ent:SetLocalPos(Vector(-7, 0, -8.5))
				ent:SetLocalAngles(Angle(-40, 0, 0))
				ent:Spawn()

				self.LoadedProp = ent
			end
		end
	elseif IsValid(self.LoadedProp) then
		self.LoadedProp:Remove()
	end
end

-- ==== SetObjectHealth - 服务器版血量写入：归零立即销毁 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 then
		self:Destroy()
	end
end

-- ==== OnTakeDamage - 受伤处理：人类攻击豁免、酸液翻倍、预警音与火花 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	-- 人类玩家的直接攻击不造成伤害（防止误伤己方部署物）
	local attacker = dmginfo:GetAttacker()
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then return end

	self:TakePhysicsDamage(dmginfo)

	-- 酸液伤害翻倍
	if dmginfo:GetDamageType() == DMG_ACID then
		dmginfo:SetDamage(dmginfo:GetDamage() * 2)
	end

	self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())

	-- 僵尸近战攻击时播放预起爆警示音
	if attacker:IsValidZombie() and dmginfo:GetInflictor().MeleeDamage then
		self:EmitSound("npc/roller/mine/rmine_predetonate.wav")
	end

	-- 受伤位置溅射火花
	local effectdata = EffectData()
		effectdata:SetOrigin(self:NearestPoint(dmginfo:GetDamagePosition()))
		effectdata:SetNormal(VectorRand():GetNormalized())
		effectdata:SetMagnitude(4)
		effectdata:SetScale(1.33)
	util.Effect("sparks", effectdata)
end

-- ==== Use - 使用交互：仅存活的拥有者人类可收拢打包 ====
function ENT:Use(pl)
	if pl == self:GetObjectOwner() and pl:Team() == TEAM_HUMAN and pl:Alive() then
		self:OnPackedUp(pl)
	end
end

-- ==== PhysicsCollide - 物理碰撞：记录碰撞数据待下帧结算 ====
function ENT:PhysicsCollide(data, phys)
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== OnPackedUp - 收拢打包：归还武器弹药，以剩余血量存入背包 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.WeaponClass)
	pl:GiveAmmo(1, self.AmmoType)

	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())

	self:Remove()
end

local trace = {mask = MASK_SOLID}
-- ==== PhysicsSimulate - 遥控移动模拟：方向键驱动、跳跃、阻力与速度钳制 ====
function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local owner = self:GetObjectOwner()
	-- 拥有者失效或处于控制禁用窗口内时不做移动处理
	if not owner:IsValid() or self.DisableControlUntil and CurTime() < self.DisableControlUntil then return SIM_NOTHING end

	local vel = phys:GetVelocity()
	local movedir = Vector(0, 0, 0)
	local aimangles = owner:EyeAngles()
	local onground = false

	if self:BeingControlled() then
		-- 检测是否着地：向正下方打一条碰撞追踪
		trace.filter = self
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, self:OBBMins().z - 8)
		local tr = util.TraceLine(trace)
		onground = tr.Hit

		-- 以玩家视角方向解析 WASD 移动输入
		if owner:KeyDown(IN_FORWARD) then
			movedir = movedir + aimangles:Forward()
		end
		if owner:KeyDown(IN_BACK) then
			movedir = movedir - aimangles:Forward()
		end
		if owner:KeyDown(IN_MOVERIGHT) then
			movedir = movedir + aimangles:Right()
		end
		if owner:KeyDown(IN_MOVELEFT) then
			movedir = movedir - aimangles:Right()
		end

		-- 冲撞键 + 着地 + 低速时可跳跃（带 1 秒冷却）
		if owner:KeyDown(IN_BULLRUSH) and onground and self.NextJump < CurTime() and vel:Length() <= 48 then
			vel.z = vel.z + 180
			self.NextJump = CurTime() + 1
		end
	end

	-- 无输入时按闲置阻力减速；有输入时加速（血量越低加速越弱，空中加速大幅削弱）
	if movedir == vector_origin then
		vel = vel * (1 - frametime * self.IdleDrag)
	else
		movedir.z = math.min(0, math.abs(movedir.z))
		movedir:Normalize()

		vel = vel + frametime * self.Acceleration * 0.55 * math.Clamp((self:GetObjectHealth() / self:GetMaxObjectHealth() + 1) / 2, 0.5, 1) * (onground and 1 or 0.1) * movedir
	end

	-- 速度钳制到最大速度
	if vel:Length() > self.MaxSpeed then
		vel:Normalize()
		vel = vel * self.MaxSpeed
	end

	phys:SetDragCoefficient(10)
	phys:SetVelocityInstantaneous(vel)
	phys:AddAngleVelocity(vel * 0.15)

	self:SetPhysicsAttacker(owner)

	return SIM_NOTHING
end

-- ==== Destroy - 销毁结算：提示丢失、特效音效；装载技能时爆炸伤人 ====
function ENT:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	local epicenter = self:LocalToWorld(self:OBBCenter())

	-- 拥有者存活时发送部署物丢失提示
	if self:GetObjectOwner():IsValidLivingHuman() then
		self:GetObjectOwner():SendDeployableLostMessage(self)
	end

	self:EmitSound("npc/manhack/gib.wav")

	local effectdata = EffectData()
		effectdata:SetOrigin(epicenter)
		effectdata:SetNormal(Vector(0, 0, 1))
		effectdata:SetMagnitude(5)
		effectdata:SetScale(1.5)
	util.Effect("sparks", effectdata)

	local owner = self:GetObjectOwner()
	-- 装载技能：产生爆炸伤害并留下灼烧痕迹
	if owner:IsValidLivingHuman() and owner:IsSkillActive(SKILL_LOADEDHULL) then
		effectdata = EffectData()
			effectdata:SetOrigin(epicenter)
			effectdata:SetNormal(Vector(0, 0, -1))
		util.Effect("decal_scorch", effectdata)

		self:EmitSound("npc/env_headcrabcanister/explosion.wav", 100, 100)
		ParticleEffect("dusty_explosion_rockets", epicenter, angle_zero)

		util.BlastDamagePlayer(self, owner, epicenter, 128, 225, DMG_ALWAYSGIB)
	else
		-- 普通销毁：播放直升机炸弹特效
		util.Effect("HelicopterMegaBomb", effectdata, true, true)
	end
end

-- 物理伤害免疫窗口结束时间（被人类物理推动后短暂免疫）
ENT.PhysDamageImmunity = 0
-- ==== Think - 主循环：销毁残骸、拥有者检查、模型恢复、入水伤害与碰撞结算 ====
function ENT:Think()
	if self.Destroyed then
		-- 销毁后生成物理残骸碎片再移除本体
		if not self.CreatedDebris then
			self.CreatedDebris = true

			local ent = ents.Create("prop_physics")
			if ent:IsValid() then
				ent:SetPos(self:GetPos())
				ent:SetAngles(self:GetAngles())
				ent:SetModel(self:GetModel())
				ent:Spawn()
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(self:GetVelocity())
				end

				ent:Fire("break")
				ent:Fire("kill", "", 0.05)
			end
		end

		self:Remove()
		return
	end

	-- 拥有者失效或不再是存活人类时销毁
	local owner = self:GetObjectOwner()
	if owner:IsValid() then
		self:SetPhysicsAttacker(owner)

		if not owner:Alive() or owner:Team() ~= TEAM_HUMAN then
			self:Destroy()
			return
		end
	else
		self:Destroy()
		return
	end

	-- 撞击后尖刺模型到期，恢复普通模型
	if self.ChangeBackTime and self.ChangeBackTime < CurTime() then
		self:SetModel("models/roller.mdl")
		self:EmitSound("npc/roller/mine/rmine_blades_out1.wav", 65, 80)
		self.ChangeBackTime = nil
	end

	-- 浸入水中持续自损（每 0.2 秒 10 点）
	if self:WaterLevel() >= 2 and CurTime() >= self.NextWaterDamage then
		self.NextWaterDamage = CurTime() + 0.2

		self:TakeDamage(10)
	end

	-- 结算上一帧记录的物理碰撞
	local data = self.HitData
	if data then
		self.HitData = nil
		self:ThreadSafePhysicsCollide(data)
	end
end

-- ==== ThreadSafePhysicsCollide - 碰撞结算：撞击伤害、反弹、尖刺切换 ====
function ENT:ThreadSafePhysicsCollide(data)
	local owner = self:GetObjectOwner()
	if not owner:IsValidLivingHuman() then return end

	local hitflesh = false
	local ent = data.HitEntity

	-- 命中实体在冷却期外时结算撞击
	if ent and ent:IsValid() and CurTime() >= (self.NextTouch[ent] or 0) then
		self.NextTouch[ent] = CurTime() + self.HitCooldown

		-- 命中存活亡灵：造成切割伤害
		if ent:IsPlayer() and ent:Team() == TEAM_UNDEAD and ent:Alive() then
			ent:TakeSpecialDamage(self.HitDamage, DMG_SLASH, owner, self)
			hitflesh = true
		else
			-- 被人类玩家物理推动时给予短暂物理伤害免疫
			local physattacker = ent:GetPhysicsAttacker()
			if physattacker:IsValid() and physattacker:Team() == TEAM_HUMAN then
				self.PhysDamageImmunity = CurTime() + 0.5
			end
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(self:NearestPoint(data.HitPos))
		effectdata:SetNormal(data.HitNormal)

	if hitflesh then
		-- 命中血肉：播放音效、喷血、反弹并切换为尖刺模型，短暂禁用控制
		self:EmitHitFleshSound()

		local dir = (self:GetPos() - data.HitPos):GetNormalized()

		util.Blood(data.HitPos, math.random(10, 14), dir, 200)

		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			dir.z = dir.z + 0.5

			phys:AddVelocity(dir * self.BounceFleshVelocity)
		end

		effectdata:SetStart(ent:WorldSpaceCenter())
		effectdata:SetEntity(self)
		util.Effect("tracer_zapper", effectdata)

		self:SetModel("models/roller_spikes.mdl")
		self.ChangeBackTime = CurTime() + 0.25
		self.DisableControlUntil = CurTime() + 1
	elseif data.DeltaTime > 0.33 and data.Speed > 200 then
		-- 高速撞击硬表面：播放碰撞音与火花
		self:EmitHitSound()

		effectdata:SetMagnitude(2)
		effectdata:SetScale(1)
		util.Effect("sparks", effectdata)
	end
end

-- ==== EmitHitFleshSound - 命中血肉音效 ====
function ENT:EmitHitFleshSound()
	self:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
end

-- ==== EmitHitSound - 命中硬表面音效 ====
function ENT:EmitHitSound()
	self:EmitSound("npc/manhack/grind"..math.random(5)..".wav")
end

-- ==== SetupPlayerVisibility - 可见性：将地雷位置加入拥有者的 PVS ====
function ENT:SetupPlayerVisibility(pl)
	if pl ~= self:GetObjectOwner() then return end

	AddOriginToPVS(self:GetPos())
end
