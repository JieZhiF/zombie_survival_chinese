-- ============================================================================
-- cs_deadhouse.lua - CS 死亡之屋（Deadhouse）地图补丁
-- 负责：在门洞位置生成电锯锯片实体作阻挡
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 生成锯片模型实体，用作门洞阻挡或装饰
	local ent = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent:IsValid() then
		-- 放置坐标：门洞位置
		ent:SetPos(Vector(-905, 99, 128))
		-- 朝向：竖直放置（角度 (0, 90, 90)）
		ent:SetAngles(Angle(0,90,90))
		-- solid=6：静态实体，可阻挡玩家移动
		ent:SetKeyValue("solid", "6")
		-- 使用电锯锯片模型
		ent:SetModel(Model("models/props_junk/sawblade001a.mdl"))
		-- 生成实体使其生效
		ent:Spawn()
	end
end)
