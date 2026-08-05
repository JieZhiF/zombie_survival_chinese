-- ============================================================================
-- zs_mines_b3.lua - 矿井 地图补丁
-- 负责：移除地图上所有 func_button 按钮与第 3 个旋转按钮，防止玩家触发机关破坏平衡
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "MPInitPostEntity", function()
	-- 遍历并移除所有按钮实体
	for _, ent in pairs(ents.FindByClass("func_button")) do
		ent:Remove()
	end

	-- 直接按索引移除第 3 个旋转按钮
	ents.FindByClass("func_rot_button")[3]:Remove()
end)
