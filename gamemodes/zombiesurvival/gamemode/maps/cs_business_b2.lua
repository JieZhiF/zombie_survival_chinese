-- ============================================================================
-- cs_business_b2.lua - cs_business_b2 地图补丁 - 生成五扇隐形防爆门封堵出入口
-- 负责：在办公楼的五个出入口位置生成防爆门（blastdoor001c）并全部设为
--       全透明，仅保留碰撞体实现隐形封堵，防止玩家进出/卡位
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 在坐标 (-413.3240, 2016.3511, 247.6189) 生成隐形防爆门，封堵出入口
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-413.3240, 2016.3511, 247.6189))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		-- 设为全透明，仅保留碰撞体实现隐形封堵
		ent2:SetColor(Color(0, 0, 0, 0))
	end

		-- 在坐标 (-413.3240, 2016.3511, 354.1814) 生成隐形防爆门，封堵出入口
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-413.3240, 2016.3511, 354.1814))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		-- 设为全透明，仅保留碰撞体实现隐形封堵
		ent2:SetColor(Color(0, 0, 0, 0))
	end

		-- 在坐标 (1141.4768, 2121.8750, 128.0313) 生成隐形防爆门，封堵出入口
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(1141.4768, 2121.8750, 128.0313))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		-- 设为全透明，仅保留碰撞体实现隐形封堵
		ent2:SetColor(Color(0, 0, 0, 0))
	end

		-- 在坐标 (-502.0918, 2096.4048, 128.0313) 生成隐形防爆门，封堵出入口
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-502.0918, 2096.4048, 128.0313))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		-- 设为全透明，仅保留碰撞体实现隐形封堵
		ent2:SetColor(Color(0, 0, 0, 0))
	end

		-- 在坐标 (-332.6040, 2233.0410, 128.0313) 生成隐形防爆门，封堵出入口
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-332.6040, 2233.0410, 128.0313))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		-- 设为全透明，仅保留碰撞体实现隐形封堵
		ent2:SetColor(Color(0, 0, 0, 0))
	end
end)
