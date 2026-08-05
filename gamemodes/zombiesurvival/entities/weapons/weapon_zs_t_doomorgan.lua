-- ============================================================================
-- weapon_zs_t_doomorgan.lua - 末日器官饰品武器
-- 负责：饰品类武器（继承 basetrinket），左键使用时清除自身负面状态
--       （虚弱、减速、视野模糊、冰冻），有20秒冷却
-- ============================================================================
AddCSLuaFile()

-- 继承饰品武器基类
SWEP.Base = "weapon_zs_basetrinket"

-- 武器显示名称与描述（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_t_doomorgan")
SWEP.Description = ""..translate.Get("weapon_zs_t_doomorgan_description")

if CLIENT then
	-- 第一人称视角模型元素（由多个虫饵模型拼成的器官外观）
	SWEP.VElements = {
		["doom_organ"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0, 0, -2), angle = Angle(0, 0, 0), size = Vector(0.885, 0.8, 1.08), color = Color(65, 45, 36, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["doom_organ++"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Grenade_body", rel = "doom_organ", pos = Vector(0, 0, 3.635), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 1), color = Color(45, 35, 25, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["doom_organ+++"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Grenade_body", rel = "doom_organ", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.15, 0.2, 4.193), color = Color(65, 55, 45, 255), surpresslightning = false, material = "models/flesh", skin = 0, bodygroup = {} },
		["doom_organ+"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Grenade_body", rel = "doom_organ", pos = Vector(0, 0, -3), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 1), color = Color(45, 35, 25, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型元素（第三人称显示的器官外观）
	SWEP.WElements = {
		["doom_organ"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.5, 0.518), angle = Angle(0, 0, 0), size = Vector(0.885, 0.8, 1.08), color = Color(65, 45, 36, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["doom_organ++"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "doom_organ", pos = Vector(0, 0, 3.635), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 1), color = Color(45, 35, 25, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["doom_organ+++"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "doom_organ", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.15, 0.2, 4.193), color = Color(65, 55, 45, 255), surpresslightning = false, material = "models/flesh", skin = 0, bodygroup = {} },
		["doom_organ+"] = { type = "Model", model = "models/weapons/w_bugbait.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "doom_organ", pos = Vector(0, 0, -3), angle = Angle(0, 0, 0), size = Vector(0.5, 0.5, 1), color = Color(45, 35, 25, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 隐藏原始模型，使用 SCK 元素自定义外观
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
end

-- 主攻击设置：非全自动、1秒冷却
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1

-- ==== PrimaryAttack - 左键使用末日器官（清除负面状态） ====
function SWEP:PrimaryAttack()
	-- 冷却检查
	if not self:CanPrimaryAttack() then return end
	-- 设置下次攻击冷却
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local owner = self:GetOwner()
	-- 20秒冷却检查：首次使用或冷却已过时执行
	if SERVER and not owner.LastDoomOrganCleanse or (owner.LastDoomOrganCleanse and owner.LastDoomOrganCleanse + 20 < CurTime()) then
		-- 记录本次使用时间
		owner.LastDoomOrganCleanse = CurTime()
		-- 播放挤压音效
		owner:EmitSound("weapons/bugbait/bugbait_squeeze3.wav", 70, 70)
		-- 播放肉体冲击音效
		owner:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav", 65, 135, 1, CHAN_AUTO)

		-- 客户端白屏闪烁效果
		owner:SendLua("util.WhiteOut(0.25)")

		-- 清除所有负面状态
		local statuses = {"enfeeble", "slow", "dimvision", "frost"}
		for _, status in pairs(statuses) do
			if owner:GetStatus(status) then
				owner:RemoveStatus(status)
			end
		end
	end
end
