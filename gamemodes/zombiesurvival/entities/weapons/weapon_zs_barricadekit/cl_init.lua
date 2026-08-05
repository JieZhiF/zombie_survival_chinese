-- ============================================================================
-- cl_init.lua - 搭建包（客户端）
-- 负责：武器栏位、HUD 木板计数显示、幽灵预览旋转控制
-- ============================================================================
INC_CLIENT()

SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables") -- 部署物武器栏
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES -- 武器选择组（部署物）
SWEP.DrawCrosshair = false -- 不绘制准星（使用幽灵预览）
SWEP.ViewModelFOV = 70 -- 第一人称镜头大小
SWEP.ViewModelFlip = false -- 不翻转第一人称模型

-- ==== DrawHUD - 绘制剩余木板数与准星点 ====
function SWEP:DrawHUD()
	local wid, hei = 384, 16
	local x, y = ScrW() - wid - 64, ScrH() - hei - 72
	local texty = y - 4 - draw.GetFontHeight("ZSHUDFont")

	-- 木板剩余数，耗尽时显示红色
	local charges = self:GetPrimaryAmmoCount()
	local chargetxt = "Boards: " .. charges
	if charges > 0 then
		draw.SimpleText(chargetxt, "ZSHUDFont", x + wid, texty, COLOR_GREEN, TEXT_ALIGN_RIGHT)
	else
		draw.SimpleText(chargetxt, "ZSHUDFont", x + wid, texty, COLOR_DARKRED, TEXT_ALIGN_RIGHT)
	end

	-- 仅当游戏准星开启时绘制准星点
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== Deploy - 部署时开始闲置动画计时 ====
function SWEP:Deploy()
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== GetViewModelPosition - 保持默认第一人称视角位置 ====
function SWEP:GetViewModelPosition(pos, ang)
	return pos, ang
end

-- ==== DrawWeaponSelection - 使用基类绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== PrimaryAttack - 客户端空实现（放置逻辑在服务器端） ====
function SWEP:PrimaryAttack()
end

-- ==== Think - 按住右键/R 时旋转幽灵预览朝向 ====
function SWEP:Think()
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

local nextclick = 0 -- 旋转音效冷却计时
local kityaw = CreateClientConVar("zs_barricadekityaw", 90, false, true) -- 预览朝向客户端参数
-- ==== RotateGhost - 旋转预览朝向（带音效与 0.3 秒冷却） ====
function SWEP:RotateGhost(amount)
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	RunConsoleCommand("zs_barricadekityaw", math.NormalizeAngle(kityaw:GetFloat() + amount))
end
