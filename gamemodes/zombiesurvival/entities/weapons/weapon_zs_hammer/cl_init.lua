-- ============================================================================
-- weapon_zs_hammer/cl_init.lua - 锤子（客户端入口）
-- 负责：客户端栏位设置，以及 HUD 上钉子数量显示与准星绘制
-- ============================================================================

INC_CLIENT()
-- 武器栏位：维修工具栏
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRepairTools")
SWEP.SlotGroup = WEPSELECT_REPAIR_TOOL
-- 第一人称镜头视野大小
SWEP.ViewModelFOV = 75

-- ==== DrawHUD - 绘制钉子数量 HUD 与准星 ====
function SWEP:DrawHUD()
	-- 经典模式下不绘制
	if GetGlobalBool("classicmode") then return end

	local screenscale = BetterScreenScale()

	-- 在屏幕右下角显示剩余钉子数量，颜色随数量变化（有钉子为亮绿，无钉子为红色）
	surface.SetFont("ZSHUDFont")
	local nails = self:GetPrimaryAmmoCount()
	local text = translate.Format("nails_x", nails)
	local nTEXW, nTEXH = surface.GetTextSize(text)

	draw.SimpleTextBlurry(text, "ZSHUDFont", ScrW() - nTEXW * 0.75 - 32 * screenscale, ScrH() - nTEXH * 1.5, nails > 0 and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_CENTER)

	-- 游戏默认准星开启时才绘制锁定准星（吸附目标 + 颜色反馈 + 路障血量）
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawLockCrosshair()
end

-- ==== DrawLockCrosshair - 锁定准星（钉锤武器 xdebarricade 移植） ====
-- 效果：准星四角括号在近战射程内锁定目标时，平滑吸附到目标实体中心并收缩；
--       颜色反馈目标状态（绿=可维修、青=无需维修、黄=不可操作）；
--       对准被钉子固定的路障时，准星下方显示路障血量。
-- 纯客户端 HUD 视觉反馈，不参与服务器端攻击判定。
function SWEP:DrawLockCrosshair()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end

	local own = self:GetOwner()
	if not IsValid(own) or not own:Alive() or vgui.CursorVisible() then
		self.CrossMove = 0
		return
	end

	-- 首次调用时初始化平滑状态字段，避免 nil 参与运算
	self.CrossMove = self.CrossMove or 0
	self.PosFX = self.PosFX or -1
	self.PosFY = self.PosFY or -1

	-- 锁定探测距离与武器实际近战判定范围一致
	local range = self.MeleeRange or 96
	local ww, hh = ScrW() * 0.5, ScrH() * 0.5
	local col = Color(255, 255, 255)
	local healthtext = nil

	-- 射线探测：直线未命中时用 ±2 的 Hull 兜底（与钉锤武器一致）
	local tr = util.TraceLine({
		start = own:GetShootPos(),
		endpos = own:GetShootPos() + own:GetAimVector() * range,
		filter = own,
		mask = MASK_SHOT_HULL
	})
	if not tr.Hit then
		tr = util.TraceHull({
			start = own:GetShootPos(),
			endpos = own:GetShootPos() + own:GetAimVector() * range,
			filter = own,
			mins = Vector(-2, -2, -2),
			maxs = Vector(2, 2, 2),
			mask = MASK_SHOT_HULL
		})
	end

	-- 锁定目标：把实体中心投影到屏幕坐标，作为准星吸附点
	local ent = tr.Entity
	if ent:IsValid() and not ent:IsWorld() then
		ww, hh = ent:WorldSpaceCenter():ToScreen().x, ent:WorldSpaceCenter():ToScreen().y

		if ent:IsNailed() then
			local hp, mp = ent:GetBarricadeHealth(), ent:GetMaxBarricadeHealth()
			if hp > 0 and hp < mp and ent:GetBarricadeRepairs() > 0.01 then
				col = Color(0, 255, 0) -- 可维修
			else
				col = Color(0, 255, 255) -- 无需维修（满血或无修理次数）
			end
			if mp > 0 then
				healthtext = math.ceil(hp) .. " / " .. math.ceil(mp)
			end
		else
			col = Color(255, 255, 0) -- 无法维修的普通物体
		end
	end

	-- 目标中心出屏时准星钳制在屏幕边缘
	local si = self.CrossMove
	ww = math.Clamp(ww, si * 2, ScrW() - si * 2)
	hh = math.Clamp(hh, si * 2, ScrH() - si * 2)

	-- 平滑吸附目标位置
	self.PosFX = self.PosFX == -1 and ww or Lerp(math.min(1, FrameTime() * 20), self.PosFX, ww)
	self.PosFY = self.PosFY == -1 and hh or Lerp(math.min(1, FrameTime() * 20), self.PosFY, hh)

	-- 锁定时收缩（24），无目标时张开（48）
	local locked = ent:IsValid() and not ent:IsWorld()
	self.CrossMove = Lerp(math.min(1, FrameTime() * 20), self.CrossMove, locked and 24 or 48)
	si = math.Round(self.CrossMove)

	ww, hh = math.Round(self.PosFX), math.Round(self.PosFY)

	-- 四角括号：黑色描边 + 彩色内芯
	local function NiceLine(x, y, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x, y, w, h)
		surface.SetDrawColor(col)
		draw.RoundedBox(0, x + 1, y + 1, w - 2, h - 2, col)
	end

	NiceLine(ww - si, hh - si, 3, si / 2 + 3) NiceLine(ww - si, hh - si, si / 2 + 3, 3)
	NiceLine(ww + si / 2, hh - si, si / 2 + 3, 3) NiceLine(ww + si, hh - si, 3, si / 2 + 3)
	NiceLine(ww - si, hh + si / 2, 3, si / 2 + 3) NiceLine(ww - si, hh + si, si / 2 + 3, 3)
	NiceLine(ww + si, hh + si / 2, 3, si / 2 + 3) NiceLine(ww + si / 2, hh + si, si / 2 + 3, 3)

	if healthtext then
		draw.SimpleTextOutlined(healthtext, "ZSHUDFont", ww, hh + si * 3.2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
	end
end
