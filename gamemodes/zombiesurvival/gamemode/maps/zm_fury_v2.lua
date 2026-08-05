-- ============================================================================
-- zm_fury_v2.lua - zm_fury_v2 地图补丁 - 生成防爆门封堵通道
-- 负责：在坐标 (-48.8903, 1088.3591, -407.9688) 生成防爆门（blastdoor001a），
--       封堵可被玩家利用的通道，平衡攻守路线
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

		-- 在坐标 (-48.8903, 1088.3591, -407.9688) 生成防爆门（blastdoor001a），封堵通道
	local ent = ents.Create("prop_dynamic_override")
	if ent:IsValid() then
		ent:SetPos(Vector(-48.8903, 1088.3591, -407.9688))
		ent:SetKeyValue("solid", 6)
		ent:SetModel("models/props_lab/blastdoor001a.mdl")
		ent:Spawn()
	end
end)
