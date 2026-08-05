-- ============================================================================
-- de_zentech_office.lua - 中枢科技办公室（Zentech Office）地图补丁
-- 负责：恢复物理道具默认碰撞组并移除按钮实体
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 将所有物理道具的碰撞组恢复为默认（COLLISION_GROUP_NONE），确保可正常碰撞
	for _, ent in pairs(ents.FindByClass("prop_physics*")) do ent:SetCollisionGroup(COLLISION_GROUP_NONE) end

	-- 移除所有按钮实体，防止触发地图机关
	for _, ent in pairs(ents.FindByClass("func_button")) do ent:Remove() end
end)
