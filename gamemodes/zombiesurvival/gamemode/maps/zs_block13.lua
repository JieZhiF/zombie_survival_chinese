-- ============================================================================
-- zs_block13.lua - 13 号街区（Block 13）地图补丁
-- 负责：生成隐形防爆门封堵通道，并隐藏其渲染
-- ============================================================================
-- ==== InitPostEntityMap 钩子 - 地图实体加载完成后执行补丁 ====
hook.Add("InitPostEntityMap", "Adding", function()
	-- 生成防爆门，封堵 (-320, -502, 139) 处的通道
	local ent = ents.Create("prop_dynamic_override")
	-- 仅在实体创建成功时继续设置
	if ent:IsValid() then
		-- 放置坐标：通道入口位置
		ent:SetPos(Vector(-320.409821, -502.737671, 139.487274))
		-- 朝向：绕 Z 轴旋转 90 度
		ent:SetAngles(Angle(0, 90, 0))
		-- solid=6：静态实体，可阻挡玩家移动
		ent:SetKeyValue("solid", "6")
		-- 使用实验室防爆门模型
		ent:SetModel("models/props_lab/blastdoor001c.mdl")
		-- 生成实体使其生效
		ent:Spawn()
		-- 设置不渲染：门完全隐形，仅保留碰撞阻挡
		ent:SetNoDraw(true)
	end
end)
