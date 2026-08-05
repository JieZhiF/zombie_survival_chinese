-- ============================================================================
-- init.lua - 点数逻辑实体（服务器）：供地图增删/查询/条件判断人类点数
-- 负责：处理 add/take/set/条件比较等地图输入，并把输出重定向到 on* 输出
-- ============================================================================
-- 点实体类型（无模型，纯逻辑）
ENT.Type = "point"

-- ==== Add - 增删点数：仅对人类玩家生效，负数扣点、正数加点 ====
function ENT:Add(pl, amount)
	if pl and pl:IsValidHuman() then
		if amount < 0 then
			amount = math.Round(amount)
			pl:TakePoints(-amount)
		else
			pl:AddPoints(amount)
		end
	end
end

-- ==== Set - 设定点数：仅对人类玩家生效 ====
function ENT:Set(pl, amount)
	if pl and pl:IsValidHuman() then
		self:SetAmount(pl, amount)
	end
end

-- ==== SetAmount - 直接写入玩家点数 ====
function ENT:SetAmount(pl, amount)
	pl:SetPoints(amount)
end

-- ==== GetAmount - 读取玩家当前点数 ====
function ENT:GetAmount(pl)
	return pl:GetPoints()
end

-- ==== CallIf - 条件判断：人类且点数足够触发 onconditionpassed，否则 onconditionfailed ====
function ENT:CallIf(pl, amount)
	if pl and pl:IsValidPlayer() then
		self:Input(pl:Team() == TEAM_HUMAN and self:GetAmount(pl) >= amount and "onconditionpassed" or "onconditionfailed", pl, self, amount)
	end
end

-- ==== CallIfNot - 反向条件判断：人类且点数不足时触发 onconditionpassed ====
function ENT:CallIfNot(pl, amount)
	if pl and pl:IsValidPlayer() then
		self:Input(pl:Team() == TEAM_HUMAN and self:GetAmount(pl) >= amount and "onconditionfailed" or "onconditionpassed", pl, self, amount)
	end
end

-- ==== AcceptInput - 地图输入处理：按输入名分派加/减/设/条件比较操作 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	local amount = tonumber(args) or 0
	-- 以 on 开头的输入名是输出重定向，直接转发
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	elseif name == "addtoactivator" then
		-- 给触发者加点
		self:Add(activator, amount)
	elseif name == "takefromactivator" then
		-- 从触发者扣点
		self:Add(activator, -amount)
	elseif name == "addtocaller" then
		-- 给调用者加点
		self:Add(caller, amount)
	elseif name == "takefromcaller" then
		-- 从调用者扣点
		self:Add(caller, -amount)
	elseif name == "callifactivatorhave" then
		-- 若触发者拥有足够点数则通过
		self:CallIf(activator, amount)
	elseif name == "callifactivatornothave" then
		-- 若触发者点数不足则通过
		self:CallIfNot(activator, amount)
	elseif name == "callifcallerhave" then
		-- 若调用者拥有足够点数则通过
		self:CallIf(caller, amount)
	elseif name == "callifcallernothave" then
		-- 若调用者点数不足则通过
		self:CallIfNot(caller, amount)
	elseif name == "setactivatoramount" then
		-- 设定触发者的点数
		self:Set(activator, amount)
	elseif name == "setcalleramount" then
		-- 设定调用者的点数
		self:Set(caller, amount)
	end
end

-- ==== KeyValue - Hammer 键值处理：把 on* 输出映射到 FireOutput 实体 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	end
end
