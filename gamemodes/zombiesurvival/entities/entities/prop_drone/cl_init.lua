-- ============================================================================
-- prop_drone/cl_init.lua - 武装无人机（客户端）
-- 负责：飞行/开火音效控制、瞄准光束与命中光点绘制、血量弹药标签显示，
--       以及遥控时的按键映射与镜头/本地玩家绘制调整
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：渲染边界、音效创建与控制钩子注册 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 72))

	self.AmbientSound = CreateSound(self, "npc/scanner/scanner_scan_loop2.wav")
	self.AmbientSound:Play()

	-- 开火循环音（音量由服务器开火状态驱动）
	local sound = "npc/attack_helicopter/aheli_weapon_fire_loop3.wav"
	self.ShootingSound = CreateSound(self, sound)

	self.PixVis = util.GetPixelVisibleHandle()

	-- 遥控期间的按键映射、本地玩家绘制与镜头控制
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
	hook.Add("CalcView", self, self.CalcView)
end

-- ==== Think - 音效更新：飞行音随速度升调，开火音随开火状态启停 ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.5, math.Clamp(75 + self:GetVelocity():Length() * 0.5, 75, 150))

	-- 有弹药且正在开火时播放射击音，否则停止
	if self:GetObjectOwner():IsValid() and self:GetAmmo() > 0 then
		if self:IsFiring() then
			self.ShootingSound:PlayEx(1, 120 + math.cos(CurTime()))
		else
			self.ShootingSound:Stop()
		end
	else
		self.ShootingSound:Stop()
	end
end

-- ==== OnRemove - 清理所有音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
	self.ShootingSound:Stop()
end

-- ==== SetObjectHealth - 客户端血量写入（与网络字段同步） ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

local colWhite = Color(255, 255, 255)
local colLight = Color(255, 255, 255)
local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
local matLight = Material("sprites/light_ignorez")
local normalvec = Vector(0, 0, 26)
local spreadvec = Vector(40, 40, 0)

-- ==== DrawTranslucent - 绘制：瞄准光束、命中点、血条弹药标签与指示光 ====
function ENT:DrawTranslucent()
	self:CalculateFireAngles()

	local owner = self:GetObjectOwner()
	if not owner:IsValid() then return end

	local lp = MySelf
	local camera = owner == lp and self:BeingControlled()

	-- 非控制视角下按透明度绘制机体模型
	if not camera then
		local alpha = self:TransAlphaToMe()
		render.SetBlend(alpha)
		self:DrawModel()
		render.SetBlend(1)
	end

	local ammo = self:GetAmmo()

	-- 计算枪口位置、朝向与视角点积（用于光效强度）
	local epos = self:GetRedLightPos()
	local LightNrm = self:GetForward()
	local ViewNormal = epos - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()
	local ViewDot = math.min(1, ViewNormal:Dot( LightNrm * -1 ) + 0.25)

	-- 沿枪口方向追踪瞄准点
	local ang = self:GetGunAngles()
	local tr = util.TraceLine({start = epos, endpos = epos + ang:Forward() * self.GunRange * (owner.DroneGunRangeMul or 1), mask = MASK_SHOT, filter = self.ScanFilter})

	-- 命中时光束渐变为绿色，未命中渐变为红色
	local rate = FrameTime() * 1024
	if tr.Hit then
		colLight.r = math.Approach(colLight.r, 50, rate)
		colLight.g = math.Approach(colLight.g, 255, rate)
		colLight.b = math.Approach(colLight.b, 255, rate)
	else
		colLight.r = math.Approach(colLight.r, 255, rate)
		colLight.g = math.Approach(colLight.g, 20, rate)
		colLight.b = math.Approach(colLight.b, 20, rate)
	end

	-- 非控制视角绘制两层光束（白色细芯 + 彩色外壳）
	if not camera then
		render.SetMaterial(matBeam)
		render.DrawBeam(epos, tr.HitPos, 1, 0, 1, COLOR_WHITE)
		render.DrawBeam(epos, tr.HitPos, 4, 0, 1, colLight)
	end

	-- 命中点绘制光点（控制视角下更大更亮，作为准星）
	colLight.a = camera and 30 or 255
	render.SetMaterial(matGlow)
	render.DrawSprite(tr.HitPos + tr.HitNormal * 2, camera and 12 or 4, camera and 12 or 4, COLOR_WHITE)
	render.DrawSprite(tr.HitPos + tr.HitNormal * 2, camera and 35 or 10, camera and 35 or 10, colLight)

	-- 控制视角下绘制十字准星线条
	if camera then
		render.DrawSprite(tr.HitPos + tr.HitNormal * 2, 25, 1, COLOR_WHITE)
		render.DrawSprite(tr.HitPos + tr.HitNormal * 2, 1, 25, COLOR_WHITE)
	end

	-- 人类玩家可见的血条与弹药标签（3D2D）
	if lp:IsValid() and lp:Team() == TEAM_HUMAN and owner:IsValid() and owner:IsPlayer() then
		local adjvec = epos + spreadvec * ang:Forward()
		adjvec.z = adjvec.z + 15
		ang = lp:EyeAngles()
		ang.pitch = 0
		ang:RotateAroundAxis(ang:Up(), 270)
		ang:RotateAroundAxis(ang:Forward(), 90)
		cam.Start3D2D(camera and adjvec or self:LocalToWorld(normalvec), ang, 0.03)
			cam.IgnoreZ(camera)
			local name = ""
			if owner:IsValid() and owner:IsPlayer() then
				name = owner:ClippedName()
			end
			self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name, 150, 0.85, -150)

			-- 弹药余量或"已空"提示
			if ammo > 0 then
				draw.SimpleTextBlurry("["..ammo.." / "..self.MaxAmmo.."]", "ZS3D2DFontSmall", 0, 180, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleTextBlurry(translate.Get("empty"), "ZS3D2DFontSmall", 0, 180, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			cam.IgnoreZ(false)
		cam.End3D2D()
	end

	-- 面向玩家可见时绘制枪口指示光（尺寸/透明度随距离与朝向变化）
	if ViewDot > 0 then
		local LightPos = epos + LightNrm * 5

		render.SetMaterial(matLight)
		local Visibile	= util.PixelVisible( LightPos, 16, self.PixVis )

		if not Visibile then return end

		local Size = math.Clamp(Distance * Visibile * ViewDot, 25, 250)

		Distance = math.Clamp(Distance, 32, 800)
		local Alpha = math.Clamp((1000 - Distance) * Visibile * ViewDot, 0, 120)
		colLight.a = Alpha
		colWhite.a = Alpha

		render.DrawSprite(LightPos, Size, Size, colLight, Visibile * ViewDot)
		render.DrawSprite(LightPos, Size*0.4, Size*0.4, colWhite, Visibile * ViewDot)
	end
end

-- ==== CreateMove - 遥控按键映射：跳跃→冲撞，下蹲→手雷键 ====
function ENT:CreateMove(cmd)
	if self:GetObjectOwner() ~= MySelf then return end

	if not self:BeingControlled() then return end

	local buttons = cmd:GetButtons()

	cmd:ClearMovement()

	-- 将跳跃键替换为冲撞键（无人机上升）
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

-- ==== ShouldDrawLocalPlayer - 遥控时强制绘制本地玩家模型 ====
function ENT:ShouldDrawLocalPlayer(pl)
	if self:GetObjectOwner() ~= MySelf then return end

	if self:BeingControlled() then
		return true
	end
end

-- ==== CalcView - 控制时切换到无人机视角（镜头取自相机位置） ====
function ENT:CalcView(pl, origin, angles, fov, znear, zfar)
	if self:GetObjectOwner() ~= pl or not self:BeingControlled() then return end

	return {origin = self:GetCameraPosition(angles)}
end
