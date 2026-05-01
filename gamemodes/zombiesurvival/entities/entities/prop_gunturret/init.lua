-- init.lua
INC_SERVER() -- 包含服务器端宏定义

ENT.LastHitSomething = 0
ENT.TurretDeployableAmmo = "thumper" -- 打包收起时使用的弹药类型（通常是部署物品的ID）
ENT.LastHitPeriod = 0.5             -- 失去目标后保留锁定的缓冲时间
ENT.Hitbox = "prop_hitbox_gunturret" -- 碰撞盒类名
ENT.AmmoGivePerUse = 50              -- 玩家每次按E添加的弹药量

-- 当玩家离线或换队时，清除他们拥有的炮塔所有权
local function RefreshTurretOwners(pl)
	for _, ent in pairs(ents.FindByClass("prop_gunturret*")) do
		if ent:IsValid() and ent:GetObjectOwner() == pl then
			ent:ClearObjectOwner()
			ent:ClearTarget()
		end
	end
end
hook.Add("PlayerDisconnected", "GunTurret.PlayerDisconnected", RefreshTurretOwners)
hook.Add("OnPlayerChangedTeam", "GunTurret.OnPlayerChangedTeam", RefreshTurretOwners)

-- 初始化炮塔
function ENT:Initialize()
	self:SetModel("models/Combine_turrets/Floor_turret.mdl")
	self:SetModelScale(self.ModelScale or 1, 0)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(50)
		phys:EnableMotion(false) -- 默认静止不被撞飞
		phys:Wake()
	end

	-- 属性初始化
	self:SetAmmo(self.DefaultAmmo)
	self:SetMaxObjectHealth(self.MaxHealth)
	self:SetObjectHealth(self:GetMaxObjectHealth())
	self:SetScanSpeed(1)
	self:SetScanMaxAngle(1)

	-- 创建专用的碰撞检测盒（Hitbox）
	local ent = ents.Create(self.Hitbox)
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetOwner(self)
		ent:SetParent(self)
		ent:Spawn()

		self:DeleteOnRemove(ent) -- 炮塔删除时同时删除碰撞盒
		self.Hitbox = ent
		self:SetTurretHitbox(ent)
	end

	self:SetupPlayerSkills() -- 初始化技能加成

	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end

-- 应用主人的技能加成
function ENT:SetupPlayerSkills()
	local owner = self:GetObjectOwner()
	local scanspeed = 1
	local scanangle = 1

	if owner:IsValid() then
		scanspeed = scanspeed * (owner.TurretScanSpeedMul or 1)
		scanangle = scanangle * (owner.TurretScanAngleMul or 1)
	end

	self:SetScanSpeed(scanspeed)
	self:SetScanMaxAngle(scanangle)

	-- 应用血量加成技能
	self:SetupDeployableSkillHealth("TurretHealthMul")
end

-- 设置生命值及损毁逻辑
function ENT:SetObjectHealth(health)
	self:SetDTFloat(3, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		local pos = self:LocalToWorld(self:OBBCenter())

		-- 爆炸效果
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("Explosion", effectdata, true, true)

		if self:GetObjectOwner():IsValidLivingHuman() then
			self:GetObjectOwner():SendDeployableLostMessage(self) -- 发送丢失提示
		end

		-- 损毁时返还一半弹药作为掉落物
		local amount = math.ceil(self:GetAmmo() * 0.5)
		while amount > 0 do
			local todrop = math.min(amount, 50)
			amount = amount - todrop
			local ent = ents.Create("prop_ammo")
			if ent:IsValid() then
				local heading = VectorRand():GetNormalized()
				ent:SetAmmoType(self.AmmoType)
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

-- 子弹命中回调逻辑
local TEMPTURRET
local function BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValid() then
		-- 如果命中的是当前目标僵尸，更新最后命中时间
		if TEMPTURRET:GetTarget() == ent and ent:IsPlayer() and ent:Team() == TEAM_UNDEAD then
			TEMPTURRET.LastHitSomething = CurTime()
		end
		dmginfo:SetInflictor(TEMPTURRET)
	end
end

function ENT:PlayShootSound()
	-- 射击音效由 shared 里的循环音效逻辑控制
end

-- 炮塔射击执行函数
function ENT:FireTurret(src, dir)
	if self:GetNextFire() <= CurTime() then
		local curammo = self:GetAmmo()
		local owner = self:GetObjectOwner()
		-- 检查技能：双重排炮
		local twinvolley = self:GetManualControl() and owner:IsSkillActive(SKILL_TWINVOLLEY)
		
		if curammo > (twinvolley and 1 or 0) then
			self:SetNextFire(CurTime() + self.FireDelay * (twinvolley and 1.5 or 1))
			self:SetAmmo(curammo - (twinvolley and 2 or 1))

			if self:GetAmmo() == 0 then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			self:PlayShootSound()

			TEMPTURRET = self
			-- 发射子弹
			self:FireBulletsLua(src, dir, self.Spread, self.NumShots * (twinvolley and 2 or 1), self.Damage, self:GetObjectOwner(), nil, nil, BulletCallback, nil, nil, nil, nil, self)
		else
			-- 没弹药时发出空响
			self:SetNextFire(CurTime() + 2)
			self:EmitSound("npc/turret_floor/die.wav")
		end
	end
end

-- 核心逻辑思考
function ENT:Think()
	if self.Destroyed then
		self:Remove()
		return
	end

	self:CalculatePoseAngles() -- 更新炮塔转向

	local owner = self:GetObjectOwner()
	if owner:IsValid() and self:GetAmmo() > 0 and self:GetMaterial() == "" then
		if self:GetManualControl() then
			-- 手动控制逻辑
			if owner:KeyDown(IN_ATTACK) then
				if not self:IsFiring() then self:SetFiring(true) end
				self:FireTurret(self:ShootPos(), self:GetGunAngles():Forward())
			elseif self:IsFiring() then
				self:SetFiring(false)
			end

			local target = self:GetTarget()
			if target:IsValid() then self:ClearTarget() end -- 手动控制时放弃自动锁定
		else
			-- 自动搜索逻辑
			if self:IsFiring() then self:SetFiring(false) end
			local target = self:GetTarget()
			if target:IsValid() then
				-- 检查目标是否依然合法
				if self:IsValidTarget(target) and CurTime() < self.LastHitSomething + self.LastHitPeriod then
					self:FireTurret(self:ShootPos(), (self:GetTargetPos(target) - self:ShootPos()):GetNormalized())
				else
					self:ClearTarget()
					self:EmitSound("npc/turret_floor/deploy.wav")
				end
			else
				-- 寻找新目标
				target = self:SearchForTarget()
				if target then
					self:SetTarget(target)
					self:SetTargetReceived(CurTime())
					self:EmitSound("npc/turret_floor/active.wav")
				end
			end
		end
	elseif self:IsFiring() then
		self:SetFiring(false)
	end

	self:NextThink(CurTime())
	return true
end

-- 确保主人可以透过炮塔看到视野（用于 PVS 渲染）
function ENT:SetupPlayerVisibility(pl)
	if pl ~= self:GetObjectOwner() then return end
	AddOriginToPVS(self:GetPos())
	AddOriginToPVS(self:GetPos() + pl:GetAimVector() * 1024)
end

-- 玩家按 E 交互逻辑
function ENT:Use(activator, caller)
    if self.Removing or not activator:IsPlayer() or self:GetMaterial() ~= "" then return end

    if activator:Team() == TEAM_HUMAN then
        if self:GetObjectOwner():IsValid() then
            -- 给炮塔填装弹药
            if activator:GetInfo("zs_nousetodeposit") == "0" then
                local curammo = self:GetAmmo()
                local togive = math.min(self.AmmoGivePerUse, activator:GetAmmoCount(self.AmmoType), self.MaxAmmo - curammo)
                if togive > 0 then
                    self:SetAmmo(curammo + togive)
                    activator:RemoveAmmo(togive, self.AmmoType)
                    activator:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)
                    self:EmitSound("npc/turret_floor/click1.wav")
                end
            end
        else
            -- 认领无主炮塔
            self:SetObjectOwner(activator)
            self:GetObjectOwner():SendDeployableClaimedMessage(self)
            if not activator:HasWeapon("weapon_zs_gunturretcontrol") then
                activator:Give("weapon_zs_gunturretcontrol")
            end
        end
    end
end

-- 按住 Alt + E 打包
function ENT:AltUse(activator, tr)
	self:PackUp(activator)
end

-- 打包完成时的回调：归还物品和弹药
function ENT:OnPackedUp(pl)
	pl:GiveEmptyWeapon(self.SWEP)
	pl:GiveAmmo(1, self.TurretDeployableAmmo)

	pl:PushPackedItem(self:GetClass(), self:GetObjectHealth())
	pl:GiveAmmo(self:GetAmmo(), self.AmmoType)

	self:Remove()
end

-- 受伤处理
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)

	if dmginfo:GetDamage() <= 0 then return end

	local attacker = dmginfo:GetAttacker()
	-- 只有非人类伤害（僵尸或陷阱）才扣血
	if not (attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_HUMAN) then
		self:ResetLastBarricadeAttacker(attacker, dmginfo)
		self:SetObjectHealth(self:GetObjectHealth() - dmginfo:GetDamage())
	end
end

-- 扫描目标逻辑（射线检测）
local tabSearch = {mask = MASK_SHOT}
function ENT:SearchForTarget()
	local shootpos = self:ShootPos()
	local owner = self:GetObjectOwner()

	tabSearch.start = shootpos
	tabSearch.endpos = shootpos + self:GetGunAngles():Forward() * self.SearchDistance * (owner.TurretRangeMul or 1)
	tabSearch.filter = self:GetCachedScanFilter()
	
	local tr = util.TraceLine(tabSearch)
	local ent = tr.Entity
	if ent and ent:IsValid() and self:IsValidTarget(ent) then
		return ent
	end
end

----------------------------------------
-- DataTables 设置器 (修改同步状态)
----------------------------------------
function ENT:SetAmmo(ammo) self:SetDTInt(0, ammo) end
function ENT:SetMaxObjectHealth(health) self:SetDTInt(1, health) end
function ENT:SetChannel(channel) self:SetDTInt(2, channel) end
function ENT:SetFiring(onoff) self:SetDTBool(0, onoff) end
function ENT:SetScanMaxAngle(angle) self:SetDTFloat(5, angle) end
function ENT:SetScanSpeed(speed) self:SetDTFloat(4, speed) end
function ENT:SetNextFire(tim) self:SetDTFloat(2, tim) end

function ENT:ClearObjectOwner() self:SetObjectOwner(NULL) end
function ENT:ClearTarget() self:SetTarget(NULL) end

function ENT:SetTargetReceived(tim) self:SetDTFloat(0, tim) end
function ENT:SetTargetLost(tim) self:SetDTFloat(1, tim) end

function ENT:SetTarget(ent)
	if ent:IsValid() then
		self:SetTargetReceived(CurTime())
		self.LastHitSomething = CurTime()
	else
		self:SetTargetLost(CurTime())
	end
	self:SetDTEntity(0, ent)
end

function ENT:SetObjectOwner(ent)
	self:SetDTEntity(1, ent)
	if self.HitBox then
		self.HitBox:SetObjectOwner(ent)
	end
	self:SetupPlayerSkills()
end

function ENT:SetTurretHitbox(ent)
	self:SetDTEntity(2, ent)
end