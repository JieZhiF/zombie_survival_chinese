-- ============================================================
-- 文件: sv_profiling.lua
-- 作用: 服务端脚本
-- 功能: 分析器(Profiler)系统
--       在地图上动态生成或加载一组节点（位置点）
--       用于作为僵尸刷新点、玩家目标点或路径点
--       支持自动学习（通过观察玩家位置）和加载预设节点
-- ============================================================

-- 以下是本文件中所有全局变量、函数和钩子的简要说明：
-- GM.ProfilerNodes —— 存储当前地图所有已加载/已生成的节点坐标
-- GM.ProfilerFolder —— 自动生成节点文件的存放目录
-- GM.ProfilerFolderPreMade —— 预设（手动放置）节点文件的存放目录
-- GM.ProfilerVersion —— 节点数据文件的版本号（兼容性检查）
-- GM.MaxProfilerNodes —— 允许自动生成的最大节点数量
-- ZSProfiler (Initialize) —— 在初始化时创建节点文件目录
-- GM:ClearProfiler —— 清除（保存）当前分析器节点数据
-- GM:SaveProfilerPreMade —— 保存预设节点文件
-- GM:DeleteProfilerPreMade —— 删除当前地图的预设节点文件
-- GM:SaveProfiler —— 保存自动生成的节点数据
-- FetchNodes —— 处理从网络 URL 下载的节点数据
-- GM:LoadNodeProfile —— 加载并验证节点数据（含版本检查）
-- GM:LoadProfiler —— 加载自动生成的节点文件
-- GM:GetProfilerFile —— 获取自动生成节点文件的完整路径
-- GM:GetProfilerFilePreMade —— 获取预设节点文件的完整路径
-- GM:ProfilerEnabled —— 检查分析器是否应在当前模式下启用
-- GM:NeedsProfiling —— 检查是否需要继续添加新节点
-- GM:DebugProfiler —— 在地图上可视化显示所有节点位置
-- SkewedDistance —— 自定义距离计算（Z 轴带有权重因子）
-- GM:ProfilerPlayerValid —— 核心验证函数，判断玩家位置是否适合作为新节点
-- GM:ProfilerTick —— 分析器主逻辑循环，定期收集有效玩家位置作为节点
-- ZSProfiler (Timer) —— 创建定时器周期性执行 ProfilerTick
-- ZSProfiler (OnWaveStateChanged) —— 波次开始后停止节点收集

-- ============================================================
-- 全局配置变量
-- 控制分析器的行为、数据存储路径和容量限制
-- ============================================================

-- 节点列表：存储地图上所有自动或手动生成的节点位置
GM.ProfilerNodes = {}
-- 自动生成节点文件的存放目录名
GM.ProfilerFolder = "zsprofiler"
-- 预设（手动放置）节点文件的存放目录名
GM.ProfilerFolderPreMade = "profiler_premade"
-- 节点数据版本号，用于兼容性检查
GM.ProfilerVersion = 0
-- 允许自动生成的最大节点数量
GM.MaxProfilerNodes = 128

-- ============================================================
-- 初始化 Hook：创建必要的文件目录
-- 在游戏初始化时创建自动节点和预设节点的存储目录
-- ============================================================
hook.Add("Initialize", "ZSProfiler", function()
	-- 创建自动生成节点文件的目录
	file.CreateDir(GAMEMODE.ProfilerFolder)
	-- 创建预设节点文件的目录
	file.CreateDir(GAMEMODE.ProfilerFolderPreMade)
end)

-- ============================================================
-- 初始化阶段：尝试加载预设节点文件
-- 优先级：DATA 文件系统下的预设文件 > LUA 文件系统的旧格式文件
-- 如果加载成功，标记为使用预设节点模式
-- ============================================================

-- 获取当前地图名称并转换为小写（用于文件名匹配）
local mapname = string.lower(game.GetMap())
-- 尝试从 DATA 文件系统加载预设节点
if file.Exists(GM.ProfilerFolderPreMade .. "/" .. mapname .. ".txt", "DATA") then
	-- 标记为使用预设节点
	GM.ProfilerIsPreMade = true
	-- 读取并反序列化节点数据
	local data = Deserialize(file.Read(GM.ProfilerFolderPreMade .. "/" .. mapname .. ".txt", "DATA"))
	-- 根据数据结构决定赋值方式（兼容旧格式）
	GM.ProfilerNodes = data.Nodes ~= nil and data.Nodes or data or GM.ProfilerNodes
	-- 清除可能残留的旧格式全局变量
	SRL = nil
-- 如果 DATA 文件系统没有，尝试从 LUA 文件系统加载旧格式预设文件
elseif file.Exists(GM.FolderName .. "/gamemode/" .. GM.ProfilerFolderPreMade .. "/" .. mapname .. ".lua", "LUA") then
	-- 包含旧格式的 LUA 预设文件
	include(GM.ProfilerFolderPreMade .. "/" .. mapname .. ".lua")
	-- 标记为使用预设节点
	GM.ProfilerIsPreMade = true
	-- 根据数据结构决定赋值方式
	GM.ProfilerNodes = SRL and SRL.Nodes ~= nil and SRL.Nodes or SRL or GM.ProfilerNodes
	-- 清除全局变量
	SRL = nil
end

-- ============================================================
-- 清除分析器节点（实际为保存当前节点数据）
-- 在游戏结束或重置时调用，确保节点数据被持久化
-- ============================================================
function GM:ClearProfiler()
	-- 如果分析器未启用，则不执行
	if not self:ProfilerEnabled() then return end

	-- 保存当前节点数据
	self:SaveProfiler()
end

-- ============================================================
-- 保存预设节点文件
-- 将当前节点列表和版本号写入预设节点文件（供地图制作者使用）
-- ============================================================
function GM:SaveProfilerPreMade()
	-- 序列化节点数据和版本号并写入预设文件
	file.Write(self:GetProfilerFilePreMade(), Serialize({Nodes = self.ProfilerNodes, Version = self.ProfilerVersion}))
end

-- ============================================================
-- 删除预设节点文件
-- ============================================================
function GM:DeleteProfilerPreMade()
	-- 从 DATA 文件系统删除预设节点文件
	file.Delete(self:GetProfilerFilePreMade())
end

-- ============================================================
-- 保存自动生成的节点数据
-- 仅在分析器启用且当前不是预设模式时执行
-- ============================================================
function GM:SaveProfiler()
	-- 如果分析器未启用或当前使用的是预设节点，则不保存
	if not self:ProfilerEnabled() or self.ProfilerIsPreMade then return end

	-- 序列化节点数据和版本号并写入自动生成节点文件
	file.Write(self:GetProfilerFile(), Serialize({Nodes = self.ProfilerNodes, Version = self.ProfilerVersion}))
end

-- ============================================================
-- 从网络 URL 获取节点的回调函数
-- 处理 HTTP 请求返回的节点数据
-- body: HTTP 响应体内容
-- len: 响应内容长度
-- headers: 响应头
-- code: HTTP 状态码
-- ============================================================
local function FetchNodes(body, len, headers, code)
	-- 确认请求成功且有数据
	if code == 200 and len > 0 then
		-- 反序列化响应数据
		local data = Deserialize(body)
		-- 验证数据有效
		if data then
			-- 根据数据结构决定赋值方式
			if data.Nodes then
				GAMEMODE.ProfilerNodes = data.Nodes
			else
				GAMEMODE.ProfilerNodes = data
			end
			-- 标记为预设节点模式（在线获取的数据视为预设）
			GAMEMODE.ProfilerIsPreMade = true

			-- 如果实体初始化已完成，立即调用 CreateSigils 创建节点标记
			if GAMEMODE.DidInitPostEntity then
				gamemode.Call("CreateSigils", false, true)
			end
		end
	end
end

-- ============================================================
-- 加载节点数据（含版本兼容性检查）
-- 根据 version 字段判断数据格式是否兼容
-- data: 要加载的节点数据表
-- 返回值: true 表示加载成功，false 表示加载失败
-- ============================================================
function GM:LoadNodeProfile(data)
	-- 旧格式兼容：数据没有 Version 字段且当前版本号为 0
	if not data.Version and self.ProfilerVersion == 0 then
		-- 根据数据结构赋值
		if data.Nodes then
			self.ProfilerNodes = data.Nodes
		else
			self.ProfilerNodes = data
		end
		return true
	-- 新格式：数据有 Version 且不低于当前要求的版本号
	elseif data.Nodes and data.Version >= self.ProfilerVersion then
		-- 根据数据结构赋值
		if data.Nodes then
			self.ProfilerNodes = data.Nodes
		else
			self.ProfilerNodes = data
		end
		return true
	end

	-- 版本不兼容或数据无效，加载失败
	return false
end

-- ============================================================
-- 加载分析器节点数据
-- 支持从在线 URL 和本地文件两种方式加载
-- 如果使用预设节点模式，则跳过加载
-- ============================================================
function GM:LoadProfiler()
	-- 如果分析器未启用或当前使用的是预设节点，则不加载
	if not self:ProfilerEnabled() or self.ProfilerIsPreMade then return end

	-- 如果启用了在线配置文件且 NDB 库未定义，则从在线 URL 获取节点数据
	if self.UseOnlineProfiles and not NDB then
		http.Fetch("https://www.noxiousnet.com/zs_nodes/" .. mapname .. ".txt", FetchNodes)
	end

	-- 尝试从本地 DATA 文件系统加载自动生成的节点文件
	local filename = self:GetProfilerFile()
	if file.Exists(filename, "DATA") then
		-- 读取并反序列化节点数据
		local data = Deserialize(file.Read(filename, "DATA"))
		-- 验证数据有效并尝试加载
		if data then
			self:LoadNodeProfile(data)
		end
	end
end

-- ============================================================
-- 获取自动生成节点文件的完整路径
-- 格式: zsprofiler/<地图名小写>.txt
-- ============================================================
function GM:GetProfilerFile()
	return self.ProfilerFolder .. "/" .. string.lower(game.GetMap()) .. ".txt"
end

-- ============================================================
-- 获取预设节点文件的完整路径
-- 格式: profiler_premade/<地图名小写>.txt
-- ============================================================
function GM:GetProfilerFilePreMade()
	return self.ProfilerFolderPreMade .. "/" .. string.lower(game.GetMap()) .. ".txt"
end

-- ============================================================
-- 检查分析器是否应启用
-- 在僵尸逃生(ZombieEscape)模式和目标地图(ObjectiveMap)模式下禁用
-- 这些模式有自己固定的节点/目标系统，不需要自动学习
-- ============================================================
function GM:ProfilerEnabled()
	return not self.ZombieEscape and not self.ObjectiveMap
end

-- ============================================================
-- 检查是否需要继续学习添加新节点
-- 当节点数量未达到上限且不是预设模式时返回 true
-- ============================================================
function GM:NeedsProfiling()
	return #self.ProfilerNodes <= self.MaxProfilerNodes and not self.ProfilerIsPreMade
end

-- ============================================================
-- 调试函数：在地图上可视化所有节点位置
-- 为每个节点创建一个红色 Breen 模型作为标记
-- 用于开发和测试阶段查看节点分布
-- ============================================================
function GM:DebugProfiler()
	-- 遍历所有已记录的节点
	for _, node in pairs(self.ProfilerNodes) do
		-- 标志：该节点位置是否已有调试实体
		local spawned = false
		-- 检查是否已在相同位置创建了调试实体
		for __, e in pairs(ents.FindByClass("prop_dynamic*")) do
			if e.IsNode and e:GetPos() == node then spawned = true end
		end
		-- 如果没有调试实体，则创建一个新的
		if not spawned then
			local ent = ents.Create("prop_dynamic_override")
			if ent:IsValid() then
				ent:SetModel("models/player/breen.mdl")
				ent:SetKeyValue("solid", "0")          -- 无碰撞
				ent:SetColor(Color(255, 0, 0))         -- 红色标记
				ent:SetPos(node)
				ent:Spawn()
				ent.IsNode = true                       -- 标记为调试节点
			end
		end
	end
end

-- ============================================================
-- 常量定义
-- 用于玩家位置验证中的碰撞检测和射线追踪
-- ============================================================
-- 玩家站立时碰撞盒的高度（用于向上追踪）
local playerheight = Vector(0, 0, 92)
-- 玩家碰撞盒的最小边界
local playermins = Vector(-24, -24, 0)
-- 玩家碰撞盒的最大边界
local playermaxs = Vector(24, 24, 4)
-- 用于向上发射射线检测天空的远端点
local vecsky = Vector(0, 0, 32000)

-- ============================================================
-- 带 Z 轴偏斜的距离计算函数
-- 当源点 a 的 Z 坐标高于目标点 b 时，垂直距离会被放大 skew 倍
-- 用于在判断节点距离时，给予高度差更大的权重
-- a, b: 两个三维坐标点
-- skew: Z 轴权重因子
-- ============================================================
local function SkewedDistance(a, b, skew)
	-- 如果 a 点高于 b 点，Z 轴差值乘以 skew
	if a.z > b.z then
		return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + ((a.z - b.z) * skew) ^ 2)
	end
	-- 否则使用标准三维距离
	return a:Distance(b)
end

-- ============================================================
-- 核心验证函数：判断玩家当前位置是否适合作为新节点
-- 通过一系列严格检查确保节点位置的合理性
-- 返回值: true 表示位置有效，false 表示无效
-- ============================================================
function GM:ProfilerPlayerValid(pl)
	-- 初步检查：玩家是否被显式标记为不可分析
	if pl.NoProfiling then return false end

	-- 基本状态检查：
	-- 必须是人类队伍、存活、行走移动类型、未蹲伏、在地面上、且脚下的实体是世界（非玩家或NPC）
	if not (pl:Team() == TEAM_HUMAN and pl:Alive()
		and pl:GetMoveType() == MOVETYPE_WALK and not pl:Crouching()
		and pl:OnGround() and pl:IsOnGround() and pl:GetGroundEntity() == game.GetWorld()) then return false end

	-- 获取玩家的碰撞盒中心位置和脚部位置
	local plcenter = pl:LocalToWorld(pl:OBBCenter())
	local plpos = pl:GetPos()

	-- 检查玩家是否距离已有节点太近（偏斜距离小于等于 128 单位）
	for _, node in pairs(self.ProfilerNodes) do
		if SkewedDistance(node, plpos, 3) <= 128 then
			return false
		end
	end

	-- 检查玩家是否卡在物体内部（向上进行碰撞盒追踪）
	local pos = plpos + Vector(0, 0, 1)
	-- 从脚部上方到头部高度进行 Hull 追踪，如果碰到实体则说明卡住了
	if util.TraceHull({start = pos, endpos = pos + playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID, filter = team.GetPlayers(TEAM_HUMAN)}).Hit then
		return false
	end

	-- 检查玩家是否靠近 trigger_hurt 伤害触发器
	for _, ent in pairs(ents.FindInSphere(plcenter, 256)) do
		if ent and ent:IsValid() then
			local entclass = ent:GetClass()
			-- 如果附近有伤害触发器，则此位置不安全
			if entclass == "trigger_hurt" then
				return false
			end
		end
	end

	-- 检查玩家是否靠近僵尸刷新点（距离小于 420 单位）
	for _, ent in pairs(team.GetValidSpawnPoint(TEAM_UNDEAD)) do
		if ent:GetPos():DistToSqr(plcenter) < 176400 then
			return false
		end
	end

	-- 复杂检查：检测玩家是否在室外（暴露在天空下）或在无绘图区域
	local trace = {start = plcenter, endpos = plcenter + vecsky, mins = playermins, maxs = playermaxs, mask = MASK_SOLID_BRUSHONLY}
	local trsky = util.TraceHull(trace)
	-- 如果射线击中天空或无绘图区域，则说明在室外，不添加
	if trsky.HitSky or trsky.HitNoDraw then
		return false
	end

	-- 检查玩家是否靠近窗户或入口
	-- 同时也用于检测长走廊
	-- 通过向四周不同方向发射射线检查天花板和地板的存在
	local tr
	local ang = Angle(0, 0, 0)
	-- 遍历 360 度，每隔 15 度检测一次
	for t = 0, 359, 15 do
		ang.yaw = t

		-- 从距离 32 到 92 单位，每隔 24 单位检测一次
		for d = 32, 92, 24 do
			-- 向上检测：确认上方有天花板遮挡
			trace.start = plcenter + ang:Forward() * d
			trace.endpos = trace.start + Vector(0, 0, 640)
			tr = util.TraceHull(trace)
			-- 如果没有击中（开放空间）或击中的法线 Z 分量大于 -0.65（不是平坦天花板）
			if not tr.Hit or tr.HitNormal.z > -0.65 then
				return false
			end
			-- 向下检测：确认下方有地板支撑
			trace.endpos = trace.start + Vector(0, 0, -64)
			tr = util.TraceHull(trace)
			-- 如果没有击中（开放空间）或击中的法线 Z 分量小于 0.65（不是平坦地板）
			if not tr.Hit or tr.HitNormal.z < 0.65 then
				return false
			end
		end
	end

	-- 通过以上所有检查，玩家位置有效
	return true
end

-- ============================================================
-- 分析器主循环函数
-- 遍历所有玩家，验证其位置有效后添加为新节点
-- 当节点列表发生变化时，自动保存
-- ============================================================
function GM:ProfilerTick()
	-- 如果分析器未启用或已不需要更多节点，则不执行
	if not self:ProfilerEnabled() or not self:NeedsProfiling() then return end

	-- 标志：是否有新节点被添加
	local changed = false
	-- 遍历所有在线玩家
	for _, pl in pairs(player.GetAll()) do
		if self:ProfilerPlayerValid(pl) then
			-- 将玩家的脚部位置添加为节点
			table.insert(self.ProfilerNodes, pl:GetPos())
			changed = true
		end
	end

	-- 如果节点列表有变化，保存数据
	if changed then
		self:SaveProfiler()
	end
end

-- ============================================================
-- 创建定时器：每 3 秒执行一次 ProfilerTick
-- 用于持续收集节点的自动学习
-- ============================================================
timer.Create("ZSProfiler", 3, 0, function() GAMEMODE:ProfilerTick() end)

-- ============================================================
-- 波次状态变化 Hook：在游戏波次开始后停止节点收集
-- 波次 0 为准备阶段，大于 0 表示游戏已正式开始
-- ============================================================
hook.Add("OnWaveStateChanged", "ZSProfiler", function()
	-- 如果当前波次大于 0，移除分析器定时器，锁定已收集的节点
	if GAMEMODE:GetWave() > 0 then
		timer.Remove("ZSProfiler")
	end
end)
