-- ========== 物品库存系统数据表（共享） ==========

-- 存储所有物品当前库存数量的全局表
GM.ItemStocks = {}

-- ========== 获取物品库存数量 ==========

-- 返回指定物品的剩余库存数，如果没有限制则返回-1（无限）
function GM:GetItemStocks(itemid)
	if self.ItemStocks[itemid] then
		return self.ItemStocks[itemid]
	end

	local item = FindItem(itemid)
	if item and item.MaxStock then
		return item.MaxStock
	end

	return -1
end

-- ========== 检查物品是否有库存 ==========

-- 判断指定物品是否还有库存（大于0或无限）
function GM:HasItemStocks(itemid)
	local stock = self:GetItemStocks(itemid)
	return stock > 0 or stock == -1
end
