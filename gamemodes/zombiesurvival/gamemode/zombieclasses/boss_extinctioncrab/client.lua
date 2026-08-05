-- ============================================================================
-- boss_extinctioncrab/client.lua - 灭绝蟹 (Extinction Crab) BOSS 客户端逻辑
-- 负责：击杀图标、暗红色调渲染、扑击时平滑限制视角转动
-- ============================================================================

include("shared.lua")

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fastheadcrab"
-- 图标颜色（深红色）
CLASS.IconColor = Color(100, 20, 0)

-- ==== PrePlayerDraw - 绘制前施加暗红色颜色调制 ====
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0.39, 0.08, 0)
end

-- ==== PostPlayerDraw - 绘制后恢复默认颜色调制 ====
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
end

-- ==== CreateMove - 扑击过程中平滑限制鼠标视角转动速度 ====
function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	-- 仅在武器处于扑击状态时生效
	if wep:IsValid() and wep.m_ViewAngles and wep.IsPouncing and wep:IsPouncing() then
		local maxdiff = FrameTime() * 15
		local mindiff = -maxdiff
		local originalangles = wep.m_ViewAngles
		local viewangles = cmd:GetViewAngles()

		-- 将当前视角偏航限制在原始角度的最大差范围内
		local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
		if diff > maxdiff or diff < mindiff then
			viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
		end

		wep.m_ViewAngles = viewangles

		cmd:SetViewAngles(viewangles)
	end
end
