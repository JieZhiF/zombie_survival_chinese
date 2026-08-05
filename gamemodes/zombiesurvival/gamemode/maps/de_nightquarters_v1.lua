-- ============================================================================
-- de_nightquarters_v1.lua - 夜宿区 地图补丁
-- 负责：在指定位置生成持续燃烧的火焰，作为区域伤害源与视觉阻挡
-- ============================================================================
-- ==== InitPostEntityMap - 地图实体全部加载完成后执行 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 创建火焰实体：伤害倍率 30、火势大小 200
	local ent2 = ents.Create("env_fire")
	if ent2:IsValid() then
		ent2:SetPos(Vector(-341.7814, -380.7280, 345.9983))
		ent2:SetKeyValue("damagescale", 30)
		ent2:SetKeyValue("firesize", 200)
		ent2:Spawn()
		-- 先启用火焰，再延迟 0.1 秒点燃
		ent2:Fire("Enable", "", 0)
		ent2:Fire("StartFire", "", 0.1)
	end
end)
