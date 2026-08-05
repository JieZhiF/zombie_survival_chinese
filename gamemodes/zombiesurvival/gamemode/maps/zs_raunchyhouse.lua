-- ============================================================================
-- zs_raunchyhouse.lua - 下流屋（Raunchy House）地图补丁
-- 负责：保留门结构不被破坏，移除高处出生点，并用障碍物封堵门洞
-- ============================================================================
-- ==== InitPostEntityMap 钩子（DestroyDoor 标识）- 地图实体加载后调整门与出生点 ====
hook.Add("InitPostEntityMap", "DestroyDoor", function()
	-- 关闭门破坏开关：禁止游戏模式破坏道具门（遗留标记，仅本文件写入）
	DESTROY_PROP_DOORS = false
	-- 关闭门破坏开关：禁止游戏模式破坏普通门（遗留标记，仅本文件写入）
	DESTROY_DOORS = false
	-- 查找地图上的所有旋转道具门
	local doors = ents.FindByClass("prop_door_rotating")
	-- 若存在第二扇门则将其移除（只保留一个出入口）
	if doors[2] then
		-- 删除第二扇旋转门
		doors[2]:Remove()
	end

	-- 调整出生点：移除高处出生位置，防止玩家出生在高处捷径
	for _, ent in pairs(ents.FindByClass("gmod_player_start")) do
		-- 高度大于 -440 的出生点将被删除
		if ent:GetPos().z > -440 then
			-- 删除高处出生点
			ent:Remove()
		end
	end

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 障碍 1：厨房置物架封堵门洞底部
		ent2:SetPos(Vector(2946.4270, -2783.7803, -439.9688))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用厨房置物架模型
		ent2:SetModel(Model("models/props_wasteland/kitchen_shelf001a.mdl"))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 障碍 2：煤渣砖块封堵门洞中部（叠在置物架上方）
		ent2:SetPos(Vector(2946.7278, -2781.4426, -407.3824 + 6))
		-- 朝向：倾斜放置以贴合门洞
		ent2:SetAngles(Angle(0, 50, 90))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用煤渣砖块模型
		ent2:SetModel(Model("models/props_junk/CinderBlock01a.mdl"))
		-- 生成实体使其生效
		ent2:Spawn()
	end

	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 障碍 3：煤渣砖块封堵门洞上部
		ent2:SetPos(Vector(2946.5017, -2783.1523, -343.4822 + 6))
		-- 朝向：竖直放置
		ent2:SetAngles(Angle(0, 90, 90))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用煤渣砖块模型
		ent2:SetModel(Model("models/props_junk/CinderBlock01a.mdl"))
		-- 生成实体使其生效
		ent2:Spawn()
	end
end)
