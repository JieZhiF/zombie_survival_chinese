-- ============================================================================
-- zm_crazycity.lua - 疯狂城市 地图补丁
-- 负责：生成一辆轿车作为掩体/障碍，并打开后销毁所有旋转门（防堵路）
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 生成轿车道具（物理碰撞），作为掩体或障碍
	local ent = ents.Create("prop_dynamic_override")
	if ent:IsValid() then
		ent:SetModel("models/props_vehicles/car005b_physics.mdl")
		ent:SetPos(Vector(1121, 862, 80))
		ent:SetAngles(Angle(0, 180, 0))
		ent:SetKeyValue("solid", SOLID_VPHYSICS)
		ent:Spawn()
	end

	-- 先打开所有旋转门，再延迟 0.5 秒销毁，彻底移除门
	for _, ent in pairs(ents.FindByClass("func_door_rotating")) do
		ent:Fire("open", "", 0)
		ent:Fire("kill", "", 0.5)
	end
end)
