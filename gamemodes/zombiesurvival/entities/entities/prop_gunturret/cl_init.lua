-- cl_init.lua
INC_CLIENT() -- 包含客户端宏定义

ENT.NextEmit = 0
ENT.VScreen = Vector(0, -2, 45) -- 3D2D 屏幕相对于实体的坐标
ENT.ScanPitch = 100             -- 扫描音效的基础音调
ENT.ScanSound = "npc/turret_wall/turret_loop1.wav" -- 扫描循环音效

function ENT:Initialize()
	self.BeamColor = Color(0, 255, 0, 255) -- 初始激光颜色（绿色）

	-- 创建循环音效对象
	self.ScanningSound = CreateSound(self, self.ScanSound)
	self.ShootingSound = CreateSound(self, "npc/combine_gunship/gunship_weapon_fire_loop6.wav")

	-- 设置渲染边界，防止远距离时模型消失
	local size = self.SearchDistance + 32
	local nsize = -size
	self:SetRenderBounds(Vector(nsize, nsize, nsize * 0.25), Vector(size, size, size * 0.25))

	-- 挂载钩子：用于玩家手动控制时的操作重定向、视角调整等
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
	hook.Add("CalcView", self, self.CalcView)
end

function ENT:Think()
	-- 音效逻辑处理
	if self:GetObjectOwner():IsValid() and self:GetAmmo() > 0 and self:GetMaterial() == "" then
		-- 有主人且有弹药时，播放扫描音效（音调随时间微弱震荡）
		self.ScanningSound:PlayEx(0.55, self.ScanPitch + math.sin(CurTime()))
		
		-- 如果正在射击或锁定目标，播放射击循环音效
		if self.PlayLoopingShootSound and (self:IsFiring() or self:GetTarget():IsValid()) then
			self.ShootingSound:PlayEx(1, 100 + math.cos(CurTime()))
		else
			self.ShootingSound:Stop()
		end
	else
		-- 否则停止所有循环音效
		self.ScanningSound:Stop()
		self.ShootingSound:Stop()
	end
end

function ENT:OnRemove()
	-- 实体移除时必须停止循环音效，否则会变成“鬼音”一直响
	self.ScanningSound:Stop()
	self.ShootingSound:Stop()
end

function ENT:SetObjectHealth(health)
	self:SetDTFloat(3, health)
end

-- 缓存常用函数提高性能
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local draw_SimpleText = draw.SimpleText
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local cam_Start3D2D = cam.Start3D2D
local cam_End3D2D = cam.End3D2D
local smokegravity = Vector(0, 0, 200)
local aScreen = Angle(0, 270, 60)

----------------------------------------
-- 主绘制函数 (不透明部分)
----------------------------------------
function ENT:Draw()
	-- 1. 更新姿态参数（让模型动起来）
	self:CalculatePoseAngles()
	self:SetPoseParameter("aim_yaw", self.PoseYaw)
	self:SetPoseParameter("aim_pitch", self.PosePitch)

	local owner = self:GetObjectOwner()

	-- 如果我自己正在手动控制这个炮塔，就不渲染模型（防止挡住视野）
	if owner == MySelf and self:GetManualControl() then return end

	-- 2. 绘制模型
	local alpha = self:TransAlphaToMe() -- 考虑到透明度效果
	render.SetBlend(alpha)
	self:DrawModel()
	render.SetBlend(1)

	-- 3. 受损烟雾特效
	local healthpercent = self:GetObjectHealth() / self:GetMaxObjectHealth()
	if healthpercent <= 0.5 and CurTime() >= self.NextEmit then
		self.NextEmit = CurTime() + 0.05

		local pos = self:DefaultPos()
		local sat = healthpercent * 360

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)
		local particle = emitter:Add("particles/smokey", pos)
		if particle then
			particle:SetStartAlpha(180)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(math.Rand(8, 32))
			particle:SetColor(sat, sat, sat)
			particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(8, 64))
			particle:SetGravity(smokegravity)
			particle:SetDieTime(math.Rand(0.8, 1.6))
			particle:SetAirResistance(150)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-4, 4))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
		end
		emitter:Finish()
	end

	-- 4. 绘制 3D2D 状态屏幕
	if not MySelf:IsValid() or MySelf:Team() ~= TEAM_HUMAN then return end

	local ammo = self:GetAmmo()
	local flash = math.sin(CurTime() * 15) > 0
	local wid, hei = 128, 92
	local x = wid / 2

	cam_Start3D2D(self:LocalToWorld(self.VScreen), self:LocalToWorldAngles(aScreen), 0.075)
		-- 背景底框
		surface_SetDrawColor(0, 0, 0, 160)
		surface_DrawRect(0, 0, wid, hei)

		-- 边框装饰
		surface_SetDrawColor(200, 200, 200, 160)
		surface_DrawRect(0, 0, 8, 16)
		surface_DrawRect(wid - 8, 0, 8, 16)
		surface_DrawRect(8, 0, wid - 16, 8)
		surface_DrawRect(0, hei - 16, 8, 16)
		surface_DrawRect(wid - 8, hei - 16, 8, 16)
		surface_DrawRect(8, hei - 8, wid - 16, 8)

		-- 绘制文本信息
		if owner:IsValid() and owner:IsPlayer() then
			draw_SimpleText(owner:ClippedName(), "DefaultFont", x, 10, owner == MySelf and COLOR_LBLUE or COLOR_WHITE, TEXT_ALIGN_CENTER)
		end
		-- 耐久度
		draw_SimpleText(translate.Format("integrity_x", math.ceil(healthpercent * 100)), "DefaultFontBold", x, 25, COLOR_WHITE, TEXT_ALIGN_CENTER)

		-- 手动控制提示
		if flash and self:GetManualControl() then
			draw_SimpleText(translate.Get("manual_control"), "DefaultFont", x, 40, COLOR_YELLOW, TEXT_ALIGN_CENTER)
		end

		-- 弹药量显示
		if ammo > 0 then
			draw_SimpleText("["..ammo.." / "..self.MaxAmmo.."]", "DefaultFontBold", x, 55, COLOR_WHITE, TEXT_ALIGN_CENTER)
		elseif flash then
			draw_SimpleText(translate.Get("empty"), "DefaultFontBold", x, 55, COLOR_RED, TEXT_ALIGN_CENTER)
		end

		-- 通道显示
		draw_SimpleText("CH. "..self:GetChannel().." / "..GAMEMODE.MaxChannels["turret"], "DefaultFontSmall", x, 70, COLOR_WHITE, TEXT_ALIGN_CENTER)
	cam_End3D2D()
end

----------------------------------------
-- 激光特效绘制 (透明渲染阶段)
----------------------------------------
local matBeam = Material("trails/laser")
local matGlow = Material("sprites/glow04_noz")

function ENT:DrawTranslucent()
	if self:GetMaterial() ~= "" then return end

	local lightpos = self:LightPos()
	local ang = self:GetGunAngles()
	local alpha = self:TransAlphaToMe()
	local colBeam = self.BeamColor

	local owner = self:GetObjectOwner()
	local hasowner = owner:IsValid()
	local hasammo = self:GetAmmo() > 0
	local manualcontrol = self:GetManualControl()

	-- 计算激光射线
	local tr = util.TraceLine({
		start = lightpos, 
		endpos = lightpos + ang:Forward() * (manualcontrol and 4096 or self.SearchDistance * (hasowner and owner.TurretRangeMul or 1)), 
		mask = MASK_SHOT, 
		filter = self:GetCachedScanFilter()
	})

	-- 根据状态平滑切换激光颜色
	local rate = FrameTime() * 512
	if not hasowner then
		-- 无主状态：蓝色
		colBeam.r = math.Approach(colBeam.r, 0, rate)
		colBeam.g = math.Approach(colBeam.g, 0, rate)
		colBeam.b = math.Approach(colBeam.b, 255, rate)
	elseif not hasammo or (not manualcontrol and self:GetTarget():IsValid()) then
		-- 没弹药或自动锁定目标中：红色
		colBeam.r = math.Approach(colBeam.r, 255, rate)
		colBeam.g = math.Approach(colBeam.g, 0, rate)
		colBeam.b = math.Approach(colBeam.b, 0, rate)
	elseif manualcontrol then
		-- 手动控制：黄色
		colBeam.r = math.Approach(colBeam.r, 255, rate)
		colBeam.g = math.Approach(colBeam.g, 255, rate)
		colBeam.b = math.Approach(colBeam.b, 0, rate)
	else
		-- 正常扫描：绿色
		local rate2 = FrameTime() * 200
		colBeam.r = math.Approach(colBeam.r, 0, rate2)
		colBeam.g = math.Approach(colBeam.g, 255, rate2)
		colBeam.b = math.Approach(colBeam.b, 0, rate2)
	end

	-- 绘制光束与光晕
	if hasowner and hasammo then
		render.SetMaterial(matBeam)
		if alpha > 0.5 then
			render.DrawBeam(lightpos, tr.HitPos, 1 * self.ModelScale, 0, 1, COLOR_WHITE)
		end
		render.DrawBeam(lightpos, tr.HitPos, 4 * self.ModelScale, 0, 1, colBeam)
		
		render.SetMaterial(matGlow)
		-- 枪口光晕
		if alpha > 0.5 then
			render.DrawSprite(lightpos, 4 * self.ModelScale, 4 * self.ModelScale, COLOR_WHITE)
		end
		render.DrawSprite(lightpos, 16 * self.ModelScale, 16 * self.ModelScale, colBeam)
		-- 击中点光晕
		render.DrawSprite(tr.HitPos, 2, 2, COLOR_WHITE)
		render.DrawSprite(tr.HitPos, 8, 8, colBeam)
	else
		-- 仅在枪口显示微弱光晕
		render.SetMaterial(matGlow)
		render.DrawSprite(lightpos, 4 * self.ModelScale, 4 * self.ModelScale, COLOR_WHITE)
		render.DrawSprite(lightpos, 16 * self.ModelScale, 16 * self.ModelScale, colBeam)
	end
end

----------------------------------------
-- 玩家手动控制逻辑 (客户端同步)
----------------------------------------

function ENT:SetTarget(ent)
	if ent:IsValid() then
		self:SetTargetReceived(CurTime())
	else
		self:SetTargetLost(CurTime())
	end
	self:SetDTEntity(0, ent)
end

function ENT:SetObjectOwner(ent)
	self:SetDTEntity(1, ent)
end

-- 劫持玩家输入：手动控制时禁止玩家移动，只能控制炮塔
function ENT:CreateMove(cmd)
	if self:GetObjectOwner() ~= MySelf or not self:GetManualControl() then return end

	local buttons = cmd:GetButtons()
	cmd:ClearMovement() -- 清除移动（WASD无效）

	-- 将空格(跳跃)映射为指令 A，蹲下映射为指令 B (具体取决于控制逻辑)
	if bit.band(buttons, IN_JUMP) ~= 0 then
		buttons = buttons - IN_JUMP
		buttons = buttons + IN_BULLRUSH
	end
	if bit.band(buttons, IN_DUCK) ~= 0 then
		buttons = buttons - IN_DUCK
		buttons = buttons + IN_GRENADE1
	end

	cmd:SetButtons(buttons)
end

-- 手动控制时是否允许绘制本地玩家模型
function ENT:ShouldDrawLocalPlayer(pl)
	if self:GetObjectOwner() == MySelf and self:GetManualControl() then
		return true -- 此时视角在炮塔上，玩家身体应该被渲染在原本位置
	end
end

-- 手动控制时的视角计算
local trace_cam = {mask = MASK_VISIBLE, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
function ENT:CalcView(pl, origin, angles, fov, znear, zfar)
	if self:GetObjectOwner() ~= pl or not self:GetManualControl() then return end

	-- 将相机移动到炮塔的射击口位置
	local filter = player.GetAll()
	filter[#filter + 1] = self
	trace_cam.start = self:ShootPos()
	trace_cam.endpos = trace_cam.start
	trace_cam.filter = filter
	
	local tr = util.TraceHull(trace_cam)

	-- 返回新的视角信息
	return {origin = tr.HitPos + tr.HitNormal * 3, angles = angles}
end