-- ============================================================================
-- info_player_undead/init.lua - 僵尸出生点实体
-- 负责：处理出生点的禁用/启用/切换输入，供地图与逻辑实体控制僵尸出生
-- ============================================================================

ENT.Type = "point"

-- ==== Initialize - 初始化 ====
-- 出生点实体无需初始化逻辑
function ENT:Initialize()
end

-- ==== KeyValue - 实体键值处理 ====
-- 解析 Hammer 实体键值，将 disabled/active 键映射为禁用状态
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- disabled=1 表示禁用；active=1 表示启用
	if key == "disabled" then
		self.Disabled = tonumber(value) == 1
	elseif key == "active" then
		self.Disabled = tonumber(value) == 0
	end
end

-- ==== AcceptInput - 输入处理 ====
-- 响应 Enable/Disable/Toggle 输入，返回 true 表示已处理
function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	-- 启用出生点
	if name == "enable" then
		self.Disabled = false
		return true
	-- 禁用出生点
	elseif name == "disable" then
		self.Disabled = true
		return true
	-- 反转出生点启用状态
	elseif name == "toggle" then
		self.Disabled = not self.Disabled
		return true
	end
end
