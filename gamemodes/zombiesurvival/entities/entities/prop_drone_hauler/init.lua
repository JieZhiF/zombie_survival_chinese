-- ============================================================================
-- prop_drone_hauler/init.lua - 搬运无人机（服务器）
-- 负责：生成无人机并初始化飞行物理；处理玩家遥控飞行、绳索拖拽/释放道具、
--       耐久与受损结算、水中持续掉血、碰撞伤害、销毁爆炸与打包回收；
--       通过技能为无人机附加强化（装甲/速度/操控）
-- ============================================================================
INC_SERVER()

-- 下一次水中掉血的结算时间
ENT.NextWaterDamage = 0

-- ==== Initialize - 生成无人机：模型/物理/约束/耐久/动画初始化 ====
function ENT:Initialize()
	self:SetModel("models/shield_scanner.mdl")
	-- 使用型实体（简单交互）
	self:SetUseType(SIMPLE_USE)

	-- 盒体碰撞初始化 + 物理实体初始化
	self:PhysicsInitBox(Vector(-30, -17, -14.15), Vector(18.29, 11.86, 15))
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		-- 金属材质、75 质量、无阻力可自由运动、低浮力、不受撞击伤害
		phys:SetMaterial("metal")
		phys:SetMass(75)
		phys:EnableDrag(false)
		phys:EnableMotion(true)
		phys:Wake()
		phys:SetBuoyancyRatio(0.8)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)

		-- 保持直立约束：机身偏转角度限制在 2 度内
		local Constraint = ents.Create("phys_keepupright")
		Constraint:SetAngles(Angle(0, 0, 0))
		Constraint:SetKeyValue("angularlimit", 2)
		Constraint:SetPhysConstraintObjects(phys, phys)
		Constraint:Spawn()
		Constraint:Activate()
		self:DeleteOnRemove(Constraint)
	end

	-- 注册为运动控制器实体（由 PhysicsSimulate 驱动飞行）
	self:StartMotionController()

	-- 初始化耐久值与耐久上限
	self:SetMaxObjectHealth(self.MaxHealth)
	self:SetObjectHealth(self:GetMaxObjectHealth())

	self.LastThink = CurTime()

	-- 飞行动画：固定序列 + 客户端动画播放 + 自定义碰撞检测
	self:ResetSequence(5)
	self:SetPlaybackRate(1)
	self:UseClientSideAnimation(true)
	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()

	-- 注册玩家视野加载钩子（保证远距离也能看到无人机）
	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end

-- ==== SetupPlayerSkills - 根据所有者技能强化无人机（装甲/速度/操控） ====
function ENT:SetupPlayerSkills()
	local owner = self:GetObjectOwner()
	local newmaxhealth = self.MaxHealth
	local currentmaxhealth = self:GetMaxObjectHealth()
	-- 读取实体默认属性作为技能加成基数
	local defaults = scripted_ents.Get(self:GetClass())
	local maxspeed = defaults.MaxSpeed
	local acceleration = defaults.Acceleration
	local loaded = false

	if owner:IsValid() then
		-- 应用所有者的技能修正：耐久/速度/操控倍率
		newmaxhealth = newmaxhealth * (owner.ControllableHealthMul or 1)
		maxspeed = maxspeed * owner:GetTotalAdditiveModifier("ControllableSpeedMul", "DroneSpeedMul")
		acceleration = acceleration * (owner.ControllableHandlingMul or 1)
		loaded = owner:IsSkillActive(SKILL_LOADEDHULL)
	end

	newmaxhealth = math.ceil(newmaxhealth)

	-- 按比例同步当前耐久到新的上限（不掉百分比）
	self:SetMaxObjectHealth(newmaxhealth)
	self:SetObjectHealth(self:GetObjectHealth() / currentmaxhealth * newmaxhealth)

	self.MaxSpeed = maxspeed
	self.Acceleration = acceleration

	-- 装甲技能：挂载丙烷罐装饰物，并使其失效时销毁
	if loaded then
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
	-- 技能失效时移除装饰物
	elseif IsValid(self.LoadedProp) then
		self.LoadedProp:Remove()
	end
end

-- ==== SetObjectHealth - 设置耐久，归零时销毁无人机 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 then
		self:Destroy()
	end
end

-- ==== OnRemove - 移除时恢复被拖拽道具的物理属性 ====
function ENT:OnRemove()
	self:RestoreGrappledEntityProperties()
end

-- ==== RestoreGrappledEntityProperties - 恢复拖拽道具的原始质量/物理标记 ====
function ENT:RestoreGrappledEntityProperties()
	local ent = self.GrappledEnt
	if IsValid(ent) and ent._OriginalMass then
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			-- 恢复原始质量并清除搬运期标记
			phys:SetMass(ent._OriginalMass)
			phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
			phys:ClearGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phys:ClearGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			ent._OriginalMass = nil

			-- 攻击者归属还原为所有者
			local owner = self:GetObjectOwner()
			if owner:IsValidPlayer() then
				ent:SetPhysicsAttacker(owner)
			end
		end
	end
end

-- ==== OnTakeDamage - 受损结算：人类攻击免疫，酸液加倍，播放受伤特效 ====
function ENT:OnTakeDamage(dmginfo)
	-- 无效伤害直接忽略
	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	-- 人类造成的伤害免疫（防止友伤）
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN then return end

	self:TakePhysicsDamage(dmginfo)

	-- 酸液伤害翻倍（针对无人机弱点）
	if dmginfo:GetDamageType() == DMG_ACID then
		dmginfo:SetDamage(dmginfo:GetDamage() * 2)
	end

	self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())

	-- 播放受伤音效与火花特效
	self:EmitSound("npc/scanner/scanner_pain"..math.random(2)..".wav", 65, math.Rand(120, 130))

	local effectdata = EffectData()
		effectdata:SetOrigin(self:NearestPoint(dmginfo:GetDamagePosition()))
		effectdata:SetNormal(VectorRand():GetNormalized())
		effectdata:SetMagnitude(4)
		effectdata:SetScale(1.33)
	util.Effect("sparks", effectdata)
end

-- ==== Use - 普通使用无操作 ====
function ENT:Use(activator, caller)
end

-- ==== AltUse - 右键使用：打包收起无人机 ====
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- ==== PhysicsCollide - 记录碰撞数据并立刻进入 Think 结算 ====
function ENT:PhysicsCollide(data, phys)
	self.HitData = data
	self:NextThink(CurTime())
end

-- ==== OnPackedUp - 打包完成：归还武器/弹药并移除无人机 ====
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.SWEP)
	pl:GiveAmmo(1, self.DeployableAmmo)

	-- 记录打包物品（含剩余耐久）供重新部署
	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())

	self:Remove()
end

-- ==== PhysicsSimulate - 飞行运动模拟：遥控输入转向/加减速/悬停修正 ====
function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local owner = self:GetObjectOwner()
	-- 无所有者或控制禁用期间不模拟运动
	if not owner:IsValid() or self.DisableControlUntil and CurTime() < self.DisableControlUntil then return SIM_NOTHING end

	local vel = phys:GetVelocity()
	local movedir = Vector(0, 0, 0)
	local eyeangles = owner:SyncAngles()
	local aimangles = owner:EyeAngles()

	-- 被遥控时解析 WASD/上下键为移动方向
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
		-- 根据视角偏航差驱动机身转向（带阻尼）
		local angdiff = math.AngleDifference(eyeangles.yaw, phys:GetAngles().yaw)
		if math.abs(angdiff) > 4 then
			phys:AddAngleVelocity(Vector(0, 0, math.Clamp(angdiff, -64, 64) * frametime * 100 - phys:GetAngleVelocity().z * 0.95))
		end
	end

	-- 无输入时按怠速阻力减速，有输入时按耐久比例加速
	if movedir == vector_origin then
		vel = vel * (1 - frametime * self.IdleDrag)
	else
		movedir:Normalize()

		-- 加速倍率随耐久线性衰减（耐久越低越慢）
		vel = vel + frametime * self.Acceleration * math.Clamp((self:GetObjectHealth() / self:GetMaxObjectHealth() + 1) / 2, 0.5, 1) * movedir
	end

	-- 速度钳制到最大速度
	if vel:Length() > self.MaxSpeed then
		vel:Normalize()
		vel = vel * self.MaxSpeed
	end

	-- 悬停：无输入且速度低于悬停阈值时，向下扫描并施加修正力保持高度
	if movedir == vector_origin and vel:Length() <= self.HoverSpeed then
		local trace = {mask = MASK_HOVER, filter = self}
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, self.HoverHeight * -2)
		local tr = util.TraceLine(trace)

		-- 高度偏差越大修正力越强
		local hoverdir = (trace.start - tr.HitPos):GetNormalized()
		local hoverfrac = (0.5 - tr.Fraction) * 2
		vel = vel + frametime * hoverfrac * self.HoverForce * hoverdir
	end

	-- 关闭重力、加大转向阻尼、写入计算后的速度
	phys:EnableGravity(false)
	phys:SetAngleDragCoefficient(20000)
	phys:SetVelocityInstantaneous(vel)

	self:SetPhysicsAttacker(owner)

	return SIM_NOTHING
end

-- ==== Destroy - 销毁无人机：爆炸特效/音效，装甲技能时改为烈性爆炸 ====
function ENT:Destroy()
	-- 防止重复销毁
	if self.Destroyed then return end
	self.Destroyed = true

	local pos = self:LocalToWorld(self:OBBCenter())

	self:EmitSound("npc/scanner/scanner_explode_crash2.wav")

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0, 0, 1))
		effectdata:SetMagnitude(5)
		effectdata:SetScale(1.5)
	util.Effect("sparks", effectdata)

	local owner = self:GetObjectOwner()
	-- 装甲技能：爆炸升级为范围伤害并留下烧灼痕迹
	if owner:IsValidLivingHuman() and owner:IsSkillActive(SKILL_LOADEDHULL) then
		effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetNormal(Vector(0, 0, -1))
		util.Effect("decal_scorch", effectdata)

		self:EmitSound("npc/env_headcrabcanister/explosion.wav", 100, 100)
		ParticleEffect("dusty_explosion_rockets", pos, angle_zero)

		-- 128 半径 225 伤害的范围爆炸
		util.BlastDamagePlayer(self, owner, pos, 128, 225, DMG_ALWAYSGIB)
	else
		-- 普通爆炸特效（仅视觉效果）
		util.Effect("HelicopterMegaBomb", effectdata, true, true)
	end
end

ENT.GrappledEnt = nil
-- 允许被绳索拖拽的实体类型列表
local carryclasses = {"prop_ammo", "prop_weapon", "prop_invitem", "prop_physics", "prop_physics_multiplayer", "func_physbox"}
-- ==== RopeAttach - 索具切换：释放当前拖拽目标，或瞄准并拖拽新目标 ====
function ENT:RopeAttach()
	-- 索具冷却 0.5 秒
	if CurTime() < self:GetNextFire() then return end
	self:SetNextFire(CurTime() + 0.5)

	-- 已拖拽时：解除绳索并恢复目标物理属性
	if self:IsGrappling() then
		constraint.RemoveConstraints(self, "Rope")
		self:EmitSound("npc/scanner/scanner_scan1.wav")
		self:RestoreGrappledEntityProperties()
		self:SetGrappling(false)
		self.GrappledEnt = nil

		return
	end

	local owner = self:GetObjectOwner()
	local start = self:GetCameraPosition()
	local filter = self:GetTraceFilter()
	-- 沿视线方向 128 单位寻找可拖拽目标
	local tr = util.TraceLine({start = start, endpos = start + owner:EyeAngles():Forward() * 128, mask = MASK_SOLID, filter = filter})

	local ropetraceent = tr.Entity
	if tr.Hit and ropetraceent and ropetraceent:IsValid() then
		local entclass = ropetraceent:GetClass()
		-- 目标属于可搬运类型且满足质量/可动/体积/无既有约束条件
		if table.HasValue(carryclasses, entclass) then
			local phys = ropetraceent:GetPhysicsObject()
			if phys:IsValid() and phys:GetMass() <= self.CarryMass and phys:IsMoveable() and not phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) and (ropetraceent:OBBMins():Length() + ropetraceent:OBBMaxs():Length() < CARRY_DRAG_VOLUME or ropetraceent.NoVolumeCarryCheck) and not constraint.HasConstraints(ropetraceent) then
				-- 创建 140 单位长绳索连接目标
				local rope = constraint.Rope(self, ropetraceent, 0, tr.PhysicsBone, vector_origin, WorldToLocal(tr.HitPos, angle_zero, ropetraceent:GetPos(), ropetraceent:GetAngles()), 0, 140, 2000, 1.5, "cable/rope.vmt", false)
				if not rope then
					return
				end
				-- 记录拖拽状态并减轻目标质量便于搬运
				self.GrappleCheckTime = CurTime() + 2
				self.GrappledEnt = ropetraceent
				self.GrappleRope = rope
				self:EmitSound("ambient/machines/catapult_throw.wav")
				self:SetGrappling(true)

				ropetraceent._OriginalMass = ropetraceent._OriginalMass or phys:GetMass()
				phys:SetMass(2)
				phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
				phys:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
				phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
			end
		end
	else
		-- 未命中可搬运目标时播放空扫音效
		self:EmitSound("npc/scanner/scanner_scan4.wav", 55)
	end
end

ENT.PhysDamageImmunity = 0
ENT.GrappleCheckTime = 0
-- ==== Think - 每帧结算：销毁流程/所有者存活检查/索具维护/水中掉血/碰撞伤害 ====
function ENT:Think()
	-- 已销毁：生成碎裂残骸并移除自身
	if self.Destroyed then
		if not self.CreatedDebris then
			self.CreatedDebris = true

			-- 通知人类所有者部署物已损失
			if self:GetObjectOwner():IsValidLivingHuman() then
				self:GetObjectOwner():SendDeployableLostMessage(self)
			end

			-- 生成同模型的物理残骸并让其破碎消失
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
	if owner:IsValid() then
		-- 持续把物理攻击者归属指向所有者（含拖拽目标）
		self:SetPhysicsAttacker(owner)
		if IsValid(self.GrappledEnt) then
			self.GrappledEnt:SetPhysicsAttacker(owner)
		end

		-- 所有者死亡或离开人类阵营时销毁无人机
		if not owner:Alive() or owner:Team() ~= TEAM_HUMAN then
			self:Destroy()
			return
		end
	else
		-- 所有者失效也销毁
		self:Destroy()
		return
	end

	-- 被遥控且按下攻击键时切换索具
	if self:BeingControlled() and owner:KeyDown(IN_ATTACK) then
		self:RopeAttach()
	end

	-- 每 2 秒校验拖拽状态：绳索或目标失效则解除
	if self.GrappleCheckTime <= CurTime() and self:IsGrappling() then
		if not IsValid(self.GrappledEnt) or not IsValid(self.GrappleRope) then
			constraint.RemoveConstraints(self, "Rope")
			self:EmitSound("npc/scanner/scanner_alert1.wav")
			self:SetGrappling(false)
			self:RestoreGrappledEntityProperties()
			self.GrappledEnt = nil
			self.GrappleRope = nil
		end
		self.GrappleCheckTime = CurTime() + 2
	end

	-- 入水（腰以下）时每 0.2 秒承受 10 点伤害
	if self:WaterLevel() >= 2 and CurTime() >= self.NextWaterDamage then
		self.NextWaterDamage = CurTime() + 0.2

		self:TakeDamage(10)
	end

	self:NextThink(CurTime())

	-- 处理碰撞数据（PhysicsCollide 记录的）
	local data = self.HitData
	if not data then return true end
	self.HitData = nil

	local ent = data.HitEntity
	-- 被人类投掷物撞击后获得 0.5 秒物理伤害免疫
	if ent and ent:IsValid() then
		local physattacker = ent:GetPhysicsAttacker()
		if physattacker:IsValid() and physattacker:Team() == TEAM_HUMAN then
			self.PhysDamageImmunity = CurTime() + 0.5
		end
	end

	-- 高速撞击时沿撞击反方向推离
	if data.Speed > self.HoverSpeed then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			local dir = self:GetPos() - data.HitPos
			dir:Normalize()
			phys:AddVelocity(dir * 20)
		end
	end

	-- 高速撞击世界（无稳定船体技能）或刚被暗影发射后：按速度折算撞击伤害
	if ((not owner:IsSkillActive(SKILL_STABLEHULL) and data.Speed >= self.MaxSpeed * 0.75) or (self.LastShadeLaunch and self.LastShadeLaunch + 2 > CurTime())) and
	 	ent and ent:IsWorld() and CurTime() >= self.PhysDamageImmunity then
		self:TakeDamage(math.Clamp(data.Speed * 0.11, 0, 40))
	end

	return true
end

-- ==== SetupPlayerVisibility - 让所有者视野强制加载无人机及其前方区域 ====
function ENT:SetupPlayerVisibility(pl)
	if pl ~= self:GetObjectOwner() then return end

	AddOriginToPVS(self:GetPos())
	AddOriginToPVS(self:GetPos() + pl:GetAimVector() * 1024)
end

-- ==== SetObjectHealth - 设置耐久，归零时标记为已销毁 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 and not self.Destroyed then
		self.Destroyed = true
	end
end

-- ==== SetNextFire - 设置下一次索具发射时间 ====
function ENT:SetNextFire(tim)
	self:SetDTFloat(2, tim)
end

-- ==== SetMaxObjectHealth - 设置耐久上限 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== SetGrappling - 设置拖拽状态标记 ====
function ENT:SetGrappling(onoff)
	self:SetDTBool(1, onoff)
end
