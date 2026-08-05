-- ============================================================================
-- weapon_zs_repairfield/cl_init.lua - 修理场部署器（客户端定义）
-- 负责：武器栏显示、放置幽灵的旋转操作与准星绘制
-- ============================================================================
-- 客户端专用（GMod 武器文件的标准客户端入口标记）
INC_CLIENT()

-- 不绘制默认准星（使用自定义准星点）
SWEP.DrawCrosshair = false

-- 武器槽位（可部署物品槽）/ 槽位分组 / 槽内位置
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
SWEP.SlotPos = 0

-- ==== DrawHUD - 开启准星设置时绘制准星点 ====
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetBool() then
		self:DrawCrosshairDot()
	end
end

-- ==== PrimaryAttack - 客户端不做部署逻辑（留空） ====
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 使用基础武器选择绘制 ====
function SWEP:DrawWeaponSelection(...)
	return self:BaseDrawWeaponSelection(...)
end

-- ==== Think - 每帧处理放置幽灵的旋转输入 ====
function SWEP:Think()
	-- 按住右键顺时针旋转幽灵
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	-- 按住换弹键逆时针旋转幽灵
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

-- ==== Deploy - 切换出武器时通知游戏模式 ====
function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- 旋转音效冷却时间戳
local nextclick = 0
-- ==== RotateGhost - 旋转放置幽灵并播放点击音效 ====
function SWEP:RotateGhost(amount)
	-- 限制旋转音效播放频率
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	-- 更新全局旋转角度（服务器端幽灵预览读取该角度）
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVar("_zs_ghostrotation"):GetFloat() + amount))
end
