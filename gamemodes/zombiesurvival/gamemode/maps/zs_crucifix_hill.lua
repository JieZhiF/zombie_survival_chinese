-- ============================================================================
-- zs_crucifix_hill.lua - 十字架山（Crucifix Hill）地图补丁
-- 负责：锁定全部僵尸职业，强制使用经典僵尸（Classic Zombie）职业
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 创建职业锁定逻辑实体，用于限制本图可选职业
	local ent = ents.Create("logic_classunlock")
	-- 仅在实体创建成功时继续设置
	if ent:IsValid() then
		-- 生成实体使其生效
		ent:Spawn()
		-- 锁定所有职业，禁止玩家选择其他僵尸职业
		ent:Fire("lockclass", "all", 0)
		-- 将默认职业设为经典僵尸（Classic Zombie）
		ent:Fire("defaultclass", "classic zombie", 0)
	end
end)
