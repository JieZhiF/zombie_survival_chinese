-- ========== 自定义弹药系统说明 ==========

-- 武器当前不需要此系统，仅用于组件/自定义弹药类型

-- ========== 自定义弹药数据表 ==========

CUSTOM_AMMO = {}

-- ========== 局部引用声明 ==========

local CUSTOM_AMMO = CUSTOM_AMMO
-- 自定义弹药起始索引（从128开始，避免与游戏内置弹药ID冲突）
local CUSTOM_AMMO_NUM = 128

-- ========== 元表获取 ==========

local M_Weapon = FindMetaTable("Weapon")
local M_Player = FindMetaTable("Player")
local M_Entity = FindMetaTable("Entity")

-- 获取实体GetTable方法的快速引用
local E_GetTable = M_Entity.GetTable

-- ========== 保存原始游戏函数 ==========

-- 保存游戏内置的弹药相关函数以便后续调用
local old_game_AddAmmoType = game.AddAmmoType
local old_game_GetAmmoID = game.GetAmmoID
local old_game_GetAmmoMax = game.GetAmmoMax
local old_game_GetAmmoName = game.GetAmmoName

-- 保存武器弹药类型获取函数的原始版本
local old_Weapon_GetPrimaryAmmoType = M_Weapon.GetPrimaryAmmoType
local old_Weapon_GetSecondaryAmmoType = M_Weapon.GetSecondaryAmmoType

-- 保存玩家弹药计数函数的原始版本
local old_Player_GetAmmoCount = M_Player.GetAmmoCount

-- ========== 已添加弹药类型计数器 ==========

local added = 0

-- ========== 重写game.AddAmmoType函数 ==========

-- 拦截弹药类型注册：前34种使用原版函数，后续使用扩展系统
function game.AddAmmoType(data)
	added = added + 1
	if added < 35 then
		old_game_AddAmmoType(data)
	else
		game.AddExpandedAmmoType(data)
	end
end

-- ========== 添加扩展弹药类型 ==========

-- 将弹药注册到自定义弹药表中，使用128+的索引
function game.AddExpandedAmmoType(data)
	CUSTOM_AMMO_NUM = CUSTOM_AMMO_NUM + 1

	data.index = CUSTOM_AMMO_NUM
	data.maxcarry = data.maxcarry or 9999
	CUSTOM_AMMO[CUSTOM_AMMO_NUM] = data
	CUSTOM_AMMO[data.name] = data
end

-- ========== 重写game.GetAmmoID函数 ==========

-- 在自定义弹药表中查找弹药ID，否则回退到原版函数
function game.GetAmmoID(name)
	return CUSTOM_AMMO[name] and CUSTOM_AMMO[name].index or old_game_GetAmmoID(name)
end

-- ========== 重写game.GetAmmoMax函数 ==========

-- 获取自定义弹药的最大携带量，否则回退到原版函数
function game.GetAmmoMax(name)
	return CUSTOM_AMMO[name] and CUSTOM_AMMO[name].maxcarry or old_game_GetAmmoMax(name)
end

-- ========== 重写game.GetAmmoName函数 ==========

-- 通过弹药ID获取名称，优先在自定义表中查找
function game.GetAmmoName(id)
	return CUSTOM_AMMO[id] and CUSTOM_AMMO[id].name or old_game_GetAmmoName(id)
end

-- ========== 重写武器主弹药类型获取 ==========

-- 如果武器使用了自定义弹药，返回扩展后的弹药ID
function M_Weapon:GetPrimaryAmmoType()
	local t = E_GetTable(self)
	if t.Primary and t.Primary.Ammo and CUSTOM_AMMO[t.Primary.Ammo] then return CUSTOM_AMMO[t.Primary.Ammo].index end

	return old_Weapon_GetPrimaryAmmoType(self)
end

-- ========== 重写武器副弹药类型获取 ==========

-- 如果武器副弹药使用了自定义弹药，返回扩展后的弹药ID
function M_Weapon:GetSecondaryAmmoType()
	local t = E_GetTable(self)
	if t.Secondary and t.Secondary.Ammo and CUSTOM_AMMO[t.Secondary.Ammo] then return CUSTOM_AMMO[t.Secondary.Ammo].index end

	return old_Weapon_GetSecondaryAmmoType(self)
end

-- ========== 注释掉的待实现武器弹药方法 ==========

--[[function M_Weapon:HasAmmo()
	-- TODO
end

function M_Weapon:Clip1()
	-- TODO
end

function M_Weapon:Clip2()
	-- TODO
end]]
