-- ============================================================================
-- info_player_zombie/init.lua - 僵尸出生点实体
-- 负责：供地图作者放置的僵尸队伍出生点：通过键值/输入控制该出生点的
--       启用状态（disabled/active/enable/disable/toggle）
-- ============================================================================
-- 点实体类型（地图中放置，无模型无碰撞）
ENT.Type = "point"

-- ==== Initialize - 空实现（出生点本身无初始化逻辑） ====
function ENT:Initialize()
end

-- ==== Think - 空实现（出生点无需逐帧逻辑） ====
function ENT:Think()
end

-- ==== KeyValue - 键值处理：读取 disabled/active 键值设置启用状态 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "disabled" then
		-- disabled=1：禁用该出生点
		self.Disabled = tonumber(value) == 1
	elseif key == "active" then
		-- active=0：禁用该出生点（active=1 则为启用）
		self.Disabled = tonumber(value) == 0
	end
end

-- ==== AcceptInput - 输入处理：enable/disable/toggle 控制出生点启用状态 ====
function ENT:AcceptInput(name, activator, caller, arg)
	name = string.lower(name)
	if name == "enable" then
		-- 启用出生点
		self.Disabled = false
		return true
	elseif name == "disable" then
		-- 禁用出生点
		self.Disabled = true
		return true
	elseif name == "toggle" then
		-- 切换启用状态
		self.Disabled = not self.Disabled
		return true
	end
end
