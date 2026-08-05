-- ============================================================================
-- weapon_zs_t_resupplypack.lua - 补给包（T 系随身小物件，主动使用后补给弹药）
-- 负责：定义手持补给箱的外观与左键使用逻辑（触发补给状态并结算补给效果）
-- ============================================================================

-- 客户端共享加载声明（本文件双端加载）
AddCSLuaFile()

-- 继承小物件（trinket）武器基类
SWEP.Base = "weapon_zs_basetrinket"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_resupplypack")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_t_resupplypack_description")

-- 客户端专用属性：附加模型外观
if CLIENT then
	-- 第一人称附加模型：手持弹药箱
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/Items/ammocrate_ar2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.35, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称附加模型：同样的弹药箱，供他人视角显示
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/Items/ammocrate_ar2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.35, 0.35, 0.35), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 隐藏原始模型，只显示附加模型
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
end

-- 左键：手动触发，非自动连发
SWEP.Primary.Automatic = false
-- 使用间隔 1 秒
SWEP.Primary.Delay = 1

-- ==== PrimaryAttack - 使用补给包 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 客户端不执行服务器逻辑
	if CLIENT then return end

	-- 服务器端：找到自己的补给状态实体，触发补给结算
	local owner = self:GetOwner()
	for _, ent in pairs(ents.FindByClass("status_resupplypack")) do
		if ent:GetOwner() == owner then
			owner:Resupply(owner, ent)
		end
	end
end
