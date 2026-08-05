-- ============================================================================
-- zs_manoir_de_perruques_z10.lua - 佩鲁克庄园 地图补丁
-- 负责：让第 4、5 扇旋转门免疫伤害（damagefilter=invul），防止门被破坏
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 获取地图上所有旋转门实体
	local doors = ents.FindByClass("func_door_rotating")
	-- 第 4 扇门设置为免疫伤害
	if doors[4] then
		doors[4]:SetKeyValue("damagefilter", "invul")
	end
	-- 第 5 扇门设置为免疫伤害
	if doors[5] then
		doors[5]:SetKeyValue("damagefilter", "invul")
	end
end)
