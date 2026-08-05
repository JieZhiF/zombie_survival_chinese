-- ============================================================================
-- weapon_zs_detpack/cl_init.lua - 炸药包部署武器（客户端）
-- 负责：客户端显示逻辑，隐藏默认准星改为自绘准星点、武器栏位设置、武器选择图标绘制
-- ============================================================================
INC_CLIENT()

-- 不绘制默认十字准星（改为自绘准星点）
SWEP.DrawCrosshair = false


-- 武器栏位设置（爆炸物栏）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotExplosives")
SWEP.SlotGroup = WEPSELECT_EXPLOSIVE
-- 武器类型：爆炸物
SWEP.WeaponType = "explosive"
-- 栏位内排序位置
SWEP.SlotPos = 0

-- ==== Deploy - 武器部署 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	return true
end

-- ==== DrawHUD - 绘制 HUD ====
function SWEP:DrawHUD()
	-- 玩家关闭准星时跳过绘制
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	-- 绘制屏幕中央的准星点（配合放置预览定位）
	self:DrawCrosshairDot()
end

-- ==== PrimaryAttack - 客户端开火占位 ====
function SWEP:PrimaryAttack()
	-- 客户端不处理开火（服务器端实现部署）
end

-- ==== DrawWeaponSelection - 绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	-- 使用基础类的标准绘制方式
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
