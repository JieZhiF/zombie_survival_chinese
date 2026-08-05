-- ============================================================================
-- zs_darkvilla.lua - 黑暗别墅（Dark Villa）地图补丁
-- 负责：移除传送触发器与按钮，将动态道具改为物理道具，并生成隐形防爆门封路
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	

	-- 移除所有传送触发器，防止玩家被传送到非预期区域
	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Remove()
	end

	-- 移除所有按钮实体，防止触发地图机关
	for _, ent in pairs(ents.FindByClass("func_button")) do
		ent:Remove()
	end

	-- 将地图动态道具替换为物理道具：保留外观的同时允许被物理交互推动
	for _, ent in pairs(ents.FindByClass("prop_dynamic")) do
		-- 按原动态道具创建物理道具实体
		local pro = ents.Create("prop_physics")
		-- 仅在实体创建成功时继续设置
		if pro:IsValid() then
			-- 复制原道具的模型
			pro:SetModel(ent:GetModel())
			-- 复制原道具的位置
			pro:SetPos(ent:GetPos())
			-- 复制原道具的角度
			pro:SetAngles(ent:GetAngles())
			-- 生成物理道具使其生效
			pro:Spawn()
			-- 删除原动态道具，避免重复
			ent:Remove()
		end
	end

	-- 生成隐形防爆门，封堵 (900, -228, -151) 处的缺口
	local ent2 = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent2:IsValid() then
		-- 放置坐标
		ent2:SetPos(Vector(900, -228, -151))
		-- 朝向：绕 Z 轴旋转 180 度
		ent2:SetAngles(Angle(0, 180, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent2:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent2:SetModel(Model("models/props_lab/blastdoor001b.mdl"))
		-- 全透明颜色：门不可见但可阻挡
		ent2:SetColor(Color(0, 0, 0, 0))
		-- 生成实体使其生效
		ent2:Spawn()
	end
end)
