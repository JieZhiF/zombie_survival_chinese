-- ========== 注册自定义弹药网络消息 ==========

util.AddNetworkString("cusammo")
util.AddNetworkString("cusammo_removeall")

-- ========== 获取Player元表 ==========

local M_Player = FindMetaTable("Player")
local E_GetTable = FindMetaTable("Entity").GetTable

-- ========== 保存原始玩家弹药函数 ==========

local old_Player_GiveAmmo = M_Player.GiveAmmo
local old_Player_GetAmmoCount = M_Player.GetAmmoCount
local old_Player_RemoveAmmo = M_Player.RemoveAmmo
local old_Player_SetAmmo = M_Player.SetAmmo
local old_Player_RemoveAllAmmo = M_Player.RemoveAllAmmo
local old_Player_StripAmmo = M_Player.StripAmmo

-- ========== 通过名称或ID获取自定义弹药ID ==========

-- 将弹药名称或ID转换为自定义弹药表中的索引ID
local function GetIDFromNameOrID(id_or_name)
	local ca = CUSTOM_AMMO[id_or_name]
	if ca then
		return ca.index
	end
end

-- ========== 重写玩家获取弹药数量 ==========

-- 优先在自定义弹药表中查找，否则调用原版函数
function M_Player:GetAmmoCount(id_or_name)
	local id = GetIDFromNameOrID(id_or_name)
	if id then
		local ca = E_GetTable(self).ca
		if ca then
			return ca[id] or 0
		end

		return 0
	end

	return old_Player_GetAmmoCount(self, id_or_name)
end

-- ========== 重写玩家给予弹药 ==========

-- 给予自定义弹药时存入ca表并同步客户端
function M_Player:GiveAmmo(amount, id_or_name, suppress_sound)
	local id = GetIDFromNameOrID(id_or_name)
	if id then
		local et = E_GetTable(self)
		if not et.ca then et.ca = {} end
		et.ca[id] = (self.ca[id] or 0) + amount

		self:UpdateCustomAmmoCount(id)

		-- 播放拾取音效
		if not suppress_sound then
			old_Player_GiveAmmo(self, 1, "dummy")
		end
	else
		old_Player_GiveAmmo(self, amount, id_or_name, suppress_sound)
	end
end

-- ========== 重写玩家移除弹药 ==========

-- 减少自定义弹药数量，不低于0
function M_Player:RemoveAmmo(amount, id_or_name)
	local id = GetIDFromNameOrID(id_or_name)
	if id then
		local et = E_GetTable(self)
		if not et.ca then et.ca = {} end
		et.ca[id] = math.max((self.ca[id] or 0) - amount, 0)

		self:UpdateCustomAmmoCount(id)
	else
		old_Player_RemoveAmmo(self, amount, id_or_name)
	end
end

-- ========== 重写玩家设置弹药数量 ==========

-- 直接设置自定义弹药数量
function M_Player:SetAmmo(amount, id_or_name)
	local id = GetIDFromNameOrID(id_or_name)
	if id then
		local et = E_GetTable(self)
		if not et.ca then et.ca = {} end
		et.ca[id] = amount

		self:UpdateCustomAmmoCount(id)
	else
		old_Player_SetAmmo(self, amount, id_or_name)
	end
end

-- ========== 重写玩家移除所有弹药 ==========

-- 清除自定义弹药和原版弹药
function M_Player:RemoveAllAmmo()
	self.ca = nil
	old_Player_RemoveAllAmmo(self)

	net.Start("cusammo_removeall")
	net.Send(self)
end

-- ========== 重写玩家剥离弹药 ==========

-- RemoveAllAmmo和StripAmmo的区别不确定，相同处理
function M_Player:StripAmmo()
	self.ca = nil
	old_Player_StripAmmo(self)

	net.Start("cusammo_removeall")
	net.Send(self)
end

-- ========== 同步自定义弹药数量到客户端 ==========

-- 将指定弹药的最新数量发送给玩家客户端
function M_Player:UpdateCustomAmmoCount(index)
	net.Start("cusammo")
	net.WriteUInt(index - 128, 6)
	net.WriteUInt(self.ca and self.ca[index] or 0, 10)
	net.Send(self)
end
