-- ============================================================================
-- zs_sandtraps_v2.lua - 沙坑 地图补丁
-- 负责：生成一扇隐形防爆门封锁指定通道
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成隐形防爆门（纯黑全透明，仅保留碰撞阻挡）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(2360, -2724, 218))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
		ent2:SetColor(Color(0, 0, 0, 0))
	end
end)
