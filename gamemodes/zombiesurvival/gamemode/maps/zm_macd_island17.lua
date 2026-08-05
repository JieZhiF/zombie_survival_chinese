-- ============================================================================
-- zm_macd_island17.lua - zm_macd_island17 地图补丁 - 生成隐形防爆门封堵通道
-- 负责：在坐标 (236, 1427, 660.5) 生成防爆门（blastdoor001c）封堵可被利用的通道，
--       并将门设为全透明，仅保留碰撞体实现隐形封堵
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 在坐标 (236, 1427, 660.5) 生成防爆门（blastdoor001c），封堵可利用的通道
	local ent = ents.Create("prop_dynamic_override")
	if ent:IsValid() then
		ent:SetPos(Vector(236, 1427, 660.5))
		ent:SetAngles(Angle(90, 0, 0))
		ent:SetKeyValue("solid", "6")
		ent:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent:Spawn()
		-- 设为全透明，仅保留碰撞体实现隐形封堵
		ent:SetColor(Color(0, 0, 0, 0))
	end
end)
