-- ============================================================================
-- zs_woodhouse_rain.lua - 雨夜木屋 地图补丁
-- 负责：启用地图上所有物理道具的运动模拟，使物件可被撞动或破坏
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 遍历所有物理道具并启用其物理运动
	for _, ent in pairs(ents.FindByClass("prop_physics*")) do
		ent:GetPhysicsObject():EnableMotion(true)
	end
end)
