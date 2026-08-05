-- ============================================================================
-- weapon_zs_gunturret/cl_init.lua - 机枪塔部署武器（客户端）
-- 负责：客户端绘制（隐藏准星/模型）、放置幽灵的旋转操作与武器选择图标绘制
-- ============================================================================

INC_CLIENT()

-- 不绘制游戏默认准星
SWEP.DrawCrosshair = false

-- 武器槽位：部署类武器专用槽
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
-- 武器选择分组：部署类
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
-- 槽内位置 0
SWEP.SlotPos = 0

-- ==== DrawHUD - 绘制 HUD 准星 ====
function SWEP:DrawHUD()
	-- 仅当玩家开启游戏准星（crosshair 1）时绘制圆点准星
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== Deploy - 客户端出枪动画 ====
function SWEP:Deploy()
	-- 记录出枪动画时长，到时切换待机动画
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== DrawWorldModel - 不绘制世界模型 ====
function SWEP:DrawWorldModel()
end
-- 世界模型不参与半透明绘制
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

-- ==== PrimaryAttack - 客户端禁用左键开火 ====
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	-- 使用基础武器选择绘制
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- ==== Think - 每帧检测放置幽灵旋转输入 ====
function SWEP:Think()
	-- 按住右键：顺时针旋转放置幽灵
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	-- 按住换弹键：逆时针旋转放置幽灵
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

-- 点击音效节流时间戳
local nextclick = 0
-- ==== RotateGhost - 旋转放置幽灵 ====
function SWEP:RotateGhost(amount)
	-- 节流：每 0.3 秒最多播放一次旋转音效
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	-- 将旋转角度累加并同步到控制台变量（由幽灵实体读取）
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVar("_zs_ghostrotation"):GetFloat() + amount))
end
