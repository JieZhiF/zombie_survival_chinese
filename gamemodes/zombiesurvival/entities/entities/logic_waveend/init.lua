-- ============================================================================
-- init.lua - 波次结束逻辑实体（服务器）：存储感染度阈值并转发输出
-- 负责：供地图记录所需感染度（Infliction）键值，并把 on* 输入转发为输出
-- ============================================================================
-- 点实体类型（无模型，纯逻辑）
ENT.Type = "point"

-- ==== Initialize - 初始化：补全感染度阈值的默认值 ====
function ENT:Initialize()
	self.Infliction = self.Infliction or 0
end

-- ==== Think - 空实现：本实体不执行周期逻辑 ====
function ENT:Think()
end

-- ==== AcceptInput - 地图输入处理：以 on 开头的输入直接转发为输出 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	end
end

-- ==== KeyValue - Hammer 键值处理：读取感染度阈值与 on* 输出映射 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "infliction" then
		-- 感染度阈值：感染度达到该比例时用于地图判断
		self.Infliction = tonumber(value) or self.Infliction
	elseif string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	end
end
