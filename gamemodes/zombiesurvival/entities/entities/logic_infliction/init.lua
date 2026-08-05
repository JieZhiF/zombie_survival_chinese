-- ============================================================================
-- logic_infliction/init.lua - 感染值上限逻辑实体（服务器）
-- 负责：地图编辑用点实体，通过输入/键值调整 GAMEMODE.CappedInfliction
--       （全局感染值上限），并可转发 On* 输出
-- ============================================================================
ENT.Type = "point"

-- ==== Initialize - 初始化默认感染值上限（缺省 0.5） ====
function ENT:Initialize()
	self.Infliction = self.Infliction or 0.5
end

-- ==== Think - 空实现，保留 Think 接口 ====
function ENT:Think()
end

-- ==== AcceptInput - 处理实体输入：转发 On* 输出或修改感染值上限 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- 以 "on" 开头的输入直接作为输出转发给下游实体
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	-- capinfliction：仅当新值更大时才上调全局感染值上限
	elseif name == "capinfliction" then
		GAMEMODE.CappedInfliction = math.max(GAMEMODE.CappedInfliction, tonumber(args) or 0)
	-- setinfliction：直接设定全局感染值上限
	elseif name == "setinfliction" then
		GAMEMODE.CappedInfliction = tonumber(args) or 0
	end
end

-- ==== KeyValue - 解析 Hammer 键值：infliction 存属性，On* 存为输出 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- 键值 infliction 设置本实体的感染值上限（用于自定义行为）
	if key == "infliction" then
		self.Infliction = tonumber(value) or self.Infliction
	-- 以 "on" 开头的键值注册为实体输出
	elseif string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	end
end
