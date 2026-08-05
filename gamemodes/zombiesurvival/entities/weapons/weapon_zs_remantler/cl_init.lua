-- ============================================================================
-- weapon_zs_remantler/cl_init.lua - 残骸重组器部署武器（客户端）
-- 负责：客户端显示逻辑，绘制准星点、处理右键/R键旋转预览、武器选择图标绘制
-- ============================================================================
INC_CLIENT()

-- 不绘制默认十字准星（改为自绘准星点）
SWEP.DrawCrosshair = false
-- 武器在武器选择栏中的栏位（部署物栏）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
-- 武器栏位分组（部署物）
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES

-- 栏位内排序位置
SWEP.SlotPos = 0

-- ==== DrawHUD - 绘制 HUD ====
function SWEP:DrawHUD()
	-- 玩家关闭准星时跳过绘制
	if GetConVarNumber("crosshair") ~= 1 then return end
	-- 绘制屏幕中央的准星点（配合放置预览定位）
	self:DrawCrosshairDot()
end

-- ==== PrimaryAttack - 客户端开火占位 ====
function SWEP:PrimaryAttack()
	-- 客户端不处理开火（服务器端实现部署）
end

-- ==== DrawWeaponSelection - 绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(...)
	-- 使用基础类的标准绘制方式
	return self:BaseDrawWeaponSelection(...)
end

-- ==== Think - 客户端每帧检测按键并旋转放置预览 ====
function SWEP:Think()
	-- 右键按住时顺时针旋转预览
	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self:RotateGhost(FrameTime() * 60)
	end
	-- R键按住时逆时针旋转预览
	if self:GetOwner():KeyDown(IN_RELOAD) then
		self:RotateGhost(FrameTime() * -60)
	end
end

-- ==== Deploy - 武器部署 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- 旋转音效播放冷却时间
local nextclick = 0
-- ==== RotateGhost - 旋转放置预览角度 ====
function SWEP:RotateGhost(amount)
	-- 节流播放旋转音效（每0.3秒一次）
	if nextclick <= RealTime() then
		surface.PlaySound("npc/headcrab_poison/ph_step4.wav")
		nextclick = RealTime() + 0.3
	end
	-- 通过控制台命令更新预览旋转角度
	RunConsoleCommand("_zs_ghostrotation", math.NormalizeAngle(GetConVarNumber("_zs_ghostrotation") + amount))
end
