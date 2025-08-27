INC_CLIENT()

ENT.Seed = 0
ENT.Tall = 0
ENT.Blocked = false

function ENT:Initialize()
	local dist = math.max(16, GAMEMODE.CreeperNestDist) * 2

	self:SetModelScale(0.2, 0)
	self:SetRenderBounds(Vector(-dist, -dist, -dist), Vector(dist, dist, dist))
	self:ManipulateBoneScale(0, self.ModelScale)

	self.AmbientSound = CreateSound(self, "ambient/levels/citadel/citadel_drone_loop5.wav")
	
	self.FloorModel = ClientsideModel("models/props_wasteland/antlionhill.mdl") --地板的模型
	if self.FloorModel:IsValid() then
		self.FloorModel:SetParent(self)
		self.FloorModel:SetOwner(self)
		self.FloorModel:SetPos(self:GetPos())
		self.FloorModel:SetAngles(self:GetAngles())
		self.FloorModel:Spawn()
		self.FloorModel:ManipulateBoneScale(0, Vector(0.01, 0.01, 0.01))
		self.FloorModel:SetMaterial("models/flesh")
		self.FloorModel:SetSolid(SOLID_NONE)
	end
	
	self.Seed = math.Rand(0, 10)
	self.NextFogEmit = 0 -- 新增：初始化雾气计时器
end

local EmitSounds = {
	Sound("physics/flesh/flesh_squishy_impact_hard1.wav"),
	Sound("physics/flesh/flesh_squishy_impact_hard2.wav"),
	Sound("physics/flesh/flesh_squishy_impact_hard3.wav"),
	Sound("physics/flesh/flesh_squishy_impact_hard4.wav"),
	Sound(")npc/barnacle/barnacle_die1.wav"),
	Sound(")npc/barnacle/barnacle_die2.wav"),
	Sound(")npc/barnacle/barnacle_digesting1.wav"),
	Sound(")npc/barnacle/barnacle_digesting2.wav"),
	Sound(")npc/barnacle/barnacle_gulp1.wav"),
	Sound(")npc/barnacle/barnacle_gulp2.wav")
}

function ENT:Think()
	self.Tall = math.Approach(self.Tall, math.Clamp(self:GetNestHealth() / self:GetNestMaxHealth(), 0.001, 1), FrameTime())

	if MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD then
		local blocked = false
		local nearest = self:GetPos()
		for _, human in pairs(team.GetPlayers(TEAM_HUMAN)) do
			if util.SkewedDistance(human:GetPos(), nearest, 2.75) <= GAMEMODE.CreeperNestDist then
				blocked = true
				break
			end
		end

		self.Blocked = blocked
	end

	if self.FloorModel:IsValid() then
		local a = math.abs(math.sin(CurTime())) ^ 3
		local hscale = 0.2 + a * 0.04
		self.FloorModel:ManipulateBoneScale(0, Vector(hscale * 1.1 + 0.05, hscale * 1.1 + 0.05, 0.02 * self.Tall))
	end

	if self.DoEmitNextFrame then
		self.DoEmitNextFrame = nil
		self:EmitSound(EmitSounds[math.random(#EmitSounds)], 65, math.random(95, 105))
	end

	self.AmbientSound:PlayEx(0.6, 100 + CurTime() % 1)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()

	if self.FloorModel:IsValid() then
		self.FloorModel:Remove()
	end
end

ENT.NextEmit = 0
local gravParticle = Vector(0, 0, -200)
local matFlesh = Material("models/flesh")
local matWireframe = Material("models/wireframe")

function ENT:Draw()
	local curtime = CurTime() + self.Seed
	local a = math.abs(math.sin(curtime)) ^ 3
	local hscale = 0.2 + a * 0.04
	local built = self:GetNestBuilt()
	local floormodel = self.FloorModel
	local fmvalid = floormodel:IsValid()

	-- 紫色光效
	if built then
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			local lightSize = 256 * (hscale * 5)

			dlight.pos = self:GetPos()
			dlight.r = 150
			dlight.g = 0
			dlight.b = 255
			dlight.brightness = 5 + a * 0.5
			dlight.size = lightSize
			dlight.decay = lightSize * 5
			dlight.die = CurTime() + 0.1
		end
	end

	if built then
		render.ModelMaterialOverride(matFlesh)
	else
		render.ModelMaterialOverride(matWireframe)
		render.SetColorModulation(self.Tall, 0, 0)
	end

	if fmvalid then
		floormodel:ManipulateBoneScale(0, Vector(hscale * 1.1 + 0.05, hscale * 1.1 + 0.05, 0.02 * self.Tall))
	end

	self:ManipulateBoneScale(0, Vector(hscale * 5, hscale * 5, (0.5 - a * 0.025) * self.Tall))
	self:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()

	local pos = self:GetPos() + self:GetUp() * 8
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- ================================================== --
	--             环绕的紫色雾气 (改为定时创建)
	-- ================================================== --
	if built and curtime > self.NextFogEmit then
		-- 更新下一次喷发的时间 (0.3到0.6秒之后)
		self.NextFogEmit = curtime + math.Rand(0.3, 0.6)

		-- 每次喷发1到2个粒子，效果更自然
		for i = 1, 8 do
			local fogpos = pos + Vector(math.Rand(-15, 15), math.Rand(-15, 15), math.Rand(0, 10))
			local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), fogpos)
			if particle then
				particle:SetVelocity(Vector(0,0,math.Rand(40,70)))
				-- 效果调整: 延长粒子生命周期，让效果更平滑
				particle:SetDieTime(3)
				particle:SetStartAlpha(25)
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(20, 40))
				particle:SetEndSize(math.Rand(50, 70))
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-1, 1))
				particle:SetColor(120, 50, 180)
				particle:SetAirResistance(50)
				particle:SetGravity(Vector(0, 0, 5))
			end
		end
	end
	-- ================================================== --

	if not built or curtime < self.NextEmit then
		if emitter then emitter:Finish() end
		return
	end

	self.NextEmit = curtime + math.Rand(0.4, 2)

	if math.random(4) == 1 then
		self.DoEmitNextFrame = true
	end

	-- 原有的喷血效果
	for i=0, math.Rand(0, 1) ^ 0.5 * 10 do
		local particle = emitter:Add("!sprite_bloodspray"..math.random(8), pos)
		if particle then
			particle:SetGravity(gravParticle)
			particle:SetDieTime(math.Rand(4, 6))
			particle:SetVelocity(Angle(math.Rand(-85, -70), math.Rand(0, 360), 0):Forward() * math.Rand(100, 200))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(2, 4))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetColor(180, 0, 0)
			particle:SetCollide(true)
		end
	end

	emitter:Finish()
	emitter = nil
	collectgarbage("step", 64)
end