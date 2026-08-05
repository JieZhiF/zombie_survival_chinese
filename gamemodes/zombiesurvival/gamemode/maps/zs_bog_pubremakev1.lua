-- ============================================================================
-- zs_bog_pubremakev1.lua - zs_bog_pubremakev1 地图补丁 - 移除传送与伤害触发器
-- 负责：移除地图中的传送触发器（trigger_teleport），防止玩家利用传送点卡位
--       或跳过守点区域；移除伤害触发器（trigger_hurt），避免路过时被无预警秒杀
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 移除地图的传送触发器，防止玩家利用传送点卡位或跳过守点区域
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Remove()
	end

		-- 移除地图的伤害触发器（trigger_hurt），避免玩家路过时被无预警秒杀
	for _, ent in pairs(ents.FindByClass("trigger_hurt")) do
		ent:Remove()
	end
end)
