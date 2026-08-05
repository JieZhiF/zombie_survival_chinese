-- ============================================================================
-- init.lua - 僵尸 BOSS 出生点（服务器）：启用/禁用开关
-- 负责：通过键值与输入控制出生点是否启用（供脚本动态管理 BOSS 刷新）
-- ============================================================================
ENT.Type = "point"

-- ==== Initialize - 初始化：无需逻辑 ====
function ENT:Initialize()
end

-- ==== KeyValue - 解析键值：disabled/active 设置启用状态 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "disabled" then
		self.Disabled = tonumber(value) == 1
	elseif key == "active" then
		self.Disabled = tonumber(value) == 0
	end
end

-- ==== AcceptInput - 输入控制：enable/disable/toggle 切换启用状态 ====
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
