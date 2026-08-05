-- ============================================================================
-- logic_experience - 经验倍率逻辑实体（点实体）
-- 负责：通过 Hammer 键值或输入动态设置人类与僵尸阵营的经验倍率
-- ============================================================================

-- 实体类型：点实体
ENT.Type = "point"

-- ==== Initialize - 空实现 ====
function ENT:Initialize()
end

-- ==== Think - 空实现 ====
function ENT:Think()
end

-- ==== AcceptInput - 处理 sethumanxpmulti/setzombiexpmulti 输入：动态改写对应键值 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "sethumanxpmulti" then
		self:SetKeyValue("humanxpmulti", args)

		return true
	elseif name == "setzombiexpmulti" then
		self:SetKeyValue("zombiexpmulti", args)

		return true
	end
end

-- ==== KeyValue - 解析 Hammer 键值：设置人类/僵尸经验倍率（负数归零，无效值回退为 1） ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "humanxpmulti" then
		GAMEMODE.HumanXPMulti = math.max(0, tonumber(value)) or 1
	elseif key == "zombiexpmulti" then
		GAMEMODE.ZombieXPMulti = math.max(0, tonumber(value)) or 1
	end
end
