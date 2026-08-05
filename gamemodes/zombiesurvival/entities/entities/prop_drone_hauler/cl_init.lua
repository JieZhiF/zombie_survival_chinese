-- ============================================================================
-- prop_drone_hauler/cl_init.lua - 搬运无人机（客户端）
-- 负责：播放引擎环境音；被遥控时接管输入键位与第一人称视角；
--       渲染机身、耐久血条与红色警示灯（发光精灵）
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 客户端初始化：渲染边界/引擎音/视野与输入接管钩子 ====
function ENT:Initialize()
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 72))

	-- 创建并播放引擎环境音
	self.AmbientSound = CreateSound(self, "npc/combine_gunship/dropship_engine_distant_loop1.wav")
	self.AmbientSound:Play()

	-- 像素可见性句柄（用于发光精灵遮挡计算）
	self.PixVis = util.GetPixelVisibleHandle()

	-- 注册输入接管/本地玩家绘制/视角覆盖钩子
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
	hook.Add("CalcView", self, self.CalcView)
end

-- ==== Think - 引擎音随飞行速度变调（速度越快音调越高） ====
function ENT:Think()
	self.AmbientSound:PlayEx(0.25, math.Clamp(125 + self:GetVelocity():Length() * 0.5, 150, 250))
end

-- ==== OnRemove - 移除时停止引擎音 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end

-- ==== SetObjectHealth - 耐久写入（DT 同步显示用） ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- 渲染用缓存：颜色/材质/局部偏移向量
local colWhite = Color(255, 255, 255)
local colLight = Color(255, 255, 255)
local matLight = Material("sprites/light_ignorez")
local normalvec = Vector(0, 0, 26)
local spreadvec = Vector(40, 40, 0)

-- ==== DrawTranslucent - 绘制机身/耐久血条/红色警示灯 ====
function ENT:DrawTranslucent()
	local owner = self:GetObjectOwner()
	if not owner:IsValid() then return end

	local lp = MySelf
	-- 是否处于第一人称遥控视角（此时不绘制机身本体）
	local camera = owner == lp and self:BeingControlled()

	if not camera then
		-- 按透明度绘制模型（半透明过渡）
		local alpha = self:TransAlphaToMe()
		render.SetBlend(alpha)
		self:DrawModel()
		render.SetBlend(1)
	end

	-- 警示灯位置与朝向计算
	local epos = self:GetRedLightPos()
	local LightNrm = self:GetForward()
	local ViewNormal = epos - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()
	-- 视角朝向警示灯的系数（背对时衰减）
	local ViewDot = math.min(1, ViewNormal:Dot( LightNrm * -1 ) + 0.25)

	local ang = LightNrm

	-- 人类玩家视角：在无人机上方绘制耐久血条与所有者名牌
	if lp:IsValid() and lp:Team() == TEAM_HUMAN and owner:IsValid() and owner:IsPlayer() then
		local adjvec = epos + spreadvec * ang
		adjvec.z = adjvec.z + 15
		ang = lp:EyeAngles()
		ang.pitch = 0
		ang:RotateAroundAxis(ang:Up(), 270)
		ang:RotateAroundAxis(ang:Forward(), 90)
		-- 3D2D 血条：遥控时贴屏幕绘制，否则在世界空间绘制
		cam.Start3D2D(camera and adjvec or self:LocalToWorld(normalvec), ang, 0.03)
			cam.IgnoreZ(camera)
			local name = ""
			if owner:IsValid() and owner:IsPlayer() then
				name = owner:ClippedName()
			end
			self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name, 150, 0.85, -150)

			cam.IgnoreZ(false)
		cam.End3D2D()
	end

	-- 警示灯发光：可见且视角朝内时按距离衰减绘制内外两层精灵
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

		-- 外层大光晕 + 内层高亮
		render.DrawSprite(LightPos, Size, Size, colLight, Visibile * ViewDot)
		render.DrawSprite(LightPos, Size*0.4, Size*0.4, colWhite, Visibile * ViewDot)
	end
end

-- ==== CreateMove - 遥控时按键映射：跳跃/蹲下映射为上升/下降 ====
function ENT:CreateMove(cmd)
	if self:GetObjectOwner() ~= MySelf then return end

	if not self:BeingControlled() then return end

	local buttons = cmd:GetButtons()

	-- 清除玩家的移动输入（由服务器 PhysicsSimulate 直接驱动）
	cmd:ClearMovement()

	-- 跳跃 → 上升
	if bit.band(buttons, IN_JUMP) ~= 0 then
		buttons = buttons - IN_JUMP
		buttons = buttons + IN_BULLRUSH
	end

	-- 蹲下 → 下降
	if bit.band(buttons, IN_DUCK) ~= 0 then
		buttons = buttons - IN_DUCK
		buttons = buttons + IN_GRENADE1
	end

	cmd:SetButtons(buttons)
end

-- ==== ShouldDrawLocalPlayer - 遥控视角时绘制本地玩家模型 ====
function ENT:ShouldDrawLocalPlayer(pl)
	if self:GetObjectOwner() ~= MySelf then return end

	if self:BeingControlled() then
		return true
	end
end

-- ==== CalcView - 遥控时把玩家视角切换到无人机摄像头位置 ====
function ENT:CalcView(pl, origin, angles, fov, znear, zfar)
	if self:GetObjectOwner() ~= pl or not self:BeingControlled() then return end

	return {origin = self:GetCameraPosition(angles)}
end
