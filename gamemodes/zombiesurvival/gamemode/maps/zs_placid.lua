-- ============================================================================
-- zs_placid.lua - zs_placid 地图补丁 - 生成两处环境火焰
-- 负责：地图加载完成后在地图两处建筑废墟位置生成 env_fire 环境火焰实体并立即点燃，
--       补充地图氛围；火焰伤害倍率为 60，玩家靠近时需注意避让
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 在坐标 (-3577.2402, -2450.1162, -398.9688) 处生成第一处环境火焰（火势大小 200）
	local ent2 = ents.Create("env_fire")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-3577.2402, -2450.1162, -398.9688))
		ent2:SetKeyValue("damagescale", 60)
		ent2:SetKeyValue("firesize", 200)
		ent2:Spawn()
		-- 启用并点燃火焰
		ent2:Fire("Enable", "", 0)
		ent2:Fire("StartFire", "", 0)
	end

	-- 在坐标 (-3696.8652, 2621.0576, -239.1022) 处生成第二处环境火焰
	local ent3 = ents.Create("env_fire")
	if ent3:IsValid() then
		ent3:SetPos(Vector(-3696.8652, 2621.0576, -239.1022))
		ent3:SetKeyValue("damagescale", 60)
		ent3:SetKeyValue("firesize", 200)
		ent3:Spawn()
		-- 启用并点燃火焰
		ent3:Fire("Enable", "", 0)
		ent3:Fire("StartFire", "", 0)
	end
end)
