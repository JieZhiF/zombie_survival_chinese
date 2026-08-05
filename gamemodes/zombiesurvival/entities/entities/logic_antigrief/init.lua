-- ============================================================================
-- logic_antigrief/init.lua - 防恶意破坏控制逻辑实体（点实体）
-- 负责：通过 Hammer 输入 EnableThese/DisableThese 按实体名称批量
--       设置/清除实体的 m_AntiGrief 标记，控制场景物件是否受
--       防恶意破坏保护（阻止玩家恶意拆除他人建筑）
-- ============================================================================

-- 实体类型：点实体（纯逻辑控制，无渲染）
ENT.Type = "point"

-- ==== Initialize - 初始化（无额外处理） ====
function ENT:Initialize()
end

-- ==== Think - 每帧逻辑（无额外处理） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理 Hammer 输入 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- DisableThese：按逗号分隔的名称批量取消实体的防破坏标记
	if name == "disablethese" then
		for _, entname in pairs(string.Explode(",", args)) do
			for __, ent in pairs(self:FindByNameHammer(entname, activator, caller)) do
				ent.m_AntiGrief = nil
			end
		end
		return true
	-- EnableThese：按逗号分隔的名称批量启用实体的防破坏标记
	elseif name == "enablethese" then
		for _, entname in pairs(string.Explode(",", args)) do
			for __, ent in pairs(self:FindByNameHammer(entname, activator, caller)) do
				ent.m_AntiGrief = true
			end
		end
		return true
	end
end

-- ==== KeyValue - 读取 Hammer 实体属性（本实体无自定义属性） ====
function ENT:KeyValue(key, value)
end
