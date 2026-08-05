-- ============================================================================
-- zs_stormiest_b1.lua - 暴风之最 地图补丁
-- 负责：移除地图上刷出的雷管与医疗包武器，并生成两扇隐形防爆门封锁通道
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除地图上所有刷出的雷管武器
	for _, ent in pairs(ents.FindByClass("weapon_zs_boomstick")) do ent:Remove() end
	-- 移除地图上所有刷出的医疗包武器
	for _, ent in pairs(ents.FindByClass("weapon_zs_medicalkit")) do ent:Remove() end

	-- 生成第一扇隐形防爆门（纯黑全透明，仅保留碰撞阻挡）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-2146, 1663, -625))
		ent2:SetAngles(Angle(0, 66, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:SetColor(Color(0, 0, 0, 0))
		ent2:Spawn()
	end
	-- 生成第二扇隐形防爆门（另一路口）
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-2226, 1781, -625))
		ent2:SetAngles(Angle(0, 0, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:SetColor(Color(0, 0, 0, 0))
		ent2:Spawn()
	end
end)
