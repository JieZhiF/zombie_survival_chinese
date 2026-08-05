-- ============================================================================
-- zs_obj_mental_hospital_v6.lua - 精神病院 v6（Mental Hospital v6）地图补丁
-- 负责：在武器实体布置阶段移除地图上散落的霰弹枪，防止前期获得强力武器
-- ============================================================================
-- ==== SetupProps 钩子（RemoveBoomstick）- 武器实体布置完成后移除霰弹枪 ====
hook.Add("SetupProps", "RemoveBoomstick", function()
	-- 遍历地图上所有散落的武器实体
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do
		-- 仅处理霰弹枪（Boomstick）类型：该武器前期过强，禁止在地图上出现
		if ent:GetWeaponType() == "weapon_zs_boomstick" then
			-- 删除该霰弹枪实体
			ent:Remove()
		end
	end
end)
