-- ============================================================================
-- zm_ghs_abdandon_mall.lua - GHS 废弃商场（Abdandon Mall）地图补丁
-- 负责：生成隐形防爆门封堵入口，并移除传送触发器
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成隐形防爆门，封堵 (707, 1355, 16) 处的入口
	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 放置坐标：商场入口位置
		ent2:SetPos(Vector(707, 1355, 16))
		-- 使用物理实体碰撞模式（SOLID_VPHYSICS），参与物理碰撞
		ent2:SetKeyValue("solid", SOLID_VPHYSICS)
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001b.mdl"))
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	-- 移除所有传送触发器，防止玩家被传送到非预期区域
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do ent:Remove() end
end)
