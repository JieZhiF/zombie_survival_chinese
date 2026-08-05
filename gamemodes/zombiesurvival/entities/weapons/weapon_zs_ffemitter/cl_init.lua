-- ============================================================================
-- weapon_zs_ffemitter/cl_init.lua - 火焰发射器建造装置（客户端逻辑）
-- 负责：准星、武器栏位与放置幽灵的旋转控制
-- ============================================================================
INC_CLIENT()

-- 不绘制默认准星
SWEP.DrawCrosshair = false

-- 武器选择栏位（可部署类）与栏内位置
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
SWEP.SlotPos = 0

-- ==== DrawHUD - 绘制准星：开启准星 ConVar 时绘制点状准星 ====
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== PrimaryAttack - 主攻击：客户端空实现（实际由服务器处理） ====
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 武器选择菜单绘制（沿用母本实现） ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== Deploy - 出枪：通知游戏模式 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- ==== Think - 每帧逻辑：右键/换弹键旋转放置幽灵 ====
function SWEP:Think()
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

-- 旋转点击音效的节流计时
local nextclick = 0
-- ==== RotateGhost - 旋转放置幽灵并通过控制台命令同步 ====
function SWEP:RotateGhost(amount)
	-- 旋转时播放节流后的点击音效
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVar("_zs_ghostrotation"):GetFloat() + amount))
end
