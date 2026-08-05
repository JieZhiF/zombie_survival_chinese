-- ========== 获取Player元表 ==========

local M_Player = FindMetaTable("Player")

local E_GetTable = FindMetaTable("Entity").GetTable

-- ========== 保存客户端原始玩家弹药函数 ==========

local old_Player_SetAmmo = M_Player.SetAmmo
local old_Player_GetAmmoCount = M_Player.GetAmmoCount
local old_Player_RemoveAmmo = M_Player.RemoveAmmo

-- ========== 客户端自定义弹药计数表 ==========

local CUSTOM_AMMO_COUNT = {}

-- ========== 通过名称或ID获取自定义弹药ID ==========

local function GetIDFromNameOrID(id_or_name)
	local ca = CUSTOM_AMMO[id_or_name]
	if ca then
		return ca.index
	end
end

-- ========== 重写客户端获取弹药数量 ==========

function M_Player:GetAmmoCount(id_or_name)
	if LocalPlayer() ~= self then return 0 end

	local id = GetIDFromNameOrID(id_or_name)
	if id then
		return CUSTOM_AMMO_COUNT[id] or 0
	end

	return old_Player_GetAmmoCount(self, id_or_name)
end

-- ========== 重写客户端设置弹药数量 ==========

function M_Player:SetAmmo(amount, id_or_name)
	if LocalPlayer() ~= self then return end

	local id = GetIDFromNameOrID(id_or_name)
	if id then
		CUSTOM_AMMO_COUNT[id] = amount
	else
		old_Player_SetAmmo(self, amount, id_or_name)
	end
end

-- ========== 重写客户端移除弹药 ==========

function M_Player:RemoveAmmo(amount, id_or_name)
	if LocalPlayer() ~= self then return end

	local id = GetIDFromNameOrID(id_or_name)
	if id then
		CUSTOM_AMMO_COUNT[id] = math.max((CUSTOM_AMMO_COUNT[id] or 0) - amount, 0)
	else
		old_Player_RemoveAmmo(self, amount, id_or_name)
	end
end

-- ========== 接收服务端弹药数量更新 ==========

net.Receive(NET_MSG.CUSAMMO, function(length)
	local index = net.ReadUInt(6) + 128
	local amount = net.ReadUInt(10)

	CUSTOM_AMMO_COUNT[index] = amount
end)

-- ========== 接收服务端清除所有弹药指令 ==========

net.Receive(NET_MSG.CUSAMMO_REMOVEALL, function(length)
	CUSTOM_AMMO_COUNT = {}
end)
