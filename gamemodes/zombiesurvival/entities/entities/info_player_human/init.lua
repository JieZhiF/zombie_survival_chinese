-- ============================================================================
-- info_player_human/init.lua - 人类出生点实体
-- 负责：定义人类阵营的出生点；支持通过 Hammer 键值（disabled/active）
--       或输入（enable/disable/toggle）控制出生点是否可用
-- ============================================================================
ENT.Type = "point"

-- ==== Initialize - 空实现：点实体无需初始化 ====
function ENT:Initialize()
end

-- ==== KeyValue - 键值处理：解析 Hammer 键值设置初始禁用状态 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- disabled=1 或 active=0 均表示出生点初始禁用
	if key == "disabled" then
		self.Disabled = tonumber(value) == 1
	elseif key == "active" then
		self.Disabled = tonumber(value) == 0
	end
end

-- ==== AcceptInput - 输入处理：响应 enable/disable/toggle 切换可用状态 ====
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
