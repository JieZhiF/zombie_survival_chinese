-- ============================================================================
-- abandonned_building.lua - 废弃建筑（Abandoned Building）地图补丁
-- 负责：移除按钮，并互相同步 T/CT 出生点，保证两阵营都有可用出生位置
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有按钮实体，防止触发地图机关
	for _, ent in pairs(ents.FindByClass("func_button")) do ent:Remove() end

	-- 收集地图上所有 T 阵营出生点
	local tsp = {}
	-- 收集地图上所有 CT 阵营出生点
	local ctsp = {}

	-- 遍历地图上的 T 阵营出生点
	for _, ent in pairs(ents.FindByClass("info_player_terrorist")) do
		-- 记录 T 出生点实体
		table.insert(tsp, ent)
	end

	-- 遍历地图上的 CT 阵营出生点
	for _, ent in pairs(ents.FindByClass("info_player_counterterrorist")) do
		-- 记录 CT 出生点实体
		table.insert(ctsp, ent)
	end

	-- 为每个 T 出生点生成对应的 CT 出生点（位置角度相同），供另一阵营使用
	for _, ent in pairs(tsp) do
		-- 创建 CT 阵营出生点实体
		local newent = ents.Create("info_player_counterterrorist")
		-- 仅在实体创建成功时继续设置
		if newent:IsValid() then
			-- 复制原出生点的位置
			newent:SetPos(ent:GetPos())
			-- 复制原出生点的角度
			newent:SetAngles(ent:GetAngles())
			-- 生成实体使其生效
			newent:Spawn()
		end
	end

	-- 为每个 CT 出生点生成对应的 T 出生点（位置角度相同），供另一阵营使用
	for _, ent in pairs(ctsp) do
		-- 创建 T 阵营出生点实体
		local newent = ents.Create("info_player_terrorist")
		-- 仅在实体创建成功时继续设置
		if newent:IsValid() then
			-- 复制原出生点的位置
			newent:SetPos(ent:GetPos())
			-- 复制原出生点的角度
			newent:SetAngles(ent:GetAngles())
			-- 生成实体使其生效
			newent:Spawn()
		end
	end

	-- 清理：删除原来的 T 出生点实体
	for _, ent in pairs(tsp) do
		ent:Remove()
	end

	-- 清理：删除原来的 CT 出生点实体
	for _, ent in pairs(ctsp) do
		ent:Remove()
	end
end)
