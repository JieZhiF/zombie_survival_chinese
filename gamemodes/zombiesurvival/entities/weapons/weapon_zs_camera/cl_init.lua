-- ============================================================================
-- weapon_zs_camera/cl_init.lua - 相机部署武器（客户端）
-- 负责：客户端显示逻辑，隐藏世界模型、绘制准星点；放置与开火逻辑均在服务器端
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
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	-- 绘制屏幕中央的准星点（配合放置预览定位）
	self:DrawCrosshairDot()
end

-- ==== Deploy - 武器部署 ====
function SWEP:Deploy()
	-- 记录待机动画播放完成时间
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== DrawWorldModel - 绘制世界模型 ====
function SWEP:DrawWorldModel()
	-- 空实现：隐藏世界模型（由放置预览显示虚拟模型）
end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel

-- ==== PrimaryAttack - 客户端开火占位 ====
function SWEP:PrimaryAttack()
	-- 客户端不处理开火（服务器端实现放置）
end

-- ==== DrawWeaponSelection - 绘制武器选择图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	-- 使用基础类的标准绘制方式
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
