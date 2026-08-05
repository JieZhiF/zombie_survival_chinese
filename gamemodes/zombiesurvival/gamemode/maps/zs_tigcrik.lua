-- ============================================================================
-- zs_tigcrik.lua - Tigcrik 地图补丁
-- 负责：生成隐形防爆门，封堵 (-969, 1039, 438) 处的通道
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成隐形防爆门（prop_dynamic_override），用于封堵地图通道
	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 放置坐标：通道入口位置
		ent2:SetPos(Vector(-969, 1039, 438))
		-- 朝向：绕 Z 轴旋转 90 度
		ent2:SetAngles(Angle(0, 90, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		-- 生成实体使其生效
		ent2:Spawn()
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
	end
end)
