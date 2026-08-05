-- ============================================================================
-- info_player_zombie_boss/init.lua - 僵尸 Boss 出生点（地图实体）
-- 负责：地图放置的 Boss 出生点标记；通过 keyvalue 与输入（enable/disable/
--       toggle）控制是否启用，供僵尸 Boss 波次选择出生点使用
-- ============================================================================
-- 点实体类型，无物理模型
ENT.Type = "point"

-- ==== Initialize - 初始化：空实现（占位） ====
function ENT:Initialize()
end

-- ==== KeyValue - 键值解析：由 Hammer 的 disabled/active 键设定启用状态 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "disabled" then
		self.Disabled = tonumber(value) == 1
	elseif key == "active" then
		self.Disabled = tonumber(value) == 0
	end
end

-- ==== AcceptInput - 输入处理：支持 enable/disable/toggle 切换启用状态 ====
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
