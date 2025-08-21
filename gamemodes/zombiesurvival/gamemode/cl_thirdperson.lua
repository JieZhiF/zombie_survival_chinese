
-- 本文件负责管理游戏中的越肩（第三人称）摄像机系统。它包括摄像机的启用/禁用、鼠标输入处理、与摄像机视角同步的玩家移动调整，以及计算摄像机的最终位置和朝向，同时处理墙壁碰撞和辅助瞄准。

-- GM.OverTheShoulder 一个布尔值，用于标记越肩摄像机模式是否已激活。
-- GM:UseOverTheShoulder 检查当前是否应使用越肩摄像机。
-- GM:ToggleOTSCamera 切换越肩摄像机模式的开关，可在左肩、右肩和第一人称之间循环。
-- GM:InputMouseApplyOTS 处理鼠标输入，以更新越肩摄像机的俯仰角和偏航角。
-- GM:CreateMoveOTS 在玩家移动时被调用，用于实现低血量或特定状态下的镜头摇晃效果，并根据摄像机朝向校正玩家的移动方向。
-- GM:CalcViewOTS 核心的摄像机视图计算函数。它确定摄像机在世界中的最终位置（避免穿墙），计算玩家模型的精确瞄准方向以对准屏幕中心，并设置最终的渲染视角。GM.OverTheShoulder = false

local otscameraangles = Angle()
local otsdesiredright = 0
local staggerdir = VectorRand():GetNormalized()

function GM:UseOverTheShoulder()
	return self.OverTheShoulder and not engine.IsPlayingDemo()
end

function GM:ToggleOTSCamera()
	if self.OverTheShoulder then
		if otsdesiredright == -1 then
			otsdesiredright = 0
			self.OverTheShoulder = false
			otscameraangles.roll = 0
			MySelf:SetEyeAngles(otscameraangles)
		else
			otsdesiredright = -1
		end
	else
		self.OverTheShoulder = true
		otsdesiredright = 1
		otscameraangles = MySelf:EyeAngles()
	end
end

function GM:InputMouseApplyOTS(cmd, x, y, ang)
	otscameraangles.pitch = math.Clamp(math.NormalizeAngle(otscameraangles.pitch + y / 50), -89, 89)
	otscameraangles.yaw = math.NormalizeAngle(otscameraangles.yaw - x / 50)
	otscameraangles.roll = ang.roll
end

function GM:CreateMoveOTS(cmd)
	local maxhealth = MySelf:GetMaxHealth()
	local threshold = MySelf.HasPalsy and maxhealth - 1 or maxhealth * 0.25
	local health = MySelf:Health()
	local frightened = MySelf:GetStatus("frightened")
	local gunsway = MySelf.GunSway

	if (health <= threshold or frightened or gunsway) and not GAMEMODE.ZombieEscape then
		local ft = FrameTime()

		staggerdir = (staggerdir + ft * 8 * VectorRand()):GetNormalized()

		local ang = otscameraangles
		local rate = MySelf:GetRateOfPalsy(ft, frightened, health, threshold, gunsway)

		ang.pitch = math.NormalizeAngle(ang.pitch + staggerdir.z * rate)
		ang.yaw = math.NormalizeAngle(ang.yaw + staggerdir.x * rate)
		otscameraangles = ang
	end

	local offsetyaw = otscameraangles.yaw - cmd:GetViewAngles().yaw --ply:EyeAngles( ).y

	local corrected = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
	local sign = cmd:GetForwardMove() < 0
	local length = corrected:Length()

	corrected = Angle(0, corrected:Angle().y - offsetyaw, 0):Forward()

	-- Not possible to get a perfect solution, but this is better.
	cmd:SetForwardMove(math.Clamp(corrected.x * length, sign and -length or 0, length))
	cmd:SetSideMove(corrected.y * length)
end

local trace_wall = {mask = MASK_SOLID_BRUSHONLY, mins = Vector(-3, -3, -3), maxs = Vector(3, 3, 3)}
local trace_crosshair = {mask = MASK_SHOT--[[, mins = Vector(-1, -1, -1), maxs = Vector(1, 1, 1)]]}
local maxdiff = 70

local myteam = 0
local function IgnoreTeam(ent)
	return not (ent:IsPlayer() and ent:Team() == myteam)
end
function GM:CalcViewOTS(pl, origin, angles, fov, znear, zfar)
	local camPos = origin - otscameraangles:Forward() * 28 + otsdesiredright * 12 * otscameraangles:Right() -- - otscameraangles:Up() * 2
	local eyepos = pl:EyePos()

	trace_wall.start = eyepos
	trace_wall.endpos = camPos
	trace_wall.filter = pl
	camPos = util.TraceHull(trace_wall).HitPos

	myteam = pl:Team()
	trace_crosshair.start = camPos
	trace_crosshair.endpos = camPos + otscameraangles:Forward() * 32768
	trace_crosshair.filter = IgnoreTeam
	local crosshair_tr = util.TraceLine(trace_crosshair)
	local crosshair_pos = crosshair_tr.HitPos
	local desired_angles = (crosshair_pos - eyepos):Angle()

	-- Don't face away more than a certain amount of degrees
	desired_angles.yaw = math.ApproachAngle(otscameraangles.yaw, desired_angles.yaw, maxdiff)

	pl:SetEyeAngles(desired_angles)

	origin:Set(camPos)
	angles:Set(otscameraangles)

	-- Let gamemode know if our LOS to crosshair target is blocked.
	trace_wall.start = eyepos
	trace_wall.endpos = crosshair_tr.HitPos
	GAMEMODE.LastOTSBlocked = util.TraceLine(trace_wall).Fraction <= 0.5
end
