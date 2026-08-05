-- ============================================================================
-- cl_init.lua - 点燃者武器客户端脚本
-- 负责：设置武器栏位与 HUD 3D 预览，定义 SCK 自定义模型元素（VElements/WElements），
--       绘制 HUD 显示已放置/上限地雷数量
-- ============================================================================
INC_CLIENT()
-- 武器栏位（爆炸物槽）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotExplosives")
-- 武器选择组（爆炸物）
SWEP.SlotGroup = WEPSELECT_EXPLOSIVE
-- 武器类型（爆炸物）
SWEP.WeaponType = "explosive"
-- 不翻转第一人称视图模型
SWEP.ViewModelFlip = false

-- 隐藏默认模型（改用下方自定义 SCK 模型元素拼装外观）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- HUD 3D 预览的显示位置/角度/缩放/骨骼
SWEP.HUD3DPos = Vector(4, 0, 15)
SWEP.HUD3DAng = Angle(0, 180, 180)
SWEP.HUD3DScale = 0.04
SWEP.HUD3DBone = "base"

-- 第一人称视图模型的 SCK 自定义部件（以霰弹枪为基座，拼接废料零件）
SWEP.VElements = {
	-- 部件 base++++：炮管装饰旋转器 1
	["base++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "base", rel = "base", pos = Vector(16, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base+++：炮管装饰旋转器 2
	["base+++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "base", rel = "base", pos = Vector(22, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base++++++：燃料罐（丙烷罐模型，门板材质）
	["base++++++"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "base", rel = "base", pos = Vector(33.765, 9, -4.676), angle = Angle(0, -90, 90), size = Vector(0.5, 0.5, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
	-- 部件 base：武器主体（霰弹枪模型）
	["base"] = { type = "Model", model = "models/weapons/c_shotgun.mdl", bone = "base", rel = "", pos = Vector(8, -4.5, -21), angle = Angle(90, -90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base+++++++：顶部装饰易拉罐
	["base+++++++"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "base", rel = "base", pos = Vector(30.649, 8.5, -9.87), angle = Angle(0, 0, 0), size = Vector(0.4, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
	-- 部件 base+：炮管装饰旋转器 3
	["base+"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "base", rel = "base", pos = Vector(36, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base++：炮口装饰旋转器 4
	["base++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "base", rel = "base", pos = Vector(42, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- 第三人称世界模型的 SCK 自定义部件（他人视角可见的拼装外观）
SWEP.WElements = {
	-- 部件 base+++++：世界模型主体（霰弹枪模型）
	["base+++++"] = { type = "Model", model = "models/weapons/w_shotgun.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(34.805, 9, -9), angle = Angle(-7, 180, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base+++：炮管装饰旋转器 2（世界模型）
	["base+++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(22, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base++++++：燃料罐（世界模型）
	["base++++++"] = { type = "Model", model = "models/props_junk/propane_tank001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(33.765, 9, -4.676), angle = Angle(0, -90, 90), size = Vector(0.5, 0.5, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
	-- 部件 base++：炮口装饰旋转器 4（世界模型）
	["base++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(42, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base：手持易拉罐装饰（颜色 Alpha 为 0，实际不可见，仅保留结构）
	["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-16.5, 8.5, -11), angle = Angle(0, 0, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 0), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base+++++++：顶部装饰易拉罐（世界模型）
	["base+++++++"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(30.649, 8.5, -9.87), angle = Angle(0, 0, 0), size = Vector(0.4, 0.4, 0.4), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
	-- 部件 base+：炮管装饰旋转器 3（世界模型）
	["base+"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(36, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	-- 部件 base++++：炮管装饰旋转器 1（世界模型）
	["base++++"] = { type = "Model", model = "models/props_lab/rotato.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(16, 9, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

-- ==== DrawHUD - 绘制地雷数量 HUD ====
-- 屏幕右下角显示"已放置 / 上限"地雷数；每 1 秒刷新一次计数缓存，避免每帧全图扫描
function SWEP:DrawHUD()
	local wid, hei = 384, 16
	local x, y = ScrW() - wid - 128, ScrH() - hei - 128
	local texty = y - 4 - draw.GetFontHeight("ZSHUDFont")

	-- 统计场内属于本玩家的存活地雷数（带 1 秒缓存）
	local c = 0
	if not self.NextMineCheckTime or self.NextMineCheckTime < CurTime() then
		for _, ent in pairs(ents.FindByClass("projectile_impactmine_kin")) do
			if (CLIENT or ent.CreateTime + 300 > CurTime()) and ent:GetOwner() == self:GetOwner() then
				c = c + 1
			end
		end
		self.CachedMines = c
		self.NextMineCheckTime = CurTime() + 1
	else
		-- 缓存有效期内直接复用上次统计结果
		c = self.CachedMines
	end

	-- 剩余弹药 > 0 时显示地雷计数文本
	local charges = self:GetPrimaryAmmoCount()
	local chargetxt = "Mines: " .. c .. " / " .. self.MaxMines
	if charges > 0 then
		draw.SimpleText(chargetxt, "ZSHUDFont", x + wid, texty, COLOR_CYAN, TEXT_ALIGN_RIGHT)
	end

	-- 绘制武器自身的 2D HUD
	if GAMEMODE:ShouldDraw2DWeaponHUD() then
		self:Draw2DHUD()
	end

	-- 准星 ConVar 开启时绘制中心准星点
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end
