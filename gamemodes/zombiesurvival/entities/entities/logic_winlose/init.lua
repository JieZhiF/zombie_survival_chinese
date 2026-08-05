-- ============================================================================
-- logic_winlose/init.lua - 胜负逻辑实体
-- 负责：地图触发器控制回合胜利/失败，以及结局慢动作/相机/音乐的覆写
-- ============================================================================

ENT.Type = "point"

-- ==== Initialize - 初始化 ====
-- 点实体无需初始化逻辑
function ENT:Initialize()
end

-- ==== Think - 每帧逻辑 ====
-- 无每帧逻辑
function ENT:Think()
end

-- ==== AcceptInput - 输入处理 ====
-- 响应 Win/Lose/SetEnd* 等输入：触发输出或设置全局结局覆写
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- 以 "on" 开头的输入视为输出事件，直接转发
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
		return true
	-- 触发人类胜利，结束当前回合
	elseif name == "win" then
		gamemode.Call("EndRound", TEAM_HUMAN)
		return true
	-- 触发僵尸胜利，结束当前回合
	elseif name == "lose" then
		gamemode.Call("EndRound", TEAM_UNDEAD)
		return true
	-- 设置结局是否使用慢动作
	elseif name == "setendslomo" then
		self:SetKeyValue("endslomo", args)
		return true
	-- 设置结局是否使用特定相机
	elseif name == "setendcamera" then
		self:SetKeyValue("endcamera", args)
		return true
	-- 设置结局相机位置
	elseif name == "setendcamerapos" then
		self:SetKeyValue("endcamerapos", args)
		return true
	-- 设置胜利音乐
	elseif name == "setwinmusic" then
		self:SetKeyValue("winmusic", args)
		return true
	-- 设置失败音乐
	elseif name == "setlosemusic" then
		self:SetKeyValue("losemusic", args)
		return true
	end
end

-- ==== KeyValue - 键值处理 ====
-- 解析地图实体键值：输出定义与结局相关全局覆写
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- "on" 前缀键为输出定义，注册到输出系统
	if string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	-- 覆写结局慢动作开关
	elseif key == "endslomo" then
		GAMEMODE.OverrideEndSlomo = value == "1"
	-- 覆写结局相机开关（全局网络变量）
	elseif key == "endcamera" then
		SetGlobalBool("endcamera", value == "1")
	-- 覆写结局相机位置（全局网络变量）
	elseif key == "endcamerapos" then
		SetGlobalVector("endcamerapos", Vector(value))
	-- 覆写胜利音乐（"default" 表示恢复默认）
	elseif key == "winmusic" then
		if value == "default" then
			SetGlobalString("winmusic", nil)
		else
			SetGlobalString("winmusic", value)
		end
	-- 覆写失败音乐（"default" 表示恢复默认）
	elseif key == "losemusic" then
		if value == "default" then
			SetGlobalString("losemusic", nil)
		else
			SetGlobalString("losemusic", value)
		end
	end
end
