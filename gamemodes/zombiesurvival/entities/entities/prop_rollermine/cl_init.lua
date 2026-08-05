-- ============================================================================
-- prop_rollermine/cl_init.lua - 滚动地雷（客户端）
-- 负责：移动音效随速度切换、低血量冒烟提示、控制者的 3D2D 血条显示，
--       以及遥控时的按键映射与镜头/本地玩家绘制调整
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：渲染边界、音效/子模型、控制钩子注册 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 72))

	self:CreateAmbientSounds()
	self:CreateSubModel()

	self.PixVis = util.GetPixelVisibleHandle()

	-- 遥控期间的按键映射、本地玩家绘制与镜头控制
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
	hook.Add("CalcView", self, self.CalcView)
end

-- ==== CreateSubModel - 空实现：子模型扩展点（基类无附加模型） ====
function ENT:CreateSubModel()
end

-- ==== CreateAmbientSounds - 创建两种循环移动音效 ====
function ENT:CreateAmbientSounds()
	self.AmbientSound = CreateSound(self, "npc/roller/mine/rmine_moveslow_loop1.wav")
	self.AmbientSound2 = CreateSound(self, "npc/roller/mine/rmine_seek_loop2.wav")
end

-- ==== PlayAmbientSounds - 按速度切换音效：低速搜寻音/高速移动音 ====
function ENT:PlayAmbientSounds()
	if self:GetVelocity():Length() < 50 then
		self.AmbientSound:Stop()
		self.AmbientSound2:PlayEx(0.7, 100 + math.sin(CurTime()))
	else
		self.AmbientSound:PlayEx(0.8, math.min(70 + self:GetVelocity():Length() * 0.4, 140))
		self.AmbientSound2:Stop()
	end
end

-- 冒烟粒子的发射节流时间戳
ENT.NextEmit = 0
local smokegravity = Vector(0, 0, 64)
-- ==== Think - 低血量时按血量比例从体内冒出灰色烟雾 ====
function ENT:Think()
	self:PlayAmbientSounds()

	-- 血量低于 50% 时开始冒烟，血越少烟雾越浓、发射越频繁
	local perc = math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 255)
	if perc < 0.5 and CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 0.05 + perc * math.Rand(0.05, 0.25)

		local pos = self:GetPos()
		local sat = perc * 90

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(16, 24)

		-- 配置烟雾粒子：透明度渐隐、随本体速度漂移、缓慢上浮
		local particle = emitter:Add("particles/smokey", pos)
		particle:SetStartAlpha(180)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(8, 20))
		particle:SetVelocity(self:GetVelocity() * 0.7 + VectorRand():GetNormalized() * math.Rand(4, 24))
		particle:SetGravity(smokegravity)
		particle:SetDieTime(math.Rand(0.8, 1.6))
		particle:SetAirResistance(150)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetCollide(true)
		particle:SetBounce(0.2)
		particle:SetColor(sat, sat, sat)

		-- 释放发射器并主动触发一步 GC
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end

-- ==== OnRemove - 清理音效与子模型 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
	self.AmbientSound2:Stop()
	self:RemoveSubModel()
end

-- ==== RemoveSubModel - 空实现：子模型移除扩展点 ====
function ENT:RemoveSubModel()
end

-- ==== SetObjectHealth - 客户端血量写入（与网络字段同步） ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- ==== DrawSubModel - 空实现：子模型绘制扩展点 ====
function ENT:DrawSubModel()
end

local colLight = Color(255, 0, 0)
local colWhite = Color(255, 255, 255)
local matLight = Material("sprites/light_ignorez")
-- ==== DrawTranslucent - 绘制本体并显示拥有者名血条 ====
function ENT:DrawTranslucent()
	self:DrawModel()

	self:DrawSubModel()

	local lp = MySelf
	local owner = self:GetObjectOwner()

	-- 仅人类玩家可见地雷上方的血条标签（3D2D）
	if lp:IsValid() and lp:Team() == TEAM_HUMAN and owner:IsValid() and owner:IsPlayer() then
		local ang = EyeAngles()
		ang.pitch = 0

		ang:RotateAroundAxis(ang:Up(), 270)
		ang:RotateAroundAxis(ang:Forward(), 90)

		cam.Start3D2D(self:GetPos() + Vector(0, 0, 20), ang, 0.03)
			local name = ""
			if owner:IsValid() and owner:IsPlayer() then
				name = owner:ClippedName()
			end
			self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name, 150, 0.85, -150)
		cam.End3D2D()
	end
end

-- ==== CreateMove - 遥控按键映射：跳跃→冲撞，下蹲→手雷键 ====
function ENT:CreateMove(cmd)
	if self:GetObjectOwner() ~= MySelf then return end

	if not self:BeingControlled() then return end

	local buttons = cmd:GetButtons()

	cmd:ClearMovement()

	-- 将跳跃键替换为冲撞键（地雷跳跃）
	if bit.band(buttons, IN_JUMP) ~= 0 then
		buttons = buttons - IN_JUMP
		buttons = buttons + IN_BULLRUSH
	end

	-- 将下蹲键替换为手雷键（退出控制）
	if bit.band(buttons, IN_DUCK) ~= 0 then
		buttons = buttons - IN_DUCK
		buttons = buttons + IN_GRENADE1
	end

	cmd:SetButtons(buttons)
end

-- ==== ShouldDrawLocalPlayer - 遥控时绘制本地玩家并设置目标 ID 过滤 ====
function ENT:ShouldDrawLocalPlayer(pl)
	if self:GetObjectOwner() ~= MySelf then return end

	if self:BeingControlled() then
		-- 控制期间强制绘制自己的玩家模型，并让准星目标过滤指向地雷
		if MySelf == pl and not MySelf.TargetIDFilter then
			MySelf.TargetIDFilter = self
		end

		return true
	elseif MySelf == pl and MySelf.TargetIDFilter then
		MySelf.TargetIDFilter = nil
	end
end

local trace_cam = {mask = MASK_VISIBLE, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
-- ==== CalcView - 控制时从地雷后方拉远镜头并做遮挡追踪 ====
function ENT:CalcView(pl, origin, angles, fov, znear, zfar)
	if self:GetObjectOwner() ~= pl or not self:BeingControlled() then return end

	-- 从地雷位置向后 48 单位追踪，被遮挡时镜头移到最近遮挡点
	local filter = player.GetAll()
	filter[#filter + 1] = self
	trace_cam.start = self:GetPos()
	trace_cam.endpos = trace_cam.start + angles:Forward() * -48
	trace_cam.filter = filter
	local tr = util.TraceHull(trace_cam)

	return {origin = tr.HitPos + tr.HitNormal * 3}
end
