-- ============================================================================
-- weapon_zs_t_nightvision.lua - 夜视仪（饰品类道具武器）
-- 负责：左键开关夜视效果（切换游戏模式的夜视开关状态）
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 继承饰品基础武器（不占主武器位）
SWEP.Base = "weapon_zs_basetrinket"

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_nightvision")
SWEP.Description = ""..translate.Get("weapon_zs_t_nightvision_description")

if CLIENT then
	-- 第一人称附加模型：右手佩戴的夜视仪
	SWEP.VElements = {
		["perf"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 1.557, -2.597), angle = Angle(5.843, 90, 0), size = Vector(0.25, 0.15, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称附加模型：右手佩戴的夜视仪
	SWEP.WElements = {
		["perf"] = { type = "Model", model = "models/props_combine/combine_lock01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 0.5, -2), angle = Angle(5, 90, 0), size = Vector(0.25, 0.15, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 隐藏原始模型（完全用附加模型显示）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
end

-- 非自动（单击触发）/ 触发间隔
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1

-- ==== PrimaryAttack - 左键开关夜视仪 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 客户端：播放开关音效并翻转夜视开关状态
	if CLIENT and IsFirstTimePredicted() then
		surface.PlaySound(GAMEMODE.m_NightVision and "items/nvg_off.wav" or "items/nvg_on.wav")
		GAMEMODE.m_NightVision = not GAMEMODE.m_NightVision
	end
end
