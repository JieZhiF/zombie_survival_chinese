-- ============================================================================
-- weapon_zs_crow/cl_init.lua - 乌鸦僵尸利爪（客户端表现）
-- 负责：客户端显示名称与空操作占位（攻击/换弹逻辑全在服务端），以及武器选择图标
-- ============================================================================
INC_CLIENT()

-- 客户端显示名称（本地化），不绘制准星（近战武器）
SWEP.PrintName = ""..translate.Get("weapon_zs_crow")
SWEP.DrawCrosshair = false

-- ==== PrimaryAttack - 占位覆盖：客户端不执行攻击逻辑 ====
function SWEP:PrimaryAttack()
end

-- ==== SecondaryAttack - 占位覆盖：客户端不执行副攻击逻辑 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 占位覆盖：近战武器无换弹 ====
function SWEP:Reload()
end

-- ==== Think - 占位覆盖：客户端不执行武器逻辑 ====
function SWEP:Think()
end

-- ==== DrawWeaponSelection - 绘制武器选择栏图标 ====
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
