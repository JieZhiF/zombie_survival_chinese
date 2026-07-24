-- ============================================================
-- 文件: obj_weapon_extend.lua
-- 作用: 共享脚本（同时在服务器和客户端运行）
-- 功能: 扩展武器(Weapon)对象的元表，提供弹药管理、攻击/换弹计时、模型控制等便捷辅助函数
-- ============================================================

-- 以下为本文件中所有扩展函数的简要说明：
-- GetNextPrimaryAttack / GetNextSecondaryAttack —— GetNextPrimaryFire / GetNextSecondaryFire 的别名
-- SetNextPrimaryAttack / SetNextSecondaryAttack —— SetNextPrimaryFire / SetNextSecondaryFire 的别名
-- ValidPrimaryAmmo —— 检查并返回有效的主弹药类型字符串（非"none"/"dummy"）
-- ValidSecondaryAmmo —— 检查并返回有效的副弹药类型字符串
-- SetNextReload / GetNextReload —— 设置/获取下次换弹可用时间
-- SetReloadStart / GetReloadStart —— 设置/获取换弹开始时间
-- SetReloadFinish / GetReloadFinish —— 设置/获取换弹完成时间
-- GetPrimaryAmmoCount / GetSecondaryAmmoCount —— 获取玩家主/副弹药总数（弹夹+备弹）
-- HideViewAndWorldModel / HideWorldAndViewModel —— 同时隐藏视图模型与世界模型
-- GetCombinedPrimaryAmmo / GetCombinedSecondaryAmmo —— 获取组合弹药总数（同 Count 系列）
-- TakeCombinedPrimaryAmmo / TakeCombinedSecondaryAmmo —— 从总弹药中消耗指定数量（优先备弹）
-- GetPrimaryAmmoTypeString / GetSecondaryAmmoTypeString —— 可靠获取弹药类型字符串名称

-- 获取武器对象的 Lua 元表，用于后续扩展方法
local meta = FindMetaTable("Weapon")

-- ============================================================
-- 攻击计时器别名
-- 将原生的 Fire 命名映射为 Attack 命名，方便武器代码统一风格
-- ============================================================

-- 将 GetNextPrimaryFire 映射为 GetNextPrimaryAttack
meta.GetNextPrimaryAttack = meta.GetNextPrimaryFire
-- 将 GetNextSecondaryFire 映射为 GetNextSecondaryAttack
meta.GetNextSecondaryAttack = meta.GetNextSecondaryFire
-- 将 SetNextPrimaryFire 映射为 SetNextPrimaryAttack
meta.SetNextPrimaryAttack = meta.SetNextPrimaryFire
-- 将 SetNextSecondaryFire 映射为 SetNextSecondaryAttack
meta.SetNextSecondaryAttack = meta.SetNextSecondaryFire

-- ============================================================
-- 验证主弹药类型是否有效（非"none"或"dummy"）
-- 返回值: 有效的弹药类型字符串，若无效则返回 nil
-- ============================================================
function meta:ValidPrimaryAmmo()
	-- 调用扩展方法获取主弹药类型字符串
	local ammotype = self:GetPrimaryAmmoTypeString()
	-- 判断是否为有效弹药类型
	if ammotype and ammotype ~= "none" and ammotype ~= "dummy" then
		return ammotype
	end
end

-- ============================================================
-- 验证副弹药类型是否有效（非"none"或"dummy"）
-- 返回值: 有效的弹药类型字符串，若无效则返回 nil
-- ============================================================
function meta:ValidSecondaryAmmo()
	-- 调用扩展方法获取副弹药类型字符串
	local ammotype = self:GetSecondaryAmmoTypeString()
	-- 判断是否为有效弹药类型
	if ammotype and ammotype ~= "none" and ammotype ~= "dummy" then
		return ammotype
	end
end

-- ============================================================
-- 换弹计时器网络变量封装
-- 使用 DT_WEAPON_BASE_FLOAT_* 网络变量在服务端与客户端间同步换弹状态
-- ============================================================

-- 设置下次换弹的可用时间（存储在网络变量中）
function meta:SetNextReload(fTime)
	self:SetDTFloat(DT_WEAPON_BASE_FLOAT_NEXTRELOAD, fTime)
end

-- 获取下次换弹的可用时间
function meta:GetNextReload()
	return self:GetDTFloat(DT_WEAPON_BASE_FLOAT_NEXTRELOAD)
end

-- 设置换弹开始的时间戳
function meta:SetReloadStart(fTime)
	self:SetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADSTART, fTime)
end

-- 获取换弹开始的时间戳
function meta:GetReloadStart()
	return self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADSTART)
end

-- 设置换弹完成的时间戳
function meta:SetReloadFinish(fTime)
	self:SetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADEND, fTime)
end

-- 获取换弹完成的时间戳
function meta:GetReloadFinish()
	return self:GetDTFloat(DT_WEAPON_BASE_FLOAT_RELOADEND)
end

-- ============================================================
-- 弹药总数统计
-- 计算玩家持有的弹药总量（子弹数 = 弹夹内 + 备用）
-- ============================================================

-- 获取主弹药总量: 备弹数 + 弹夹内子弹数
function meta:GetPrimaryAmmoCount()
	return self:GetOwner():GetAmmoCount(self.Primary.Ammo) + self:Clip1()
end

-- 获取副弹药总量: 备弹数 + 弹夹内子弹数
function meta:GetSecondaryAmmoCount()
	return self:GetOwner():GetAmmoCount(self.Secondary.Ammo) + self:Clip2()
end

-- ============================================================
-- 模型隐藏便捷方法
-- 同时隐藏视图模型（第一人称）与世界模型（第三人称）
-- ============================================================

-- 便捷函数：同时调用隐藏视图模型和世界模型
function meta:HideViewAndWorldModel()
	self:HideViewModel()
	self:HideWorldModel()
end
-- 为 HideViewAndWorldModel 创建别名
meta.HideWorldAndViewModel = meta.HideViewAndWorldModel

-- ============================================================
-- 组合弹药总数（与 GetPrimaryAmmoCount 系列功能相同，命名不同）
-- ============================================================

-- 获取组合主弹药总数：弹夹 + 备弹
function meta:GetCombinedPrimaryAmmo()
	return self:Clip1() + self:GetOwner():GetAmmoCount(self.Primary.Ammo)
end

-- 获取组合副弹药总数：弹夹 + 备弹
function meta:GetCombinedSecondaryAmmo()
	return self:Clip2() + self:GetOwner():GetAmmoCount(self.Secondary.Ammo)
end

-- ============================================================
-- 弹药消耗函数（优先消耗备弹，再消耗弹夹）
-- 从玩家持有的总弹药中扣除指定数量的子弹
-- ============================================================

-- 从总弹药中消耗指定数量的主弹药
function meta:TakeCombinedPrimaryAmmo(amount)
	-- 获取武器主弹药类型
	local ammotype = self.Primary.Ammo
	-- 获取武器持有者
	local owner = self:GetOwner()
	-- 获取当前弹夹内的子弹数
	local clip = self:Clip1()
	-- 获取玩家的备用弹药数
	local reserves = owner:GetAmmoCount(ammotype)

	-- 限制消耗量不超过总弹药数（备弹 + 弹夹）
	amount = math.min(reserves + clip, amount)

	-- 优先从备弹中扣除
	local fromreserves = math.min(reserves, amount)
	-- 判断备弹是否足够
	if fromreserves > 0 then
		amount = amount - fromreserves
		self:GetOwner():RemoveAmmo(fromreserves, ammotype)
	end

	-- 备弹不够时，从弹夹中扣除剩余部分
	local fromclip = math.min(clip, amount)
	-- 判断弹夹中是否有子弹可扣
	if fromclip > 0 then
		self:SetClip1(clip - fromclip)
	end
end

-- 从总弹药中消耗指定数量的副弹药
function meta:TakeCombinedSecondaryAmmo(amount)
	-- 获取武器副弹药类型
	local ammotype = self.Secondary.Ammo
	-- 获取武器持有者
	local owner = self:GetOwner()
	-- 获取当前副弹夹内的子弹数
	local clip = self:Clip2()
	-- 获取玩家的副备用弹药数
	local reserves = owner:GetAmmoCount(ammotype)

	-- 限制消耗量不超过总弹药数
	amount = math.min(reserves + clip, amount)

	-- 优先从备弹中扣除
	local fromreserves = math.min(reserves, amount)
	-- 判断备弹是否足够
	if fromreserves > 0 then
		amount = amount - fromreserves
		self:GetOwner():RemoveAmmo(fromreserves, ammotype)
	end

	-- 备弹不够时，从弹夹中扣除剩余部分
	local fromclip = math.min(clip, amount)
	-- 判断弹夹中是否有子弹可扣
	if fromclip > 0 then
		self:SetClip2(clip - fromclip)
	end
end

-- ============================================================
-- 弹药 ID → 名称 映射表
-- 将 Source 引擎的数字弹药类型 ID 转换为可读的字符串名称
-- 用于兼容旧版武器或直接从引擎获取弹药类型的情况
-- ============================================================
local TranslatedAmmo = {}
TranslatedAmmo[-1] = "none"              -- 无效弹药类型
TranslatedAmmo[0] = "none"               -- 无弹药
TranslatedAmmo[1] = "ar2"                -- AR2 突击步枪弹药
TranslatedAmmo[2] = "alyxgun"            -- 爱莉克斯手枪弹药
TranslatedAmmo[3] = "pistol"             -- 标准手枪弹药
TranslatedAmmo[4] = "smg1"               -- SMG1 冲锋枪弹药
TranslatedAmmo[5] = "357"                -- .357 马格南左轮弹药
TranslatedAmmo[6] = "xbowbolt"           -- 十字弓箭矢
TranslatedAmmo[7] = "buckshot"           -- 霰弹枪弹药
TranslatedAmmo[8] = "rpg_round"          -- RPG 火箭弹
TranslatedAmmo[9] = "smg1_grenade"       -- SMG 枪挂榴弹
TranslatedAmmo[10] = "sniperround"       -- 狙击步枪弹药
TranslatedAmmo[11] = "sniperpenetratedround" -- 穿甲狙击弹药
TranslatedAmmo[12] = "grenade"           -- 手榴弹
TranslatedAmmo[13] = "thumper"           -- 重击弹药
TranslatedAmmo[14] = "gravity"           -- 重力枪弹药（ID 14 对应重力枪）
TranslatedAmmo[14] = "battery"           -- 电池（覆盖上一行，实际引擎中电池也使用 ID 14）
TranslatedAmmo[15] = "gaussenergy"       -- 高斯枪能量弹药
TranslatedAmmo[16] = "combinecannon"     -- 联合军火炮弹药
TranslatedAmmo[17] = "airboatgun"        -- 气艇机枪弹药
TranslatedAmmo[18] = "striderminigun"    -- 三角机甲机枪弹药
TranslatedAmmo[19] = "helicoptergun"     -- 直升机机枪弹药
TranslatedAmmo[20] = "ar2altfire"        -- AR2 副模式弹药（脉冲弹）
TranslatedAmmo[21] = "slam"              -- SLAM 遥控炸药

-- ============================================================
-- 获取主弹药类型字符串（优先使用武器定义，否则从引擎 ID 转换）
-- 返回值: 弹药类型名称的字符串（小写），若无效则返回"none"
-- ============================================================
function meta:GetPrimaryAmmoTypeString()
	-- 如果武器已定义 Primary.Ammo 字段，直接返回其小写形式
	if self.Primary and self.Primary.Ammo then return string.lower(self.Primary.Ammo) end
	-- 否则从映射表中根据引擎 ID 查找
	return TranslatedAmmo[self:GetPrimaryAmmoType()] or "none"
end

-- ============================================================
-- 获取副弹药类型字符串（优先使用武器定义，否则从引擎 ID 转换）
-- 返回值: 弹药类型名称的字符串（小写），若无效则返回"none"
-- ============================================================
function meta:GetSecondaryAmmoTypeString()
	-- 如果武器已定义 Secondary.Ammo 字段，直接返回其小写形式
	if self.Secondary and self.Secondary.Ammo then return string.lower(self.Secondary.Ammo) end
	-- 否则从映射表中根据引擎 ID 查找
	return TranslatedAmmo[self:GetSecondaryAmmoType()] or "none"
end
