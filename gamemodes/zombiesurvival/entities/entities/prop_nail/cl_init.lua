-- ============================================================================
-- prop_nail - 路障钉子实体（客户端）
-- 负责：绘制钉子模型、低血量时爆发火花特效，并在条件满足时以 3D2D 信息板显示路障血量/修理次数/放置者
-- ============================================================================
INC_CLIENT()

-- 渲染分组：半透明（配合 3D2D 信息板叠加绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-- 下次火花粒子发射时间（限频用）
ENT.NextEmit = 0


-- ==== SetAttachEntity - 客户端仅记录附着实体引用 ====
function ENT:SetAttachEntity(ent, physbone1, physbone2)
	self.m_AttachEntity = ent
end

-- ==== OnRemove - 钉子被拔除时沿法线方向爆发火花粒子并播放金属音效 ====
function ENT:OnRemove()
	local normal = self:GetForward() * -1
	local pos = self:GetPos() + normal

	sound.Play("physics/metal/metal_box_impact_bullet"..math.random(1, 3)..".wav", pos, 75, math.random(90, 110))

	local grav = Vector(0, 0, -300)

	-- 生成 32~48 颗火花：沿拔除方向喷出、受重力下落、带弹跳
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(22, 32)
	for i=1, math.random(32, 48) do
		local vNormal = (VectorRand() * 0.6 + normal):GetNormalized()
		local particle = emitter:Add("effects/spark", pos + vNormal)
		particle:SetVelocity(vNormal * math.Rand(16, 100))
		particle:SetDieTime(math.Rand(0.5, 1))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(0.4, 1.5))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetGravity(grav)
	end
	emitter:Finish() emitter = nil collectgarbage("step", 64)
end

-- 专家（已转生）玩家标记用的挂锁图标材质
local matExpert = Material("zombiesurvival/padlock.png")
-- 好友玩家标记用的爱心图标材质
local matHeart = Material("icon16/heart.png")
-- 钉子血量条颜色（运行时按剩余血量红绿渐变）
local colNail = Color(0, 0, 5, 220)
-- 信息文字常规颜色
local colText = Color(240, 240, 240, 150)
-- 信息文字高亮颜色
local colText_High = Color(240, 240, 240, 190)
-- 放置者已死亡时的名字颜色
local colDead = Color(230, 80, 80, 95)
-- ==== DrawTranslucent - 绘制钉子模型、低血量火花特效与路障状态 3D2D 信息板 ====
function ENT:DrawTranslucent()
	local parent = self:GetParent()
	-- 父实体无效或本帧已绘制过信息板时只绘制模型
	if not parent:IsValid() or RealTime() == parent.LastNailInfoDraw then
		self:DrawModel()
		return
	end

	local drawinfo
	local myteam
	local pos
	local eyepos
	if MySelf:IsValid() then
		myteam = MySelf:Team()
		pos = self:GetPos()
		eyepos = EyePos()
		-- 人类/观察者：开启常显、按住加速键或准星瞄准该路障，且距离在 512 英寸内、视线无遮挡时才显示
		if myteam == TEAM_HUMAN or myteam == TEAM_SPECTATOR then
			drawinfo = (GAMEMODE.AlwaysShowNails or MySelf:KeyDown(IN_SPEED) or GAMEMODE.TraceTargetNoPlayers == self:GetParent()) and eyepos:DistToSqr(pos) <= 262144 and WorldVisible(eyepos, pos)
		elseif myteam == TEAM_UNDEAD then
			-- 亡灵：仅当准星瞄准该路障时显示
			drawinfo = GAMEMODE.TraceTargetNoPlayers == self:GetParent()
		end
	end

	self:DrawModel()

	local nhp = self:GetNailHealth()
	local mnhp = self:GetMaxNailHealth()

	-- 血量低于 35% 时周期性爆发黄绿色火花并播放音效（带随机冷却）
	if nhp/mnhp < 0.35 and CurTime() > self.NextEmit then
		local normal = self:GetForward() * -1
		local epos = self:GetPos() + normal

		sound.Play("physics/metal/metal_box_impact_bullet"..math.random(1, 3)..".wav", pos, 58, math.random(210, 240))

		local emitter = ParticleEmitter(epos)
		emitter:SetNearClip(22, 32)
		-- 生成 6~12 颗短促的火花粒子
		for i=1, math.random(6, 12) do
			local vNormal = (VectorRand() * 0.6 + normal):GetNormalized()
			local particle = emitter:Add("effects/spark", epos + vNormal)
			particle:SetDieTime(math.Rand(0.1, 0.2))
			particle:SetGravity(Vector(math.random(-5, 5), math.random(-5, 5), math.random(1, 3)):GetNormal() * 50)
			particle:SetStartAlpha(100)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(1)
			particle:SetStartLength(10)
			particle:SetEndLength(0)
			particle:SetColor(165, 188, 0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
		end
		emitter:Finish() emitter = nil collectgarbage("step", 64)

		self.NextEmit = CurTime() + math.Rand(4.2, 5.8)
	end

	-- 满足显示条件时绘制 3D2D 信息板
	if drawinfo then
		-- 记录本帧已绘制，避免同一路障同帧被重复绘制
		parent.LastNailInfoDraw = RealTime()

		local displayowner = self:GetDTString(0)
		local redname = false
		local expert = false
		local hcolor = COLOR_WHITE

		local deployer = self:GetOwner()
		-- 未直接指定显示名字时从放置者生成；死亡/非人类放置者的名字标红
		if displayowner == "" then
			displayowner = nil

			if deployer:IsValid() then
				displayowner = deployer:Name()
				if deployer:Team() == TEAM_HUMAN and deployer:Alive() then
					local rlvl = deployer:GetZSRemortLevel()
					expert = rlvl > 0

					-- 专家（已转生）玩家：按转生等级段查找对应的名字高亮颜色
					if expert then
						local rlvlmod, hlvl = math.floor((rlvl % 40) / 4), 0
						for rlvlr, rcolor in pairs(GAMEMODE.RemortColors) do
							if rlvlmod >= rlvlr and rlvlr >= hlvl then
								hlvl = rlvlr
								hcolor = rcolor
							end
						end
					end
				else
					-- 放置者已死亡：名字前加 (DEAD) 标记并标红
					displayowner = "(DEAD) "..displayowner
					redname = true
				end
			end
		end

		-- 旋转 3D2D 基准角度使信息板始终朝向观察者
		local ang = EyeAngles()
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		local nearest = parent:WorldSpaceCenter()
		local norm = nearest - eyepos
		norm:Normalize()
		local dot = EyeVector():Dot(norm)

		-- 视线与信息板方向越接近正面越清晰，背对时透明度快速衰减
		local dotsq = dot * dot
		local vis = math.Clamp((dotsq * dotsq) - 0.1, 0, 1)

		if vis < 0.01 then return end

		-- 忽略深度测试，使信息板穿透障碍物可见
		cam.IgnoreZ(true)

		cam.Start3D2D(nearest, ang, 0.1)
			local wid, hei = 150, 6
			local x, y = wid * -0.5 + 2, 0

			-- 好友（爱心）或专家（挂锁）玩家在名字旁绘制对应标记图标
			local validfriend = deployer:IsValidLivingHuman() and deployer.ZSFriendAdded

			if validfriend or expert then
				surface.SetMaterial(validfriend and matHeart or matExpert)
				surface.SetDrawColor(hcolor.r, hcolor.g, hcolor.b, 240 * vis)
				surface.DrawTexturedRect(
					x - (validfriend and 24 or 32),
					y - (validfriend and 0 or 5),
					validfriend and 16 or 24,
					validfriend and 16 or 24
				)
			end

			-- 绘制修理次数条与钉子血量条（每 200 值分段绘制，支持超大数值显示）
			if self:GetMaxRepairs() > 0 or self:GetMaxNailHealth() > 0 then
				local repairs = self:GetRepairs()
				local mrps = self:GetMaxRepairs()

				-- 修理次数条（蓝色）
				surface.SetDrawColor(0, 0, 0, 210 * vis)
				surface.DrawRect(x - 1, y, mrps/5 + mrps/50 + 1, hei)

				for i = 0, repairs, 200 do
					local val = math.Clamp(repairs - i, 0, 200)

					surface.SetDrawColor(100, 170, 215, 240 * vis)
					surface.DrawRect(x + 1 + i/5 + i/50, y + 1, val/5, hei - 2)
				end

				-- 血量条颜色随剩余血量比例从红色渐变到绿色
				local mu = math.Clamp(nhp / mnhp, 0, 1)
				local green = mu * 200
				colNail.r = 200 - green
				colNail.g = green
				colNail.a = 240 * vis

				y = y + hei + 3
				hei = 8
				x = wid * -0.5 + 2

				-- 钉子血量条（红绿渐变）
				surface.SetDrawColor(0, 0, 0, 210 * vis)
				surface.DrawRect(x - 1, y, mnhp/5 + mnhp/50 + 2, hei)

				for i = 0, nhp, 200 do
					local val = math.Clamp(nhp - i, 0, 200)

					surface.SetDrawColor(colNail)
					surface.DrawRect(x + 1 + i/5 + i/50, y + 1, val/5, hei - 2)
				end

				-- 显示放置者名字与当前/最大血量数字
				if displayowner then
					local col = redname and colDead or colText
					col.a = 150 * vis

					draw.SimpleText(displayowner, "BarrierFont", 0, y + 20, colText, TEXT_ALIGN_CENTER)
					draw.SimpleText(math.floor(nhp) .. "/" .. math.floor(self:GetMaxNailHealth()), "BarrierFont", x + 45, y - 45, colText_High, TEXT_ALIGN_CENTER)
				end
				draw.SimpleText("按[Z/B]来穿过", "BarrierFont", x + 75, y +45, colText_High, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()

		cam.IgnoreZ(false)
	end
end
