-- ============================================================================
-- prop_nail - 路障钉子实体（客户端）
-- 负责：绘制钉子模型、低血量时爆发火花特效，并显示竖向血条及路障状态信息
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
local colNailText = Color(255, 255, 255, 255)
local colNailTextOutline = Color(0, 0, 0, 200)
local colNailRepair = Color(100, 170, 215, 240)
local colNailRepairText = Color(100, 170, 215, 240)
local colNailDamage = Color(100, 255, 100, 190)
-- 信息文字常规颜色
local colText = Color(240, 240, 240, 150)
-- 信息文字高亮颜色
local colText_High = Color(240, 240, 240, 255)
-- 放置者已死亡时的名字颜色
local colDead = Color(230, 80, 80, 95)
local nailHudData = {}

local function DrawNailHud()
	if not IsValid(nailHudData.parent) then return end

	local hudX = ScrW() * 0.5
	local hudY = ScrH() * 0.5 + 70
	local nhp = nailHudData.nhp
	local mnhp = nailHudData.mnhp
	local repairs = nailHudData.repairs
	local mrps = nailHudData.mrps
	local nailFraction = mnhp > 0 and math.Clamp(nhp / mnhp, 0, 1) or 0
	local damagePercent = math.floor((1 - nailFraction) * 100)
	local healthText = math.floor(nhp) .. " / " .. math.floor(mnhp) .. " "
	local damageText = "(" .. damagePercent .. "%)"

	colText.a = nailHudData.vis * 230
	colText_High.a = nailHudData.vis * 255
	colNailDamage.a = nailHudData.vis * 255
	colNail.a = nailHudData.vis * 255
	colNailRepair.a = nailHudData.vis * 255
	colNailRepairText.a = nailHudData.vis * 255

	local barWidth, barHeight = 150, 8
	local barX = hudX - barWidth * 0.5
	local barY = hudY
	local fillWidth = nailFraction * barWidth
	surface.SetDrawColor(0, 0, 0, 230 * nailHudData.vis)
	surface.DrawRect(barX, barY, barWidth, barHeight)
	if fillWidth > 0 then
		surface.SetDrawColor(colNail)
		surface.DrawRect(barX + 1, barY + 1, math.max(fillWidth - 2, 1), barHeight - 2)
	end

	-- 生命值显示在生命条上方（与血条重合，类似图层叠加）
	surface.SetFont("BarrierFont")
	local textY = barY + barHeight * 0.5
	local healthWidth = surface.GetTextSize(healthText)
	local damageWidth = surface.GetTextSize(damageText)
	local textWidth = healthWidth + damageWidth
	local textX = barX + barWidth * 0.5 - textWidth * 0.5
	draw.SimpleText(healthText, "BarrierFont", textX + healthWidth * 0.5, textY, colText_High, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(damageText, "BarrierFont", textX + healthWidth + damageWidth * 0.5, textY, colNailDamage, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	-- 维修条：与生命条并排显示（一个上一个下），维修值同样显示在维修条上方
	if mrps > 0 then
		local repairFraction = math.Clamp(repairs / mrps, 0, 1)
		local repairBarWidth, repairBarHeight = barWidth, barHeight
		local repairY = barY + barHeight + 20
		surface.SetDrawColor(0, 0, 0, 230 * nailHudData.vis)
		surface.DrawRect(barX, repairY, repairBarWidth, repairBarHeight)
		if repairFraction > 0 then
			surface.SetDrawColor(colNailRepair)
			surface.DrawRect(barX + 1, repairY + 1, math.max(repairFraction * (repairBarWidth - 2), 1), repairBarHeight - 2)
		end

		local repairText = math.floor(repairs) .. " / " .. math.floor(mrps)
		draw.SimpleText(repairText, "BarrierFont", barX + repairBarWidth * 0.5, repairY + repairBarHeight * 0.5, colNailRepairText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	if nailHudData.ownerText then
		local ownerColor = nailHudData.redname and colDead or colText
		ownerColor.a = nailHudData.vis * 230
		draw.SimpleText(nailHudData.ownerText, "BarrierFont", hudX, hudY + 50, ownerColor, TEXT_ALIGN_CENTER)
	end
	draw.SimpleText("按[Z/B]来穿过", "BarrierFont", hudX, hudY + 90, colText_High, TEXT_ALIGN_CENTER)
	nailHudData.parent = nil
end

hook.Add("HUDPaint", "ZS_PropNailInfo", DrawNailHud)

function ENT:DrawNailHealthVertical(pos, ang, nhp, mnhp, repairs, mrps, vis)
	if mnhp <= 0 then return end

	local barWid, barHei = 10, 44
	local barBottom = -4
	local mu = math.Clamp(nhp / mnhp, 0, 1)
	local fillHei = mu * barHei
	local repairFraction = mrps > 0 and math.Clamp(repairs / mrps, 0, 1) or 0
	local repairWid = 4
	local repairX = barWid * 0.5 + 2
	if nhp > 0 then
		fillHei = math.max(fillHei, 1)
	end

	local green = mu * 200
	colNail.r = 200 - green
	colNail.g = green
	colNail.a = 255 * vis
	colNailRepair.a = 255 * vis
	colNailText.a = 255 * vis
	colNailTextOutline.a = 230 * vis

	cam.Start3D2D(pos, ang, 0.1)
		surface.SetDrawColor(0, 0, 0, 230 * vis)
		surface.DrawRect(barWid * -0.5 - 1, barBottom - barHei - 1, barWid + 2, barHei + 2)
		if mrps > 0 then
			surface.DrawRect(repairX - 1, barBottom - barHei - 1, repairWid + 2, barHei + 2)
		end

		if fillHei > 0 then
			surface.SetDrawColor(colNail)
			surface.DrawRect(barWid * -0.5, barBottom - fillHei, barWid, fillHei)
		end
		if repairFraction > 0 then
			surface.SetDrawColor(colNailRepair)
			surface.DrawRect(repairX, barBottom - repairFraction * barHei, repairWid, repairFraction * barHei)
		end

		draw.SimpleTextOutlined(
			math.floor(nhp),
			"BarrierFont",
			barWid * -0.5 + barWid * 0.5,
			0,
			colNailText,
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP,
			1,
			colNailTextOutline
		)
	cam.End3D2D()
end

-- ==== DrawTranslucent - 绘制钉子模型、低血量火花特效与路障状态 3D2D 信息板 ====
function ENT:DrawTranslucent()
	local parent = self:GetParent()
	-- 父实体无效或本帧已绘制过信息板时只绘制模型
	if not parent:IsValid() or RealTime() == parent.LastNailInfoDraw then
		self:DrawModel()
		return
	end
	parent.LastNailInfoDraw = RealTime()
	nailHudData.parent = nil

	local drawinfo
	local myteam
	local pos = self:GetPos()
	local eyepos = EyePos()
	local target = GAMEMODE.TraceTargetNoPlayers
	if MySelf:IsValid() then
		myteam = MySelf:Team()
		if myteam == TEAM_HUMAN or myteam == TEAM_SPECTATOR then
			drawinfo = target == self:GetParent() or target == self
		elseif myteam == TEAM_UNDEAD then
			-- 亡灵：仅当准星瞄准该路障时显示
			drawinfo = target == self:GetParent() or target == self
		end
	end

	self:DrawModel()

	local nhp = self:GetNailHealth()
	local mnhp = self:GetMaxNailHealth()
	local repairs = self:GetRepairs()
	local mrps = self:GetMaxRepairs()

	-- 血量低于 35% 时周期性爆发黄绿色火花并播放音效（带随机冷却）
	if mnhp > 0 and nhp / mnhp < 0.35 and CurTime() > self.NextEmit then
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

	if not MySelf:IsValid() then return end

	local ang = EyeAngles()
	ang:RotateAroundAxis(ang:Up(), -90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	local nearest = parent:WorldSpaceCenter()
	local norm = nearest - eyepos
	norm:Normalize()
	local dot = EyeVector():Dot(norm)
	local dotsq = dot * dot
	local vis = math.Clamp((dotsq * dotsq) - 0.1, 0, 1)

	cam.IgnoreZ(true)
	self:DrawNailHealthVertical(nearest, ang, nhp, mnhp, repairs, mrps, vis)
	cam.IgnoreZ(false)

	if drawinfo and vis >= 0.01 then
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

			nailHudData.parent = parent
			nailHudData.nhp = nhp
			nailHudData.mnhp = mnhp
			nailHudData.repairs = repairs
			nailHudData.mrps = mrps
			nailHudData.vis = vis
			nailHudData.ownerText = displayowner and "建造者: " .. displayowner or nil
			nailHudData.redname = redname
		end
end
