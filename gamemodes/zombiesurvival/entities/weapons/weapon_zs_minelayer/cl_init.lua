-- ============================================================================
-- weapon_zs_minelayer/cl_init.lua - 冲击地雷发射器（客户端定义）
-- 负责：武器栏显示设置、地雷数量 HUD 与准星绘制
-- ============================================================================
-- 客户端专用（GMod 武器文件的标准客户端入口标记）
INC_CLIENT()

-- 第一人称模型不翻转
SWEP.ViewModelFlip = false
-- 武器槽位（可部署物品槽）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
-- 槽位分组：可部署物品
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
-- 武器栏 3D 预览：位置 / 角度 / 缩放 / 骨骼
SWEP.HUD3DPos = Vector(4, 0, 15)
SWEP.HUD3DAng = Angle(0, 180, 180)
SWEP.HUD3DScale = 0.04
SWEP.HUD3DBone = "base"

-- ==== DrawHUD - 绘制 HUD（开启准星设置时画准星点） ====
-- 注意：此定义随后被下方第二个 DrawHUD 覆盖
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() == 1 then
		self:DrawCrosshairDot()
	end
end

-- ==== DrawHUD - 绘制 HUD（最终生效版本：地雷计数 + 2D HUD + 准星） ====
function SWEP:DrawHUD()
	-- HUD 区域尺寸与位置（右下角）
	local wid, hei = 384, 16
	local x, y = ScrW() - wid - 128, ScrH() - hei - 128
	local texty = y - 4 - draw.GetFontHeight("ZSHUDFont")

	-- 统计场上地雷数量（带 1 秒缓存，避免每帧遍历实体）
	local c = 0
	if not self.NextMineCheckTime or self.NextMineCheckTime < CurTime() then
		for _, ent in pairs(ents.FindByClass("projectile_impactmine")) do
			if (CLIENT or ent.CreateTime + 300 > CurTime()) and ent:GetOwner() == self:GetOwner() then
				c = c + 1
			end
		end
		self.CachedMines = c
		self.NextMineCheckTime = CurTime() + 1
	else
		-- 缓存未过期时直接使用缓存值
		c = self.CachedMines
	end

	-- 绘制地雷计数文本（仅当还有弹药时显示）
	local charges = self:GetPrimaryAmmoCount()
	local chargetxt = "Mines: " .. c .. " / " .. self.MaxMines
	if charges > 0 then
		draw.SimpleText(chargetxt, "ZSHUDFont", x + wid, texty, COLOR_CYAN, TEXT_ALIGN_RIGHT)
	end

	-- 游戏模式允许时绘制 2D 武器 HUD（弹药图标等）
	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:Draw2DHUD()
	end

	-- 开启准星设置时绘制准星点
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end
