-- ============================================================================
-- logic_waves/init.lua - 波次控制逻辑实体
-- 负责：供地图作者使用的点实体：通过输入（advancewave/startwave/setwave
--       等）操控游戏模式波次状态，并将 "On*" 输入转发为输出
-- ============================================================================
-- 点实体类型（地图中放置，无模型无碰撞）
ENT.Type = "point"

-- ==== Initialize - 初始化：补全 wave 键值默认值 ====
function ENT:Initialize()
	self.Wave = self.Wave or -1
end

-- ==== Think - 空实现（点实体无需逐帧逻辑） ====
function ENT:Think()
end

-- ==== AcceptInput - 波次控制输入：处理各波次命令并转发 On* 输出 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if string.sub(name, 1, 2) == "on" then
		-- "On*" 前缀输入直接转发为输出
		self:FireOutput(name, activator, caller, args)
	elseif name == "advancewave" then
		-- 推进波次：结束当前波并立即开始下一波
		gamemode.Call("SetWaveActive", false)
		gamemode.Call("SetWaveStart", CurTime())
		return true
	elseif name == "endwave" then
		-- 结束当前波次
		gamemode.Call("SetWaveEnd", CurTime())
		return true
	elseif name == "setwave" then
		-- 设置当前波次编号（参数无效时默认第 1 波）
		gamemode.Call("SetWave", tonumber(args) or 1)
		return true
	elseif name == "setwaves" then
		-- 设置总波次数（参数无效时回退为游戏默认）
		SetGlobalInt("numwaves", tonumber(args) or GAMEMODE.NumberOfWaves)
		return true
	elseif name == "startwave" then
		-- 立即开始当前波次
		gamemode.Call("SetWaveStart", CurTime())
		return true
	elseif name == "setwavestart" then
		-- 设置波次开始时间：-1 表示立刻，正数表示相对当前时刻的延迟秒数
		local time = tonumber(args) or 0
		gamemode.Call("SetWaveStart", time == -1 and time or (CurTime() + time))
		return true
	elseif name == "setwaveend" then
		-- 设置波次结束时间：-1 表示立刻，正数表示相对当前时刻的延迟秒数
		local time = tonumber(args) or 0
		gamemode.Call("SetWaveEnd", time == -1 and time or (CurTime() + time))
		return true
	end
end

-- ==== KeyValue - 键值处理：读取 wave 数值与 On* 输出绑定 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if string.sub(key, 1, 2) == "on" then
		-- On* 输出目标绑定（Hammer 中的输出连接）
		self:AddOnOutput(key, value)
	elseif key == "wave" then
		-- wave：实体关注的波次编号（无效值回退为 -1）
		self.Wave = tonumber(value) or -1
	end
end
