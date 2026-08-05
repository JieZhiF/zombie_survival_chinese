-- ============================================================================
-- zs_bunker.lua - 地堡 地图补丁
-- 负责：在地堡指定入口生成一扇防爆门作为障碍物，封堵通行路线
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成防爆门（实验室防爆门模型，solid=6 启用物理碰撞）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(953.7239, -1549.8622, 128.0313))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel("models/props_lab/blastdoor001c.mdl")
		ent2:Spawn()
	end
end)
