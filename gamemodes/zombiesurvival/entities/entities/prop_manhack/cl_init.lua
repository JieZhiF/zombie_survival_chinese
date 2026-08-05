-- ============================================================================
-- prop_manhack/cl_init.lua - 玩家控制的无人机（客户端）
-- 负责：环境音效、受伤冒烟、警告灯与血条显示，以及控制模式下的
--       输入重映射、第三人称视角和本地玩家绘制
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：设置渲染边界、环境音效、子模型与视角钩子 ====
function ENT:Initialize()
	-- 扩大渲染边界，保证旋转/缩放动画完整显示
	self:SetRenderBounds(Vector(-72, -72, -72), Vector(72, 72, 72))

	self:CreateAmbientSounds()
	self:CreateSubModel()

	-- 像素可见性句柄：用于警告灯的遮挡检测
	self.PixVis = util.GetPixelVisibleHandle()

	-- 注册输入重映射、本地玩家绘制与相机视角钩子（控制模式下生效）
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)
	hook.Add("CalcView", self, self.CalcView)
end

-- ==== CreateSubModel - 创建附加子模型（空实现，供派生无人机类型覆盖） ====
function ENT:CreateSubModel()
end

-- ==== CreateAmbientSounds - 创建引擎与刀刃旋转的循环音效 ====
function ENT:CreateAmbientSounds()
	self.AmbientSound = CreateSound(self, "npc/manhack/mh_engine_loop1.wav")
	self.AmbientSound2 = CreateSound(self, "npc/manhack/mh_blade_loop1.wav")
end

-- ==== PlayAmbientSounds - 播放环境音效：音量随飞行速度变化 ====
function ENT:PlayAmbientSounds()
	-- 引擎声：音量 0.5，音调随速度升高（上限 160）
	self.AmbientSound:PlayEx(0.5, math.min(80 + self:GetVelocity():Length() * 0.3, 160))
	-- 刀刃声：音量 0.3，音调随时间轻微起伏
	self.AmbientSound2:PlayEx(0.3, 100 + math.sin(CurTime()))
end

-- 冒烟粒子生成的节流时间戳
ENT.NextEmit = 0
-- 烟雾向上飘升的重力向量
local smokegravity = Vector(0, 0, 64)
-- ==== Think - 每帧播放环境音，生命低于 50% 时按受损程度冒烟 ====
function ENT:Think()
	self:PlayAmbientSounds()

	-- 剩余生命比例：越低冒烟越频繁
	local perc = math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 255)
	if perc < 0.5 and CurTime() >= self.NextEmit then
		-- 受损越重，粒子生成间隔越短
		self.NextEmit = CurTime() + 0.05 + perc * math.Rand(0.05, 0.25)

		local pos = self:GetPos()
		-- 烟雾灰度随受损程度加深（0~90）
		local sat = perc * 90

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(16, 24)

		-- 黑色烟雾：向上飘升、膨胀并逐渐淡出
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

		-- 结束发射器并释放内存
		emitter:Finish() emitter = nil collectgarbage("step", 64)
	end
end

-- ==== OnRemove - 移除时停止环境音效并清理子模型 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
	self.AmbientSound2:Stop()
	self:RemoveSubModel()
end

-- ==== RemoveSubModel - 移除附加子模型（空实现，供派生类型覆盖） ====
function ENT:RemoveSubModel()
end

-- ==== SetObjectHealth - 客户端同步当前生命值到 DT（供 HUD/血条读取） ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
end

-- ==== DrawSubModel - 绘制附加子模型（空实现，供派生类型覆盖） ====
function ENT:DrawSubModel()
end

-- 警告灯颜色与材质（灯光精灵材质，忽略深度测试）
local colLight = Color(255, 0, 0)
local colWhite = Color(255, 255, 255)
local matLight = Material("sprites/light_ignorez")
-- ==== DrawTranslucent - 绘制本体、3D2D 血条与警告灯 ====
function ENT:DrawTranslucent()

	-- 依据到拥有者的距离/可见性调节整体透明度
	local alpha = self:TransAlphaToMe()
	render.SetBlend(alpha)
	self:DrawModel()
	self:DrawSubModel()
	render.SetBlend(1)

	-- 人类玩家视角下，在无人机上方显示拥有者名字与生命血条
	local lp = MySelf
	local owner = self:GetObjectOwner()

	if lp:IsValid() and lp:Team() == TEAM_HUMAN and owner:IsValid() and owner:IsPlayer() then
		local ang = EyeAngles()
		ang.pitch = 0

		-- 旋转 3D2D 画布使其面向玩家
		ang:RotateAroundAxis(ang:Up(), 270)
		ang:RotateAroundAxis(ang:Forward(), 90)
		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 16)), ang, 0.03)
			local name = ""
			if owner:IsValid() and owner:IsPlayer() then
				name = owner:ClippedName()
			end
			self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name, 150, 0.85, -150)
		cam.End3D2D()
	end

	-- 警告灯：位于无人机下方，朝向观察者且未被遮挡时才绘制
	local epos = self:GetRedLightPos()
	local LightNrm = self:GetRedLightAngles():Forward()
	local ViewNormal = epos - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()
	local ViewDot = ViewNormal:Dot( LightNrm * -1 )

	if ViewDot >= 0 then
		-- 灯光颜色取拥有者的玩家颜色（按比例缩放）
		if owner:IsValid() and owner:IsPlayer() then
			local vcol = owner:GetPlayerColor()
			if vcol then
				-- 默认颜色为黑时视为白色
				if vcol == vector_origin then
					vcol.x = 1 vcol.y = 1 vcol.z = 1
				end
				vcol:Normalize()
				vcol = vcol * 2.55
				colLight.r = math.Clamp(vcol.r * 100, 0, 255)
				colLight.g = math.Clamp(vcol.g * 100, 0, 255)
				colLight.b = math.Clamp(vcol.b * 100, 0, 255)
			end
		end

		local LightPos = epos + LightNrm * 5

		render.SetMaterial(matLight)
		-- 像素可见性检测：被遮挡时不绘制灯光
		local Visibile	= util.PixelVisible( LightPos, 16, self.PixVis )

		if not Visibile then return end

		-- 灯光大小与透明度随距离衰减
		local Size = math.Clamp(Distance * Visibile * ViewDot * 0.9, 20, 210)

		Distance = math.Clamp(Distance, 32, 800)
		local Alpha = math.Clamp((1000 - Distance) * Visibile * ViewDot, 0, 100)
		colLight.a = Alpha
		colWhite.a = Alpha

		-- 绘制彩色大光晕与白色小核心
		render.DrawSprite(LightPos, Size, Size, colLight, Visibile * ViewDot)
		render.DrawSprite(LightPos, Size*0.4, Size*0.4, colWhite, Visibile * ViewDot)
	end
end

-- ==== CreateMove - 控制模式下重映射输入：跳跃→突进，下蹲→投掷 ====
function ENT:CreateMove(cmd)
	-- 仅限控制者本人操作
	if self:GetObjectOwner() ~= MySelf then return end

	-- 未处于控制模式时不干预输入
	if not self:BeingControlled() then return end

	local buttons = cmd:GetButtons()

	-- 控制模式下禁止位移输入（由无人机自行飞行）
	cmd:ClearMovement()

	-- 跳跃键映射为突进（BULLRUSH）
	if bit.band(buttons, IN_JUMP) ~= 0 then
		buttons = buttons - IN_JUMP
		buttons = buttons + IN_BULLRUSH
	end

	-- 下蹲键映射为投掷（GRENADE1）
	if bit.band(buttons, IN_DUCK) ~= 0 then
		buttons = buttons - IN_DUCK
		buttons = buttons + IN_GRENADE1
	end

	cmd:SetButtons(buttons)
end

-- ==== ShouldDrawLocalPlayer - 控制模式下绘制本地玩家模型（第三人称） ====
function ENT:ShouldDrawLocalPlayer(pl)
	if self:GetObjectOwner() ~= MySelf then return end

	-- 控制期间：绘制本地玩家，并注册目标 ID 过滤
	if self:BeingControlled() then
		if MySelf == pl and not MySelf.TargetIDFilter then
			MySelf.TargetIDFilter = self
		end

		return true
	-- 脱离控制：清除目标 ID 过滤
	elseif MySelf == pl and MySelf.TargetIDFilter then
		MySelf.TargetIDFilter = nil
	end
end

-- 第三人称相机的射线检测参数（可见性遮罩，4 单位包围盒）
local trace_cam = {mask = MASK_VISIBLE, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
-- ==== CalcView - 控制模式下从无人机后方 48 单位处取景，检测碰撞防穿墙 ====
function ENT:CalcView(pl, origin, angles, fov, znear, zfar)
	-- 仅控制模式下且为控制者本人时生效
	if self:GetObjectOwner() ~= pl or not self:BeingControlled() then return end

	-- 从无人机位置向后 48 单位做包围盒射线检测，排除所有玩家与自身
	local filter = player.GetAll()
	filter[#filter + 1] = self
	trace_cam.start = self:GetPos()
	trace_cam.endpos = trace_cam.start + angles:Forward() * -48
	trace_cam.filter = filter
	local tr = util.TraceHull(trace_cam)

	-- 相机贴紧遮挡物表面（外推 3 单位），避免视线穿墙
	return {origin = tr.HitPos + tr.HitNormal * 3}
end
