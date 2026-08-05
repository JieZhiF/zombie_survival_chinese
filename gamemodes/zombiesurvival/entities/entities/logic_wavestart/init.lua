-- ============================================================================
-- logic_wavestart/init.lua - 波次开始逻辑实体
-- 负责：供地图作者使用的点实体：记录施加波次的数目（infliction）键值，
--       并将所有 "On*" 形式的输入直接转发为同名输出
-- ============================================================================
-- 点实体类型（地图中放置，无模型无碰撞）
ENT.Type = "point"

-- ==== Initialize - 初始化：补全 infliction 键值默认值 ====
function ENT:Initialize()
	self.Infliction = self.Infliction or 0
end

-- ==== Think - 空实现（点实体无需逐帧逻辑） ====
function ENT:Think()
end

-- ==== AcceptInput - 输入转发：以 "on" 开头的输入直接触发出同名输出 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- "On*" 前缀输入直接转发为输出（如 OnPress → 触发 OnPress 输出）
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	end
end

-- ==== KeyValue - 键值处理：读取 infliction 数值与 On* 输出绑定 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "infliction" then
		-- infliction：本次施加的波次数目（无效值回退为默认）
		self.Infliction = tonumber(value) or self.Infliction
	elseif string.sub(key, 1, 2) == "on" then
		-- On* 输出目标绑定（Hammer 中的输出连接）
		self:AddOnOutput(key, value)
	end
end
