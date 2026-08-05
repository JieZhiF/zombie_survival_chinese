-- ============================================================================
-- zs_xmas_lodge.lua - zs_xmas_lodge 地图补丁 - 清理弹药箱与地下残留物
-- 负责：移除地图自带的弹药箱（item_ammo_crate），统一由游戏模式补给机制提供弹药；
--       同时移除掉落到 z 轴 -300 以下的物理道具，清理地图底部的残留物
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 移除地图自带的弹药箱，避免与游戏模式的弹药补给机制冲突
	for _, ent in pairs(ents.FindByClass("item_ammo_crate")) do ent:Remove() end

		-- 移除所有掉落到地图底部（z < -300）的物理道具，清理悬浮残留物
	for _, ent in pairs(ents.FindByClass("prop_physics*")) do
		if ent:GetPos().z < -300 then
			ent:Remove()
		end
	end
end)
