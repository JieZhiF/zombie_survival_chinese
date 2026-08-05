-- ============================================================================
-- prop_drone/init.lua - 无人机（服务器）
-- 负责：可部署、可驾驶的武装无人机：拥有者控制飞行与机炮射击，属性
--       受技能加成（血量/速度/操控/负重/装甲）；坠毁时爆炸并散落弹药
-- ============================================================================
INC_SERVER()

-- 水中伤害的结算间隔冷却（初始为 0）
ENT.NextWaterDamage = 0

-- ==== Initialize - 初始化：模型、物理、保持竖直约束与运动控制器 ====
function ENT:Initialize()
	-- 使用联合扫描器模型
	self:SetModel("models/combine_scanner.mdl")
	self:SetUseType(SIMPLE_USE)

	-- 先按包围盒初始化物理，再切换为 vphysics
	self:PhysicsInitBox(Vector(-30, -17, -14.15), Vector(18.29, 11.86, 15))
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(75)
		-- 无空气阻力、可自由运动
		phys:EnableDrag(false)
		phys:EnableMotion(true)
		phys:Wake()
		phys:SetBuoyancyRatio(0.8)
		-- 不受撞击伤害
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

		-- 保持竖直的物理约束（角度限制 2 度），随无人机一起销毁
		local Constraint = ents.Create("phys_keepupright")
		Constraint:SetAngles(Angle(0, 0, 0))
		Constraint:SetKeyValue("angularlimit", 2)
		Constraint:SetPhysConstraintObjects(phys, phys)
		Constraint:Spawn()
		Constraint:Activate()
		self:DeleteOnRemove(Constraint)
	end

	-- 启用运动控制器（由 PhysicsSimulate 驱动）
	self:StartMotionController()

	self:SetMaxObjectHealth(self.MaxHealth)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	self.LastThink = CurTime()

	-- 动画：飞行姿态
	self:SetSequence(2)
	self:SetPlaybackRate(1)
	self:UseClientSideAnimation(true)
	-- 自定义碰撞回调（用于物理撞击检测）
	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()

	-- 为拥有者扩展 PVS 可见性
	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end

-- ==== SetupPlayerSkills - 按拥有者技能重算无人机属性并挂载装甲 ====
function ENT:SetupPlayerSkills()
	local owner = self:GetObjectOwner()
	local newmaxhealth = self.MaxHealth
	local currentmaxhealth = self:GetMaxObjectHealth()
	local defaults = scripted_ents.Get(self:GetClass())
	local maxspeed = defaults.MaxSpeed
	local acceleration = defaults.Acceleration
	local carrymass = defaults.CarryMass
	local loaded = false

	if owner:IsValid() then
		-- 应用拥有者的血量/速度/操控/负重技能加成
		newmaxhealth = newmaxhealth * (owner.ControllableHealthMul or 1)
		maxspeed = maxspeed * owner:GetTotalAdditiveModifier("ControllableSpeedMul", "DroneSpeedMul")
		acceleration = acceleration * (owner.ControllableHandlingMul or 1)
		carrymass = carrymass * (owner.DroneCarryMassMul or 1)
		-- 重装甲技能：附加丙烷罐装甲模型
		loaded = owner:IsSkillActive(SKILL_LOADEDHULL)
	end

	newmaxhealth = math.ceil(newmaxhealth)

	-- 按新旧最大血量比例缩放当前血量（技能升级不掉血）
	self:SetMaxObjectHealth(newmaxhealth)
	self:SetObjectHealth(self:GetObjectHealth() / currentmaxhealth * newmaxhealth)

	self.MaxSpeed = maxspeed
	self.Acceleration = acceleration
	self.CarryMass = carrymass

	if loaded then
		-- 有重装甲技能：挂载丙烷罐模型（只创建一次）
		if not IsValid(self.LoadedProp) then
			local ent = ents.Create("prop_dynamic_override")
			if ent:IsValid() then
				ent:SetModel("models/props_junk/propane_tank001a.mdl")
				ent:SetModelScale(0.65, 0)
				ent:SetParent(self)
				ent:SetOwner(self)
				ent:SetLocalPos(Vector(-5, 0, -6.5))
				ent:SetLocalAngles(Angle(-40, 0, 0))
				ent:Spawn()

				self.LoadedProp = ent
			end
		end
	elseif IsValid(self.LoadedProp) then
		-- 技能失效：移除装甲模型
		self.LoadedProp:Remove()
	end
end

-- ==== OnTakeDamage - 受伤处理：酸伤翻倍、削减耐久并播放火花特效 ====
function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	-- 人类玩家的攻击不削减耐久
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then return end

	self:TakePhysicsDamage(dmginfo)

	-- 酸性伤害加倍（无人机惧酸）
	if dmginfo:GetDamageType() == DMG_ACID then
		dmginfo:SetDamage(dmginfo:GetDamage() * 2)
	end

	self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())

	-- 受伤音效与火花特效
	self:EmitSound("npc/scanner/scanner_pain"..math.random(2)..".wav", 65, math.Rand(120, 130))

	local effectdata = EffectData()
		effectdata:SetOrigin(self:NearestPoint(dmginfo:GetDamagePosition()))
		effectdata:SetNormal(VectorRand():GetNormalized())
		effectdata:SetMagnitude(4)
		effectdata:SetScale(1.33)
	util.Effect("sparks", effectdata)
end

-- ==== Use - 使用：把当前弹药存入无人机 ====
function ENT:Use(activator, caller)
	-- 仅限人类玩家、有拥有者且未关闭 zs_nousetodeposit 选项时可用
	if not activator:IsPlayer() or activator:Team() ~= TEAM_HUMAN or not self:GetObjectOwner():IsValid() or activator:GetInfo("zs_nousetodeposit") ~= "0" then return end

	local ammotype = self.AmmoType
	local curammo = self:GetAmmo()

	-- 存入数量 = min(缓存上限, 玩家携带量, 无人机剩余容量)
	local togive = math.min(GAMEMODE.AmmoCache[ammotype], activator:GetAmmoCount(ammotype), self.MaxAmmo - curammo)
	if togive > 0 then
		self:SetAmmo(curammo + togive)
		activator:RemoveAmmo(togive, ammotype)
		activator:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)
		self:EmitSound("npc/turret_floor/click1.wav")
	end
end

-- ==== AltUse - 右键打包收起 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== PhysicsCollide - 记录撞击数据，交由 Think 处理 ====
function ENT:PhysicsCollide(data, phys)
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== OnPackedUp - 打包完成：归还武器、部署弹药与剩余弹药 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.SWEP)
	pl:GiveAmmo(1, self.DeployableAmmo)

	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())
	pl:GiveAmmo(self:GetAmmo(), self.AmmoType)

	self:Remove()
end

-- ==== PhysicsSimulate - 运动模拟：按键操控、限速、悬停与阻尼 ====
function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local owner = self:GetObjectOwner()
	-- 无有效拥有者或在操控禁用期：不做处理
	if not owner:IsValid() or self.DisableControlUntil and CurTime() < self.DisableControlUntil then return SIM_NOTHING end

	local vel = phys:GetVelocity()
	local movedir = Vector(0, 0, 0)
	local eyeangles = owner:SyncAngles()
	local aimangles = owner:EyeAngles()

	-- 正在被操控时读取按键输入合成移动方向
	if self:BeingControlled() then
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
		if owner:KeyDown(IN_BULLRUSH) then
			movedir = movedir + Vector(0, 0, 0.5)
		end
		if owner:KeyDown(IN_GRENADE1) then
			movedir = movedir - Vector(0, 0, 0.5)
		end
		-- 航向差过大时施加角速度使机头对准玩家朝向
		local angdiff = math.AngleDifference(eyeangles.yaw, phys:GetAngles().yaw)
		if math.abs(angdiff) > 4 then
			phys:AddAngleVelocity(Vector(0, 0, math.Clamp(angdiff, -64, 64) * frametime * 100 - phys:GetAngleVelocity().z * 0.95))
		end
	end

	if movedir == vector_origin then
		-- 无输入：按闲置阻尼减速
		vel = vel * (1 - frametime * self.IdleDrag)
	else
		-- 有输入：加速（血量越低加速越弱）
		movedir:Normalize()

		vel = vel + frametime * self.Acceleration * math.Clamp((self:GetObjectHealth() / self:GetMaxObjectHealth() + 1) / 2, 0.5, 1) * movedir
	end

	-- 限制最大速度
	if vel:Length() > self.MaxSpeed then
		vel:Normalize()
		vel = vel * self.MaxSpeed
	end

	-- 无输入且速度低于悬停阈值：向下探测并朝悬停高度修正
	if movedir == vector_origin and vel:Length() <= self.HoverSpeed then
		local trace = {mask = MASK_HOVER, filter = self}
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, self.HoverHeight * -2)
		local tr = util.TraceLine(trace)

		local hoverdir = (trace.start - tr.HitPos):GetNormalized()
		local hoverfrac = (0.5 - tr.Fraction) * 2
		vel = vel + frametime * hoverfrac * self.HoverForce * hoverdir
	end

	-- 关闭重力并直接设置速度（悬浮飞行）
	phys:EnableGravity(false)
	phys:SetAngleDragCoefficient(20000)
	phys:SetVelocityInstantaneous(vel)

	self:SetPhysicsAttacker(owner)

	return SIM_NOTHING
end

-- ==== Destroy - 坠毁：爆炸/殉爆特效并散落一半弹药 ====
function ENT:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	local pos = self:LocalToWorld(self:OBBCenter())

	self:EmitSound("npc/scanner/scanner_explode_crash2.wav")

	-- 火花特效
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0, 0, 1))
		effectdata:SetMagnitude(5)
		effectdata:SetScale(1.5)
	util.Effect("sparks", effectdata)

	local owner = self:GetObjectOwner()
	if owner:IsValidLivingHuman() and owner:IsSkillActive(SKILL_LOADEDHULL) then
		-- 重装甲技能：坠毁时殉爆（燃烧痕迹 + 范围爆炸伤害）
		effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetNormal(Vector(0, 0, -1))
		util.Effect("decal_scorch", effectdata)

		self:EmitSound("npc/env_headcrabcanister/explosion.wav", 100, 100)
		ParticleEffect("dusty_explosion_rockets", pos, angle_zero)

		util.BlastDamagePlayer(self, owner, pos, 128, 225, DMG_ALWAYSGIB)
	else
		-- 普通坠毁：直升机炸弹特效
		util.Effect("HelicopterMegaBomb", effectdata, true, true)
	end

	-- 散落一半弹药（每堆最多 50 发），随机方向抛射
	local amount = math.floor(self:GetAmmo() * 0.5)
	while amount > 0 do
		local todrop = math.min(amount, 50)
		amount = amount - todrop
		local ent = ents.Create("prop_ammo")
		if ent:IsValid() then
			local heading = VectorRand():GetNormalized()
			ent:SetAmmoType(self.AmmoType)
			ent:SetAmmo(todrop)
			ent:SetPos(pos + heading * 4)
			ent:SetAngles(VectorRand():Angle())
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:ApplyForceOffset(heading * math.Rand(8000, 32000), pos)
			end
		end
	end
end

-- ==== BulletCallback - 机炮子弹命中回调：对僵尸附加腿部伤害 ====
function ENT:BulletCallback(tr, dmginfo)
	local ent = tr.Entity
	if not ent or not ent:IsValid() then return end

	if ent:IsValidZombie() then
		ent:AddLegDamage(4.5)
	end
end

-- ==== FireTurret - 机炮开火：按冷却消耗弹药发射子弹 ====
function ENT:FireTurret(src, dir)
	if self:GetNextFire() <= CurTime() then
		local curammo = self:GetAmmo()
		if curammo > 0 then
			local owner = self:GetObjectOwner()

			-- 射击冷却 0.15 秒，每次消耗 1 发弹药
			self:SetNextFire(CurTime() + 0.15)
			self:SetAmmo(curammo - 1)

			-- 开火时启用延迟补偿，配合子弹回调与曳光特效
			owner:LagCompensation(true)
			self:FireBulletsLua(src, dir, 5, 1, 16.5, owner, nil, "AR2Tracer", self.BulletCallback, nil, nil, self.GunRange, nil, self)
			owner:LagCompensation(false)
		else
			-- 弹药耗尽：2 秒后重试并播放空膛音
			self:SetNextFire(CurTime() + 2)
			self:EmitSound("npc/turret_floor/die.wav")
		end
	end
end

ENT.PhysDamageImmunity = 0

-- ==== Think - 主循环：销毁处理、操控检查、开火、水中受损与撞击结算 ====
function ENT:Think()
	-- 已摧毁：生成一次破碎残骸后移除
	if self.Destroyed then
		if not self.CreatedDebris then
			self.CreatedDebris = true

			if self:GetObjectOwner():IsValidLivingHuman() then
				self:GetObjectOwner():SendDeployableLostMessage(self)
			end

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

	local owner = self:GetObjectOwner()
	-- 拥有者死亡/换队/消失：无人机坠毁
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

	-- 每帧计算机炮瞄准角度
	self:CalculateFireAngles()

	-- 被操控且按住攻击键时持续开火
	if self:GetAmmo() > 0 then
		if self:BeingControlled() and owner:KeyDown(IN_ATTACK) then
			if not self:IsFiring() then self:SetFiring(true) end
			self:FireTurret(self:GetRedLightPos(), self:GetGunAngles():Forward())
		else
			self:SetFiring(false)
		end
	end

	-- 浸水（腰线以上）时持续受到伤害
	if self:WaterLevel() >= 2 and CurTime() >= self.NextWaterDamage then
		self.NextWaterDamage = CurTime() + 0.2

		self:TakeDamage(10)
	end

	self:NextThink(CurTime())

	-- 处理 PhysicsCollide 记录的撞击数据
	local data = self.HitData
	if not data then return true end
	self.HitData = nil

	local ent = data.HitEntity
	if ent and ent:IsValid() then
		-- 被人类玩家推挤/碰撞时获得短暂物理伤害免疫
		local physattacker = ent:GetPhysicsAttacker()
		if physattacker:IsValid() and physattacker:Team() == TEAM_HUMAN then
			self.PhysDamageImmunity = CurTime() + 0.5
		end
	end

	-- 高速撞击时把无人机反弹开
	if data.Speed > self.HoverSpeed then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			local dir = self:GetPos() - data.HitPos
			dir:Normalize()
			phys:AddVelocity(dir * 20)
		end
	end

	-- 高速撞墙（非稳定外壳技能/刚被暗影发射）时承受撞击伤害
	if ((not owner:IsSkillActive(SKILL_STABLEHULL) and data.Speed >= self.MaxSpeed * 0.75) or (self.LastShadeLaunch and self.LastShadeLaunch + 2 > CurTime())) and
	 	ent and ent:IsWorld() and CurTime() >= self.PhysDamageImmunity then
		self:TakeDamage(math.Clamp(data.Speed * 0.11, 0, 40))
	end

	return true
end

-- ==== SetupPlayerVisibility - 为拥有者扩展 PVS（含机炮瞄准点）====
function ENT:SetupPlayerVisibility(pl)
	if pl ~= self:GetObjectOwner() then return end

	AddOriginToPVS(self:GetPos())
	AddOriginToPVS(self:GetPos() + pl:GetAimVector() * 1024)
end

-- ==== SetObjectHealth - 写入耐久；归零时触发坠毁（DT 浮点 0 号位）====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 and not self.Destroyed then
		self:Destroy()
	end
end

-- ==== SetMaxObjectHealth - 写入最大耐久（DT 浮点 1 号位）====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== SetNextFire - 写入下次开火时间（DT 浮点 2 号位）====
function ENT:SetNextFire(tim)
	self:SetDTFloat(2, tim)
end

-- ==== SetAmmo - 写入弹药量（DT 整数 0 号位）====
function ENT:SetAmmo(ammo)
	self:SetDTInt(0, ammo)
end

-- ==== SetFiring - 写入开火状态（DT 布尔 0 号位）====
function ENT:SetFiring(onoff)
	self:SetDTBool(0, onoff)
end
