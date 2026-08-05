-- ========== 引入共享库存模块 ==========

include("sh_stock.lua")

-- ========== 注册客户端文件同步 ==========

AddCSLuaFile("cl_stock.lua")
AddCSLuaFile("sh_stock.lua")

-- ========== 设置物品库存数量（服务端） ==========

-- 为指定物品设置新的库存数量并通知客户端
function GM:SetItemStocks(itemid, stock)
	self.ItemStocks[itemid] = stock

	self:SendItemStocks(itemid)
end

-- ========== 增加/减少物品库存（服务端） ==========

-- 增加或减少指定物品的库存数量（不会低于0）
function GM:AddItemStocks(itemid, stock)
	local currentstock = self:GetItemStocks(itemid)
	if currentstock ~= -1 then
		self:SetItemStocks(itemid, math.max(currentstock + stock, 0))
	end
end

-- ========== 刷新玩家物品库存数据（服务端） ==========

-- 向指定玩家（或所有人类玩家）发送当前所有物品库存
function GM:RefreshItemStocks(pl)
	for k in pairs(self.ItemStocks) do
		self:SendItemStocks(k, pl)
	end
end

-- ========== 发送单件物品库存到客户端 ==========

-- 通过网络消息将指定物品的库存数量发送给玩家
function GM:SendItemStocks(itemid, pl)
	net.Start(NET_MSG.ITEMSTOCK)
		net.WriteString(tostring(itemid))
		net.WriteInt(self:GetItemStocks(itemid), 16)
	if pl then
		net.Send(pl)
	else
		net.Send(team.GetPlayers(TEAM_HUMAN))
	end
end

-- ========== 清除所有物品库存（服务端） ==========

-- 清空库存记录并可选通知客户端刷新
function GM:ClearItemStocks(nosend)
	self.ItemStocks = {}

	if not nosend then
		self:RefreshItemStocks()
	end
end
