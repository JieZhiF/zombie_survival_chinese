-- ============================================================================
-- zs_tug_hut.lua - 拖车小屋（Tug Hut）地图补丁
-- 负责：生成两扇隐形防爆门封堵通道，并移除治疗充电器
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 第 1 扇隐形防爆门：封堵 (-890, 71, 140) 处的通道
	local ent = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent:IsValid() then
		-- 放置坐标：通道入口位置
		ent:SetPos(Vector(-890.3486, 71.1159, 140.0313))
		-- 朝向：绕 Z 轴旋转 90 度
		ent:SetAngles(Angle(0, 90, 0))
		-- 使用实验室防爆门模型
		ent:SetModel("models/props_lab/blastdoor001a.mdl")
		-- solid=6：静态实体，可阻挡玩家移动
		ent:SetKeyValue("solid", "6")
		-- 生成实体使其生效
		ent:Spawn()
	end

	-- 第 2 扇隐形防爆门：封堵 (-1083, -107, 140) 处的通道
	local ent = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent:IsValid() then
		-- 放置坐标：通道入口位置
		ent:SetPos(Vector(-1083.4521, -107.9099, 140.0313))
		-- 使用实验室防爆门模型
		ent:SetModel("models/props_lab/blastdoor001a.mdl")
		-- solid=6：静态实体，可阻挡玩家移动
		ent:SetKeyValue("solid", "6")
		-- 生成实体使其生效
		ent:Spawn()
	end

	-- 移除所有治疗充电器（item_healthcharger），防止无限治疗
	for _, ent in pairs(ents.FindByClass("item_healthcharger")) do
			-- 删除治疗充电器
			ent:Remove()
		end
	end
end)
