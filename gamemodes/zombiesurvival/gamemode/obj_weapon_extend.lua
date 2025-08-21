-- 本文件为共享脚本（同时在服务器和客户端运行），主要用于扩展武器对象的功能，提供了一系列便捷的辅助函数，用于简化弹药管理、攻击/换弹计时、以及模型控制等常见操作。

-- GetNextPrimaryAttack GetNextPrimaryFire的别名，用于获取下一次主攻击的可用时间。
-- GetNextSecondaryAttack GetNextSecondaryFire的别名，用于获取下一次副攻击的可用时间。
-- SetNextPrimaryAttack SetNextPrimaryFire的别名，用于设置下一次主攻击的可用时间。
-- SetNextSecondaryAttack SetNextSecondaryFire的别名，用于设置下一次副攻击的可用时间。
-- ValidPrimaryAmmo 检查并返回一个有效的主弹药类型字符串（非"none"或"dummy"）。
-- ValidSecondaryAmmo 检查并返回一个有效的副弹药类型字符串。
-- SetNextReload 设置下一次可以开始装弹的时间。
-- GetNextReload 获取下一次可以开始装弹的时间。
-- SetReloadStart 设置本次装弹开始的时间。
-- GetReloadStart 获取本次装弹开始的时间。
-- SetReloadFinish 设置本次装弹完成的时间。
-- GetReloadFinish 获取本次装弹完成的时间。
-- GetPrimaryAmmoCount 获取玩家拥有的主弹药总数（弹夹内 + 备弹）。
-- GetSecondaryAmmoCount 获取玩家拥有的副弹药总数（弹夹内 + 备弹）。
-- HideViewAndWorldModel 一个便捷函数，同时调用隐藏视图模型和世界模型的方法。
-- HideWorldAndViewModel HideViewAndWorldModel的别名。
-- GetCombinedPrimaryAmmo 获取玩家拥有的主弹药总数（弹夹内 + 备弹），功能同 GetPrimaryAmmoCount。
-- GetCombinedSecondaryAmmo 获取玩家拥有的副弹药总数（弹夹内 + 备弹），功能同 GetSecondaryAmmoCount。
-- TakeCombinedPrimaryAmmo 从玩家的总主弹药中消耗指定数量的子弹（优先消耗备弹，再消耗弹夹内的）。
-- TakeCombinedSecondaryAmmo 从玩家的总副弹药中消耗指定数量的子弹（优先消耗备弹，再消耗弹夹内的）。
-- GetPrimaryAmmoTypeString 可靠地获取主弹药类型的字符串名称，如果需要会从引擎的数字ID进行转换。
-- GetSecondaryAmmoTypeString 可靠地获取副弹药类型的字符串名称，如果需要会从引擎的数字ID进行转换。
local meta = FindMetaTable("Weapon")

meta.GetNextPrimaryAttack = meta.GetNextPrimaryFire
meta.GetNextSecondaryAttack = meta.GetNextSecondaryFire
meta.SetNextPrimaryAttack = meta.SetNextPrimaryFire
meta.SetNextSecondaryAttack = meta.SetNextSecondaryFire

function meta:ValidPrimaryAmmo()
	local ammotype = self:GetPrimaryAmmoTypeString()
	if ammotype and ammotype ~= "none" and ammotype ~= "dummy" then
		return ammotype
	end
end

function meta:ValidSecondaryAmmo()
	local ammotype = self:GetSecondaryAmmoTypeString()
	if ammotype and ammotype ~= "none" and ammotype ~= "dummy" then
		return ammotype
	end
end

function meta:SetNextReload(fTime)
	self:SetDTFloat(DT_WEAPON_BASE_FLOAT_NEXTRELOAD, fTime)
end

function meta:GetNextReload()
	return self:GetDTFloat(DT_WEAPON_BASE_FLOAT_NEXTRELOAD)
end

function meta:SetReloadStart(fTime)
	self:SetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADSTART, fTime)
end

function meta:GetReloadStart()
	return self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADSTART)
end

function meta:SetReloadFinish(fTime)
	self:SetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADEND, fTime)
end

function meta:GetReloadFinish()
	return self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADEND)
end

function meta:GetPrimaryAmmoCount()
	return self:GetOwner():GetAmmoCount(self.Primary.Ammo) + self:Clip1()
end

function meta:GetSecondaryAmmoCount()
	return self:GetOwner():GetAmmoCount(self.Secondary.Ammo) + self:Clip2()
end

function meta:HideViewAndWorldModel()
	self:HideViewModel()
	self:HideWorldModel()
end
meta.HideWorldAndViewModel = meta.HideViewAndWorldModel

function meta:GetCombinedPrimaryAmmo()
	return self:Clip1() + self:GetOwner():GetAmmoCount(self.Primary.Ammo)
end

function meta:GetCombinedSecondaryAmmo()
	return self:Clip2() + self:GetOwner():GetAmmoCount(self.Secondary.Ammo)
end

function meta:TakeCombinedPrimaryAmmo(amount)
	local ammotype = self.Primary.Ammo
	local owner = self:GetOwner()
	local clip = self:Clip1()
	local reserves = owner:GetAmmoCount(ammotype)

	amount = math.min(reserves + clip, amount)

	local fromreserves = math.min(reserves, amount)
	if fromreserves > 0 then
		amount = amount - fromreserves
		self:GetOwner():RemoveAmmo(fromreserves, ammotype)
	end

	local fromclip = math.min(clip, amount)
	if fromclip > 0 then
		self:SetClip1(clip - fromclip)
	end
end

function meta:TakeCombinedSecondaryAmmo(amount)
	local ammotype = self.Secondary.Ammo
	local owner = self:GetOwner()
	local clip = self:Clip2()
	local reserves = owner:GetAmmoCount(ammotype)

	amount = math.min(reserves + clip, amount)

	local fromreserves = math.min(reserves, amount)
	if fromreserves > 0 then
		amount = amount - fromreserves
		self:GetOwner():RemoveAmmo(fromreserves, ammotype)
	end

	local fromclip = math.min(clip, amount)
	if fromclip > 0 then
		self:SetClip2(clip - fromclip)
	end
end

local TranslatedAmmo = {}
TranslatedAmmo[-1] = "none"
TranslatedAmmo[0] = "none"
TranslatedAmmo[1] = "ar2"
TranslatedAmmo[2] = "alyxgun"
TranslatedAmmo[3] = "pistol"
TranslatedAmmo[4] = "smg1"
TranslatedAmmo[5] = "357"
TranslatedAmmo[6] = "xbowbolt"
TranslatedAmmo[7] = "buckshot"
TranslatedAmmo[8] = "rpg_round"
TranslatedAmmo[9] = "smg1_grenade"
TranslatedAmmo[10] = "sniperround"
TranslatedAmmo[11] = "sniperpenetratedround"
TranslatedAmmo[12] = "grenade"
TranslatedAmmo[13] = "thumper"
TranslatedAmmo[14] = "gravity"
TranslatedAmmo[14] = "battery"
TranslatedAmmo[15] = "gaussenergy"
TranslatedAmmo[16] = "combinecannon"
TranslatedAmmo[17] = "airboatgun"
TranslatedAmmo[18] = "striderminigun"
TranslatedAmmo[19] = "helicoptergun"
TranslatedAmmo[20] = "ar2altfire"
TranslatedAmmo[21] = "slam"

function meta:GetPrimaryAmmoTypeString()
	if self.Primary and self.Primary.Ammo then return string.lower(self.Primary.Ammo) end
	return TranslatedAmmo[self:GetPrimaryAmmoType()] or "none"
end

function meta:GetSecondaryAmmoTypeString()
	if self.Secondary and self.Secondary.Ammo then return string.lower(self.Secondary.Ammo) end
	return TranslatedAmmo[self:GetSecondaryAmmoType()] or "none"
end
