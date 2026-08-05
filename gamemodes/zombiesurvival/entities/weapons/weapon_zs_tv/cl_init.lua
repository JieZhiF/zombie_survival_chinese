-- ============================================================================
-- weapon_zs_tv/cl_init.lua - 电视部署物武器（客户端部分）
-- 负责：栏位与准星设置；不绘制世界模型（放置预览由幽灵状态呈现），
--       左键逻辑由服务器处理
-- ============================================================================
INC_CLIENT() -- 客户端专用文件标记

SWEP.DrawCrosshair = false -- 不绘制准星（用屏幕中心点代替）


-- 武器栏位：放入"可部署物品"分类
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotDeployables")
-- 栏位组：可部署物品栏
SWEP.SlotGroup = WEPSELECT_DEPLOYABLES
-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

-- ==== DrawHUD - 绘制 HUD 准星 ====
-- 仅当玩家开启了准星设置时，绘制屏幕中心的放置落点指示点
function SWEP:DrawHUD()
	if GetConVar("crosshair"):GetInt() ~= 1 then return end
	self:DrawCrosshairDot()
end

-- ==== Deploy - 武器展开时 ====
-- 延迟待机动画（客户端表现）
function SWEP:Deploy()
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== DrawWorldModel - 不绘制世界模型 ====
-- 电视的世界模型由部署预览幽灵呈现，这里留空禁用默认绘制
function SWEP:DrawWorldModel()
end
SWEP.DrawWorldModelTranslucent = SWEP.DrawWorldModel -- 半透明绘制同样留空

-- ==== PrimaryAttack - 左键（空实现） ====
-- 放置逻辑由服务器端处理
function SWEP:PrimaryAttack()
end

-- ==== DrawWeaponSelection - 武器选择界面图标 ====
-- 使用基础武器母本的默认绘制
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end
