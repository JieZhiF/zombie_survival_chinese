-- ============================================================================
-- weapon_zs_medicfield/cl_init.lua - 医疗站部署器（客户端）
-- 负责：声明部署物槽位与圆点准星；右键/换弹键旋转放置预览（幽灵），
--       并通过 ConVar 把旋转量同步给服务器
-- ============================================================================
INC_CLIENT()

-- 不绘制游戏默认准星
SWEP.DrawCrosshair = false

-- 武器槽位：部署物类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
SWEP.SlotPos = 0

-- ==== DrawHUD - 绘制 HUD：按准星设置绘制圆点准星 ====
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetBool() then
		self:DrawCrosshairDot()
	end
end

-- ==== PrimaryAttack - 主攻击（空实现：部署由服务器端处理） ====
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 武器选择界面：沿用基底绘制 ====
function SWEP:DrawWeaponSelection(...)
	return self:BaseDrawWeaponSelection(...)
end

-- ==== Think - 每帧：右键/换弹键旋转放置预览幽灵 ====
function SWEP:Think()
	-- 按住右键：顺时针旋转预览
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	-- 按住换弹键：逆时针旋转预览
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

-- ==== Deploy - 出枪：触发部署事件（客户端侧） ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- 旋转音效的节流时间戳
local nextclick = 0
-- ==== RotateGhost - 旋转幽灵：带节流点击音，并把旋转量写入 ConVar 同步服务器 ====
function SWEP:RotateGhost(amount)
	-- 每 0.3 秒最多播一次旋转音
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	-- 累加旋转角度（归一化到 [-180, 180]）并提交给服务器
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVar("_zs_ghostrotation"):GetFloat() + amount))
end
