-- ============================================================================
-- zs_town_b1_7.lua - zs_town_b1_7 地图补丁 - 移除可剥削的门并补防爆门
-- 负责：移除指定位置附近的旋转门（func_door_rotating）与全部滑动门
--       （func_movelinear），防止门被利用卡位；随后生成一扇防爆门
--       （blastdoor001c）补全被移除门后的防守路线
-- ============================================================================
-- ==== InitPostEntityMap - 地图加载完成后执行本图补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
		-- 移除坐标 (1736.2645, -1860.0313, -525.5502) 附近 32 单位内的旋转门，堵住可利用的门缝
	for _, ent in pairs(ents.FindInSphere(Vector(1736.2645, -1860.0313, -525.5502), 32)) do
		if ent:GetClass() == "func_door_rotating" then ent:Remove() end
	end

		-- 移除地图全部滑动门（func_movelinear），防止其被用于堵路或卡位
	for _, ent in pairs(ents.FindByClass("func_movelinear")) do
		ent:Remove()
	end

		-- 在坐标 (1120.2247, -2566.5984, -263.9688) 生成防爆门（blastdoor001c），补全防守位
	local ent2 = ents.Create("prop_dynamic_override")
	if ent2:IsValid() then
		ent2:SetPos(Vector(1120.2247, -2566.5984, -263.9688))
		ent2:SetAngles(Angle(0, 90, 0))
		ent2:SetKeyValue("solid", "6")
		ent2:SetModel(Model("models/props_lab/blastdoor001c.mdl"))
		ent2:Spawn()
	end
end)
