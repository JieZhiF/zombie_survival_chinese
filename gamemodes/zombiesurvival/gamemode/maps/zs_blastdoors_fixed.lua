-- ============================================================================
-- zs_blastdoors_fixed.lua - 防爆门修复版（Blastdoors Fixed）地图补丁
-- 负责：生成四扇隐形防爆门封堵四个通道，并打碎残留可破坏物
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 第 1 扇隐形防爆门：封堵 X=-255 方向的通道，位于入口坐标
		ent2:SetPos(Vector(-255, 1215+53, 448))
		-- 朝向：门面沿 X 轴翻转放置
		ent2:SetAngles(Angle(90, 270, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 第 2 扇隐形防爆门：封堵 X=0 方向的通道，位于入口坐标
		ent2:SetPos(Vector(0, 1215+53, 448))
		-- 朝向：门面沿 X 轴翻转放置
		ent2:SetAngles(Angle(90, 270, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 第 3 扇隐形防爆门：封堵 Y=575 方向的通道，位于入口坐标
		ent2:SetPos(Vector(-512-53, 575, 448))
		-- 朝向：门面垂直于通道放置
		ent2:SetAngles(Angle(90, 0, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 第 4 扇隐形防爆门：封堵 Y=830 方向的通道，位于入口坐标
		ent2:SetPos(Vector(-512-53, 830, 448))
		-- 朝向：门面垂直于通道放置
		ent2:SetAngles(Angle(90, 0, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	-- 打碎地图上所有可破坏物，清除可能堵路的残骸
	for _, ent in pairs(ents.FindByClass("func_breakable")) do
		-- 触发 Break 输出，打碎可破坏物
		ent:Fire("Break", "", 0)
	end
	
	-- 打碎名为 blastdoor2 的残留门，防止其阻挡新生成的通道
	for _, ent in pairs(ents.FindByName("blastdoor2")) do
		-- 触发 Break 输出，打碎残留门
		ent:Fire("Break", "", 0)
	end
end)
