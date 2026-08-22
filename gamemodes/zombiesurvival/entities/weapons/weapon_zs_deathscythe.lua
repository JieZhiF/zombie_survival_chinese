-- ============================================================================
-- weapon_zs_deathscythe.lua - 死神 BOSS 的改版镰刀
-- 左键：镰刀连击；右键：召唤2个强化骷髅；R键：锁定单人传送
-- 重构：传送状态使用服务器计时器保证必定结束/解冻，不再依赖 SWEP:Think
-- ============================================================================
AddCSLuaFile()

SWEP.Base = "weapon_zs_scythe"

SWEP.PrintName = "" .. translate.Get("weapon_zs_deathscythe")
SWEP.Description = "" .. translate.Get("weapon_zs_deathscythe_description")
SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 35
SWEP.MeleeRange = 90
SWEP.MeleeSize = 4
SWEP.MeleeKnockBack = 0
SWEP.Primary.Delay = 1.1

SWEP.TeleportRange = 1500
SWEP.TeleportDuration = 15
SWEP.TeleportPullRadius = 45
SWEP.TeleportCooldown = 15
SWEP.SummonDelay = 20
SWEP.SummonCount = 2

-- 传送状态需要显式注册 DT。
	-- 注意不能占用 0 号槽，因为基类 weapon_zs_basemelee 已用它同步 PowerCombo。
	function SWEP:SetupDataTables()
		self.BaseClass.SetupDataTables(self)
		self:NetworkVar("Entity", 1, "TeleportTarget")
		self:NetworkVar("Float", 2, "TeleportEndTime")
		self:NetworkVar("Float", 3, "TeleportStartTime")
	end

local math_random = math.random
local CurTime = CurTime

-- 是否正在传送
function SWEP:IsTeleporting()
	return self:GetTeleportEndTime() > CurTime()
end

-- R键：传送 / 再按取消
function SWEP:Reload()
	local owner = self:GetOwner()
	if not owner:IsValid() then
		return
	end

	if SERVER and self:IsTeleporting() then
		self:StopTeleport("cancel")
		return
	end

	if CLIENT then
		return
	end

	if self:IsTeleporting() then
		return
	end

	if CurTime() < (self.NextTeleport or 0) then
		return
	end

	local victim = self:FindTeleportTarget()
	if not victim then
		return
	end

	self:StartTeleport(victim)
end

-- Think 只做安全兜底，正常结束由服务器计时器负责
function SWEP:Think()
	self.BaseClass.Think(self)

	if not SERVER or not self:IsTeleporting() then
		return
	end

	local owner = self:GetOwner()
	local victim = self:GetTeleportTarget()

	if not (owner:IsValid() and victim:IsValid() and victim:IsValidLivingHuman()) then
		self:StopTeleport("invalid")
	end
end

function SWEP:Holster()
	if SERVER then
		self:StopTeleport("holster")
	end
	return self.BaseClass.Holster(self)
end

function SWEP:OnRemove()
	if SERVER then
		self:StopTeleport("remove")
	elseif self.BaseClass.OnRemove then
		self.BaseClass.OnRemove(self)
	end
end

if SERVER then
	-- 开始传送：冻结双方、同步 HUD 数据，并用计时器保证结束
	function SWEP:StartTeleport(victim)
		local owner = self:GetOwner()
		if not (owner:IsValid() and victim:IsValid() and victim:IsValidLivingHuman()) then
			return false
		end

		if self:IsTeleporting() then
			self:StopTeleport("restart")
		end

		local starttime = CurTime()
		local endtime = starttime + self.TeleportDuration

		self.NextTeleport = endtime + self.TeleportCooldown
		self.TeleportOwner = owner
		self.TeleportVictim = victim

		self:SetTeleportTarget(victim)
		self:SetTeleportEndTime(endtime)
		self:SetTeleportStartTime(starttime)

		owner:Freeze(true)
		victim:Freeze(true)

		-- 双方 HUD 进度条数据
		owner:SetNWBool("DeathTeleportIsOwner", true)
		victim:SetNWBool("DeathTeleportIsOwner", false)
		owner:SetNWFloat("DeathTeleportStartTime", starttime)
		owner:SetNWFloat("DeathTeleportEndTime", endtime)
		victim:SetNWFloat("DeathTeleportStartTime", starttime)
		victim:SetNWFloat("DeathTeleportEndTime", endtime)
		
		-- 设置死神信息供客户端绘制方向指示
		victim:SetNWEntity("DeathScytheOwner", owner)

		-- 服务器计时器：到点必定完成并解冻
		self.TeleportTimerId = "deathscythe_teleport_" .. self:EntIndex() .. "_" .. tostring(self)
		timer.Create(self.TeleportTimerId, self.TeleportDuration, 1, function()
			if self:IsValid() then
				self:FinishTeleport()
			end
		end)

		owner:EmitSound("hl1/ambience/particle_suck1.wav", 75, 120)
		return true
	end

	-- 完成传送：传送目标后再统一收尾
	function SWEP:FinishTeleport()
		-- 计时器到点即视为完成；不要用 IsTeleporting() 判断，
		-- 因为 timer 触发时 endtime 可能刚好已经 <= CurTime，IsTeleporting() 会返回 false。
		if not self.TeleportVictim and not (self:GetTeleportTarget() and self:GetTeleportTarget():IsValid()) then
			return
		end

		local owner = self:GetOwner()
		if not (owner and owner:IsValid()) then
			owner = self.TeleportOwner
		end
		local victim = self:GetTeleportTarget()
		if not (victim and victim:IsValid()) then
			victim = self.TeleportVictim
		end

		if owner and owner:IsValid() and victim and victim:IsValid() and victim:IsValidLivingHuman() then
			self:TeleportTargetToOwner(owner, victim)
			
			-- 播放传送完成音效
			owner:EmitSound("hl1/fvox/activated.wav", 75, 100)
			victim:EmitSound("hl1/fvox/panic01.wav", 75, 120)
		end

		self:StopTeleport("finish")
	end

	-- 统一收尾：移除计时器、解除双方冻结、清空状态
	function SWEP:StopTeleport(reason)
		if self.TeleportTimerId then
			if timer.Exists(self.TeleportTimerId) then
				timer.Remove(self.TeleportTimerId)
			end
			self.TeleportTimerId = nil
		end

		local victim = self:GetTeleportTarget()
		if not (victim and victim:IsValid()) then
			victim = self.TeleportVictim
		end

		if victim and victim:IsValid() then
			victim:Freeze(false)
			victim:SetNWBool("DeathTeleportIsOwner", false)
			victim:SetNWFloat("DeathTeleportStartTime", 0)
			victim:SetNWFloat("DeathTeleportEndTime", 0)
			victim:SetNWEntity("DeathScytheOwner", NULL)
		end

		local owner = self:GetOwner()
		if not (owner and owner:IsValid()) then
			owner = self.TeleportOwner
		end

		if owner and owner:IsValid() then
			owner:Freeze(false)
			owner:SetNWBool("DeathTeleportIsOwner", false)
			owner:SetNWFloat("DeathTeleportStartTime", 0)
			owner:SetNWFloat("DeathTeleportEndTime", 0)
		end

		self.TeleportOwner = nil
		self.TeleportVictim = nil
		self:SetTeleportTarget(NULL)
		self:SetTeleportEndTime(0)
		self:SetTeleportStartTime(0)
	end

	-- 找准星方向上的一个可传送目标
	function SWEP:FindTeleportTarget()
		local owner = self:GetOwner()
		local ent = owner:CompensatedMeleeTrace(self.TeleportRange, self.MeleeSize).Entity

		if ent:IsValid() and ent:IsValidLivingHuman() then
			return ent
		end
	end

	-- 把目标传送到自己周围（严格空地检测，避免卡住）
	function SWEP:TeleportTargetToOwner(owner, victim)
		if not (owner:IsValid() and victim:IsValid()) then
			return
		end

		local bosspos = owner:GetPos()
		local mins = victim:OBBMins()
		local maxs = victim:OBBMaxs()
		local height = maxs.z - mins.z

		-- 过滤所有玩家，避免传送到别人身上
		local filter = {owner, victim}
		for _, pl in ipairs(player.GetAll()) do
			if pl ~= owner and pl ~= victim then
				table.insert(filter, pl)
			end
		end

		local function FindSafeSpot(centerpos, radius)
			for r = 0, 2 do
				local curradius = radius * (1 + r * 0.6)
				for i = 1, 12 do
					local ang = (i - 1) * 30 + math_random() * 8
					local pos = centerpos + Angle(0, ang, 0):Forward() * curradius

					-- 从上往下找地面；StartSolid 说明候选点本身卡在障碍里，直接跳过
					local tr = util.TraceHull({
						start = pos + Vector(0, 0, 96),
						endpos = pos + Vector(0, 0, -128),
						mins = mins,
						maxs = maxs,
						filter = filter,
						mask = MASK_PLAYERSOLID,
					})

					if tr.Hit and not tr.StartSolid and not tr.HitSky and not tr.HitNoDraw then
						local groundpos = tr.HitPos + Vector(0, 0, 2)

						-- 检查头顶到站立空间是否通畅（没被路障/天花板挡住）
						local up = util.TraceHull({
							start = groundpos,
							endpos = groundpos + Vector(0, 0, height + 4),
							mins = mins,
							maxs = maxs,
							filter = filter,
							mask = MASK_PLAYERSOLID,
						})

						if not up.Hit and not up.StartSolid then
							return groundpos
						end
					end
				end
			end
			return nil
		end

		local spot = FindSafeSpot(bosspos, self.TeleportPullRadius)
		-- 周围找不到，就在 boss 面朝方向前方再找
		if not spot then
			spot = FindSafeSpot(bosspos + owner:GetAimVector() * 80, self.TeleportPullRadius)
		end

		if spot then
			victim:SetPos(spot)
			victim:SetVelocity(Vector(0, 0, 0))
		else
			victim:SetPos(bosspos + Vector(0, 0, 72))
			victim:SetVelocity(Vector(0, 0, 0))
		end

		-- 传送后保险：0.3 秒后若仍卡在固体里，再找一次空位
		timer.Simple(0.3, function()
			if not (self:IsValid() and victim:IsValid()) then return end

			local stuck = util.TraceHull({
				start = victim:GetPos(),
				endpos = victim:GetPos() + Vector(0, 0, 1),
				mins = mins,
				maxs = maxs,
				filter = victim,
				mask = MASK_PLAYERSOLID,
			})

			if stuck.StartSolid then
				local respot = FindSafeSpot(bosspos, self.TeleportPullRadius)
				if respot then
					victim:SetPos(respot)
					victim:SetVelocity(Vector(0, 0, 0))
				end
			end
		end)
	end
end

-- 右键：召唤2个强化骷髅
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	if not owner:IsValid() then
		return
	end
	if CurTime() < self:GetNextSecondaryFire() then
		return
	end
	self:SetNextSecondaryFire(CurTime() + self.SummonDelay)

	if CLIENT then
		return
	end

	owner:EmitSound("npc/zombie/zombie_voice_idle" .. math_random(14) .. ".wav", 75, 60)
	owner.LastRangedAttack = CurTime()

	local shootpos = owner:GetShootPos()
	local aimvec = owner:GetAimVector()
	local right = owner:EyeAngles():Right()

	for i = 1, self.SummonCount do
		local spread = i == 1 and -0.15 or 0.15
		self:ThrowSkeletonNest(owner, shootpos, aimvec + right * spread)
	end
end

function SWEP:ThrowSkeletonNest(owner, shootpos, veldir)
	if not SERVER then
		return
	end

	local ent = ents.Create("prop_thrownskeleton")
	if not ent:IsValid() then
		return
	end

	ent:SetPos(shootpos)
	ent:SetAngles(AngleRand())
	ent:SetOwner(owner)
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetVelocityInstantaneous(veldir:GetNormalized() * 700)
		phys:AddAngleVelocity(VectorRand() * math.Rand(200, 300))
		ent:SetPhysicsAttacker(owner)
	end
end

if not CLIENT then
	return
end

-- 传送时隐藏武器模型：第一人称直接跳过视图模型绘制（VElements 随之隐藏）
function SWEP:PreDrawViewModel(vm)
	if self:IsTeleporting() then
		return true
	end

	if self.ShowViewModel == false then
		render.SetBlend(0)
	end
end

-- 传送时隐藏武器模型：第三人称跳过世界模型与 WElements 绘制
function SWEP:DrawWorldModel()
	if self:IsTeleporting() then
		return
	end

	self.BaseClass.DrawWorldModel(self)
end

-- 移除继承的R键格挡HUD
function SWEP:DrawBlockHUD() end

function SWEP:DrawMeleeHud() end

function SWEP:CooldownRingBinding2()
	return 0
end

-- 传送进度条绘制辅助
local function DrawTeleportProgressBar(progress, color, text)
	local w = ScrW() * 0.3
	local h = 20
	local x = ScrW() * 0.5 - w * 0.5
	local y = ScrH() * 0.35

	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(x - 2, y - 2, w + 4, h + 4)

	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	surface.DrawRect(x, y, w * progress, h)

	surface.SetDrawColor(255, 255, 255, 60)
	surface.DrawOutlinedRect(x - 2, y - 2, w + 4, h + 4)

	if text then
		draw.SimpleText(
			text,
			"DefaultFont",
			ScrW() * 0.5,
			y - 8,
			Color(255, 255, 255, 235),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_BOTTOM
		)
	end
end

-- 死神本人与被传送玩家的进度条（双方都有）
hook.Add("HUDPaint", "DeathTeleportProgress", function()
	if not MySelf or not MySelf:IsValid() then
		return
	end

	local endtime = MySelf:GetNWFloat("DeathTeleportEndTime", 0)
	if endtime <= CurTime() then
		return
	end

	local starttime = MySelf:GetNWFloat("DeathTeleportStartTime", 0)
	local progress = math.Clamp((CurTime() - starttime) / math.max(endtime - starttime, 0.001), 0, 1)

	if MySelf:GetNWBool("DeathTeleportIsOwner", false) then
		DrawTeleportProgressBar(progress, Color(120, 30, 160, 220), "传送中 - 按 R 取消")
	else
		DrawTeleportProgressBar(progress, Color(120, 20, 20, 220), "被死神传送了！")
	end
end)

-- 为被传送的玩家绘制死神方向指示
hook.Add("HUDPaint", "DeathTeleportDirectionIndicator", function()
	if not MySelf or not MySelf:IsValid() then
		return
	end

	-- 检查当前是否是被传送状态
	local endtime = MySelf:GetNWFloat("DeathTeleportEndTime", 0)
	if endtime <= CurTime() then
		return
	end

	-- 只在被传送时显示方向指示
	if not MySelf:GetNWBool("DeathTeleportIsOwner", false) then
		local deathScythePlayer = MySelf:GetNWEntity("DeathScytheOwner", NULL)
		
		if deathScythePlayer and deathScythePlayer:IsValid() then
			-- 获取死神的位置
			local deathPos = deathScythePlayer:EyePos()
			local myPos = MySelf:EyePos()
			
			-- 计算屏幕位置
			local deathScreenPos = deathPos:ToScreen()
			local myScreenX = ScrW() * 0.5
			local myScreenY = ScrH() * 0.5
			
			-- 如果死神不在屏幕内，绘制方向指示
			if deathScreenPos.x < 0 or deathScreenPos.x > ScrW() or deathScreenPos.y < 0 or deathScreenPos.y > ScrH() then
				-- 计算方向角度
				local angle = math.atan2(deathPos.y - myPos.y, deathPos.x - myPos.x)
				
				-- 在屏幕边缘绘制指示箭头
				local arrowDistance = 100
				local arrowX = myScreenX + math.cos(angle) * arrowDistance
				local arrowY = myScreenY + math.sin(angle) * arrowDistance
				
			-- 绘制背景圆圈
			surface.SetDrawColor(0, 0, 0, 180)
			surface.DrawCircle(arrowX, arrowY, 30, 0, 0, 0)

			-- 绘制外圈
			surface.SetDrawColor(255, 50, 50, 255)
			surface.DrawCircle(arrowX, arrowY, 30, 255, 50, 50)
				
				-- 绘制箭头
				local arrowSize = 15
				local arrowAngle1 = angle + math.pi * 0.8
				local arrowAngle2 = angle - math.pi * 0.8
				
				local arrowX1 = arrowX + math.cos(arrowAngle1) * arrowSize
				local arrowY1 = arrowY + math.sin(arrowAngle1) * arrowSize
				local arrowX2 = arrowX + math.cos(arrowAngle2) * arrowSize
				local arrowY2 = arrowY + math.sin(arrowAngle2) * arrowSize
				
				surface.SetDrawColor(255, 50, 50, 255)
				surface.DrawLine(arrowX, arrowY, arrowX1, arrowY1)
				surface.DrawLine(arrowX, arrowY, arrowX2, arrowY2)
				surface.DrawLine(arrowX1, arrowY1, arrowX2, arrowY2)
				
				-- 绘制死神图标
				draw.SimpleText("☠", "DermaLarge", arrowX, arrowY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				-- 如果死神在屏幕内，绘制距离指示
				local distance = myPos:Distance(deathPos)
				local screenPos = deathPos:ToScreen()
				
			-- 绘制背景圆圈
			surface.SetDrawColor(0, 0, 0, 180)
			surface.DrawCircle(screenPos.x, screenPos.y, 25, 0, 0, 0)

			-- 绘制外圈
			surface.SetDrawColor(255, 50, 50, 255)
			surface.DrawCircle(screenPos.x, screenPos.y, 25, 255, 50, 50)
				
				-- 绘制距离文字
				draw.SimpleText(math.Round(distance) .. "m", "DefaultFont", screenPos.x, screenPos.y + 35, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end
	end
end)