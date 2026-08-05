-- ============================================================================
-- zs_dl_powercliff.lua - 电力悬崖 地图补丁
-- 负责：将所有僵尸出生点集中到固定坐标附近（随机偏移不超过 100 单位）
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 目标集中点坐标
	local pos = Vector(-2580, 2294, 48)
	-- 遍历所有僵尸出生点并移动到集中点附近
	for _, ent in pairs(ents.FindByClass("info_player_zombie")) do
		-- 生成水平方向随机偏移（z 归零，仅在 XY 平面内偏移）
		local rand = VectorRand()
		rand.z = 0
		rand = rand * 100

		ent:SetPos(pos + rand)
	end
end)
