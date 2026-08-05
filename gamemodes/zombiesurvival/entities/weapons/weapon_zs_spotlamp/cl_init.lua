-- ============================================================================
-- cl_init.lua - 探照灯（可部署照明武器）客户端逻辑
-- 负责：准星与武器栏位配置、幽灵预览旋转（右键/换弹键）、HUD 绘制
-- ============================================================================

-- 客户端 realm 守卫：仅客户端加载本文件（替代 if CLIENT then 写法）
INC_CLIENT()

-- 不绘制默认准星（部署类武器用中心点代替）
SWEP.DrawCrosshair = false

-- 武器栏位（可部署物分类）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
SWEP.SlotPos = 0

-- ==== DrawHUD - 准星开启（数值为 1）时绘制中心部署点 ====
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== PrimaryAttack - 客户端不处理开火（由服务端执行） ====
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 使用基类默认的武器选择绘制 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== Think - 按住右键/换弹键时旋转放置预览（每帧） ====
function SWEP:Think()
	-- 右键：顺时针旋转预览
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	-- 换弹键：逆时针旋转预览
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

-- ==== Deploy - 部署武器：广播部署事件 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- 旋转点击音效的节流计时
local nextclick = 0
-- ==== RotateGhost - 按给定角度旋转放置预览（带点击音效与 0.3 秒节流） ====
function SWEP:RotateGhost(amount)
	-- 节流：每次旋转间隔至少 0.3 秒才播放点击音
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	-- 通过控制台命令把累计旋转角写回共享 ConVar（服务端幽灵状态据此旋转）
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVar("_zs_ghostrotation"):GetFloat() + amount))
end
