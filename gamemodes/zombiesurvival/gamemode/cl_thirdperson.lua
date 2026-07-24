-- ============================================================
-- 越肩第三人称摄像机系统
-- 负责越肩视角的启用/禁用、鼠标输入处理、与视角同步的移动校正，
-- 以及摄像机位置计算（含墙壁碰撞检测和辅助瞄准）
-- ============================================================

-- 存储越肩摄像机的当前角度
local otscameraangles = Angle()
-- 期望的摄像机偏侧方向（1=右肩，-1=左肩，0=第一人称）
local otsdesiredright = 0
-- 低血量/惊吓状态下的镜头摇晃方向向量
local staggerdir = VectorRand():GetNormalized()

-- 检查当前是否应使用越肩摄像机
function GM:UseOverTheShoulder()
	return self.OverTheShoulder and not engine.IsPlayingDemo()
end

-- 切换越肩摄像机模式（循环：第一人称 -> 右肩 -> 左肩 -> 第一人称）
function GM:ToggleOTSCamera()
	if self.OverTheShoulder then
		-- 当前在左肩模式，切换到第一人称
		if otsdesiredright == -1 then
			otsdesiredright = 0
			self.OverTheShoulder = false
			otscameraangles.roll = 0
			MySelf:SetEyeAngles(otscameraangles)
		else
			-- 当前在右肩模式，切换到左肩
			otsdesiredright = -1
		end
	else
		-- 当前为第一人称，启用越肩视角并设为右肩
		self.OverTheShoulder = true
		otsdesiredright = 1
		otscameraangles = MySelf:EyeAngles()
	end
end

-- 处理鼠标输入，更新越肩摄像机的俯仰角和偏航角
function GM:InputMouseApplyOTS(cmd, x, y, ang)
	otscameraangles.pitch = math.Clamp(math.NormalizeAngle(otscameraangles.pitch + y / 50), -89, 89)
	otscameraangles.yaw = math.NormalizeAngle(otscameraangles.yaw - x / 50)
	otscameraangles.roll = ang.roll
end

-- 玩家移动时调用，实现低血量抖动和移动方向校正
function GM:CreateMoveOTS(cmd)
	local maxhealth = MySelf:GetMaxHealth()
	-- 如果玩家有Palsy状态，阈值设为满血-1，否则为最大血量的25%
	local threshold = MySelf.HasPalsy and maxhealth - 1 or maxhealth * 0.25
	local health = MySelf:Health()
	local frightened = MySelf:GetStatus("frightened")
	local gunsway = MySelf.GunSway

	-- 低血量、受惊吓或有枪口晃动时（非僵尸逃跑模式），产生镜头摇晃
	if (health <= threshold or frightened or gunsway) and not GAMEMODE.ZombieEscape then
		local ft = FrameTime()

		-- 更新摇晃方向向量（随机漫步）
		staggerdir = (staggerdir + ft * 8 * VectorRand()):GetNormalized()

		local ang = otscameraangles
		local rate = MySelf:GetRateOfPalsy(ft, frightened, health, threshold, gunsway)

		-- 将摇晃应用到摄像机角度
		ang.pitch = math.NormalizeAngle(ang.pitch + staggerdir.z * rate)
		ang.yaw = math.NormalizeAngle(ang.yaw + staggerdir.x * rate)
		otscameraangles = ang
	end

	-- 计算摄像机视角与移动方向的偏角差
	local offsetyaw = otscameraangles.yaw - cmd:GetViewAngles().yaw

	-- 修正移动方向：根据摄像机朝向调整WASD移动
	local corrected = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
	local sign = cmd:GetForwardMove() < 0
	local length = corrected:Length()

	corrected = Angle(0, corrected:Angle().y - offsetyaw, 0):Forward()

	-- 无法完美解决，但这比默认好
	cmd:SetForwardMove(math.Clamp(corrected.x * length, sign and -length or 0, length))
	cmd:SetSideMove(corrected.y * length)
end

-- 墙壁碰撞检测用的Trace参数（包围盒检测）
local trace_wall = {mask = MASK_SOLID_BRUSHONLY, mins = Vector(-3, -3, -3), maxs = Vector(3, 3, 3)}
-- 准星瞄准检测用的Trace参数
local trace_crosshair = {mask = MASK_SHOT}
-- 最大偏角限制：摄像机与准星方向差值不超过70度
local maxdiff = 70

-- 当前玩家的队伍编号
local myteam = 0
-- Trace过滤器：忽略同队玩家
local function IgnoreTeam(ent)
	return not (ent:IsPlayer() and ent:Team() == myteam)
end

-- 核心摄像机视图计算函数
-- pl: 本地玩家, origin: 摄像机原点, angles: 视角角度, fov: 视野, znear/zfar: 裁剪平面
function GM:CalcViewOTS(pl, origin, angles, fov, znear, zfar)
	-- 计算摄像机位置：玩家身后28单位，偏侧12单位
	local camPos = origin - otscameraangles:Forward() * 28 + otsdesiredright * 12 * otscameraangles:Right()
	local eyepos = pl:EyePos()

	-- 墙壁碰撞检测：从玩家眼睛到摄像机位置做Hull Trace，防止穿墙
	trace_wall.start = eyepos
	trace_wall.endpos = camPos
	trace_wall.filter = pl
	camPos = util.TraceHull(trace_wall).HitPos

	-- 辅助瞄准：计算玩家模型应朝向的方向，使屏幕中心对准目标
	myteam = pl:Team()
	trace_crosshair.start = camPos
	trace_crosshair.endpos = camPos + otscameraangles:Forward() * 32768
	trace_crosshair.filter = IgnoreTeam
	local crosshair_tr = util.TraceLine(trace_crosshair)
	local crosshair_pos = crosshair_tr.HitPos
	local desired_angles = (crosshair_pos - eyepos):Angle()

	-- 限制最大偏角，避免角色过度扭曲
	desired_angles.yaw = math.ApproachAngle(otscameraangles.yaw, desired_angles.yaw, maxdiff)

	-- 设置玩家视角朝向目标点
	pl:SetEyeAngles(desired_angles)

	-- 更新最终的渲染位置和角度
	origin:Set(camPos)
	angles:Set(otscameraangles)

	-- 检测玩家视线到准星目标是否被阻挡
	trace_wall.start = eyepos
	trace_wall.endpos = crosshair_tr.HitPos
	GAMEMODE.LastOTSBlocked = util.TraceLine(trace_wall).Fraction <= 0.5
end
