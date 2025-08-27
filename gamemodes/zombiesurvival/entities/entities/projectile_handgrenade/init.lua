INC_SERVER()

ENT.LifeTime = 3
function ENT:Initialize()
	self:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
	self:SetColor(Color(255, 255, 0))
	self:PhysicsInitSphere(3)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetModelScale(0.2, 0)
	self:DrawShadow(false)
	self:SetupGenericProjectile(true)

	self.Bounces = 0
	self.ExplodeTime = CurTime() + self.LifeTime
	self.Grace = CurTime() + 0.1
	self.Firemode = self:GetDTBool(0)
end

function ENT:Think()
	-- [[ 新增部分开始 ]] --
	-- 定义一个最大下落速度（正数）。数值越小，下落得越慢。
	-- 作为参考，Garry's Mod 中玩家的默认下落速度上限大约是 350-400。
	-- 你可以从 150 左右开始尝试。
	local fall_drag_multiplier = 0.985

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local vel = phys:GetVelocity()
		-- 如果正在下落
		if vel.z < 0 then
			-- 只减小Z轴的速度，X和Y保持不变
			vel.z = vel.z * fall_drag_multiplier
			phys:SetVelocity(vel)
		end
	end


	if self.ExplodeTime <= CurTime() then
		self:Explode(self:GetPos())
	end
	if self.PhysicsData then
		if self.Bounces <= 0 or self.PhysicsData.HitEntity:IsPlayer() or self.PhysicsData.HitEntity.ZombieConstruction then
			self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
		end
		local phys = self.PhysicsData.PhysObject
		if phys:IsValid() then
			local hitnormal = self.PhysicsData.HitNormal
			local vel = self.PhysicsData.OurOldVelocity
			local normal = vel:GetNormalized()
			phys:SetVelocityInstantaneous((2 * hitnormal * hitnormal:Dot(normal * -1) + normal) * vel:Length() * 0.8)
		end
		if CurTime() >= self.Grace then
			self.Bounces = self.Bounces -1
		end
		self.PhysicsData = nil
	end

	self:NextThink(CurTime())
	return true
end

function ENT:Explode(hitpos, hitnormal, hitent)
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	local explosionRadius = 100 -- 定义爆炸半径
	if self.Firemode then
		-- 2. 查找爆炸范围内的所有实体，并点燃它们
		for _, ent in pairs(ents.FindInSphere(hitpos, explosionRadius)) do
			-- 确保实体是有效的，并且是玩家或NPC
			if ent:IsValidLivingZombie() then
				-- 点燃实体，持续5秒，火焰不会蔓延 (第二个参数为0)
				ent:Ignite(4, 0) -- [2, 5]
				ent:SetNWFloat("FireDieTime", CurTime() + 4)
				timer.Simple(0, function()
					-- 再次检查owner和ent是否仍然有效，因为延迟期间它们可能已死亡或被移除
					if not IsValid(owner) or not IsValid(ent) then return end
					-- 遍历所有火焰实体
					for __, fire in pairs(ents.FindByClass("entityflame")) do
						-- 找到刚刚附着在目标身上的那个火焰
						if fire:IsValid() and fire:GetParent() == ent then
							fire:SetOwner(owner)
							fire:SetPhysicsAttacker(owner)
							fire.AttackerForward = owner -- 这一行通常不是必需的，前两行已经足够
						end
					end
				end)
			end
		end
	end
	-- [[ 新增部分结束 ]] --

	if owner:IsValidLivingHuman() then
		local source = self:ProjectileDamageSource()
		-- 这里的 100 已经被 explosionRadius 变量替代
		util.BlastDamagePlayer(source, owner, hitpos, explosionRadius, self.ProjDamage or 29, DMG_ALWAYSGIB, 0.95)
	end

	self:EmitSound(")weapons/explode5.wav", 80, 130)
	self:Remove()
end


function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
