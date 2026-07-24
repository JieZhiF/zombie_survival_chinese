-- ========== 引入共享库存模块 ==========

include("sh_stock.lua")

-- ========== 清除客户端库存数据 ==========

-- 清空客户端本地缓存的物品库存表
function GM:ClearItemStocks()
	self.ItemStocks = {}
end

-- ========== 接收服务端库存更新 ==========

-- 从服务端接收单个物品的最新库存数量
net.Receive("zs_itemstock", function(length)
	local itemid = net.ReadString()
	local stock = net.ReadInt(16)

	GAMEMODE.ItemStocks[itemid] = stock
end)
