-- ============================================================================
-- init.lua - 赎罪玩家出生点（可选）
-- 负责：地图上的点实体，供赎罪（Redeemed）玩家出生，可通过 KV/输入控制启用状态
-- ============================================================================
-- 点实体类型（无模型无物理）
ENT.Type = "point"

-- ==== Initialize - 初始化 ====
-- 点实体无需初始化逻辑，空实现保持钩子存在
function ENT:Initialize()
end

-- ==== KeyValue - 解析 Hammer 键值 ====
-- 支持 disabled/active 两种键值，均折算为禁用标志（disabled=1 或 active=0 时禁用）
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "disabled" then
		self.Disabled = tonumber(value) == 1
	elseif key == "active" then
		self.Disabled = tonumber(value) == 0
	end
end

-- ==== AcceptInput - 响应 Enable/Disable/Toggle 输入 ====
-- 供地图逻辑实体切换该出生点的可用状态，返回 true 表示输入已被处理
function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	if name == "enable" then
		self.Disabled = false
		return true
	elseif name == "disable" then
		self.Disabled = true
		return true
	elseif name == "toggle" then
		self.Disabled = not self.Disabled
		return true
	end
end
