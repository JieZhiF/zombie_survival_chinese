-- 这个系统用于创建节点，这些节点可以被用来生成动态目标点（例如僵尸逃生模式中的僵尸刷新点或目标点）。

GM.ProfilerNodes = {} -- 一个表，用于存储地图上所有自动或手动生成的“分析器节点”（即潜在的sigil点或路径点）。
GM.ProfilerFolder = "zsprofiler" -- 用于存储自动生成节点数据的文件目录名。
GM.ProfilerFolderPreMade = "profiler_premade" -- 用于存储手动放置的（预设）节点数据的文件目录名。
GM.ProfilerVersion = 0 -- 节点数据的版本号，用于兼容性检查。
GM.MaxProfilerNodes = 128 -- 允许的最大分析器节点数量。


hook.Add("Initialize", "ZSProfiler", function()

	file.CreateDir(GAMEMODE.ProfilerFolder)
	file.CreateDir(GAMEMODE.ProfilerFolderPreMade)
end)

local mapname = string.lower(game.GetMap()) -- 获取当前地图的名称并转换为小写
-- 尝试加载预设的（手动放置的）节点数据
if file.Exists(GM.ProfilerFolderPreMade.."/"..mapname..".txt", "DATA") then
	GM.ProfilerIsPreMade = true -- 设置标志，表示当前使用的是预设节点
	-- 从DATA文件系统中读取并反序列化节点数据
	local data = Deserialize(file.Read(GM.ProfilerFolderPreMade.."/"..mapname..".txt", "DATA"))
	-- 根据数据结构的不同（可能是旧格式），将节点赋值给 GM.ProfilerNodes
	GM.ProfilerNodes = data.Nodes ~= nil and data.Nodes or data or GM.ProfilerNodes
	SRL = nil -- 清除一个可能来自旧LUA文件的全局变量
elseif file.Exists(GM.FolderName.."/gamemode/"..GM.ProfilerFolderPreMade.."/"..mapname..".lua", "LUA") then
	-- 如果DATA文件系统没有，尝试从LUA文件系统加载旧的预设节点文件
	include(GM.ProfilerFolderPreMade.."/"..mapname..".lua") -- 包含LUA文件
	GM.ProfilerIsPreMade = true -- 设置标志，表示当前使用的是预设节点
	-- 同样根据数据结构的不同，将节点赋值给 GM.ProfilerNodes
	GM.ProfilerNodes = SRL and SRL.Nodes ~= nil and SRL.Nodes or SRL or GM.ProfilerNodes
	SRL = nil -- 清除全局变量
end

-- 清除分析器（实际上是保存当前状态）
function GM:ClearProfiler()
	if not self:ProfilerEnabled() then return end -- 如果分析器未启用，则不执行

	self:SaveProfiler() -- 保存当前分析器节点状态
end

-- 保存预设的（手动放置的）节点
function GM:SaveProfilerPreMade()
	-- 将当前节点列表和版本号序列化并写入预设节点文件
	file.Write(self:GetProfilerFilePreMade(), Serialize({Nodes = self.ProfilerNodes, Version = self.ProfilerVersion}))
end

-- 删除预设的（手动放置的）节点文件
function GM:DeleteProfilerPreMade()
	file.Delete(self:GetProfilerFilePreMade())
end

-- 保存自动生成的节点
function GM:SaveProfiler()
	-- 如果分析器未启用或当前使用的是预设节点，则不保存
	if not self:ProfilerEnabled() or self.ProfilerIsPreMade then return end

	-- 将当前节点列表和版本号序列化并写入自动生成节点文件
	file.Write(self:GetProfilerFile(), Serialize({Nodes = self.ProfilerNodes, Version = self.ProfilerVersion}))
end

-- 从在线URL获取节点的回调函数
-- body: 响应体，len: 响应长度，headers: 响应头，code: HTTP状态码
local function FetchNodes(body, len, headers, code)
	if code == 200 and len > 0 then -- 如果请求成功且有内容
		local data = Deserialize(body) -- 反序列化响应体
		if data then
			if data.Nodes then -- 如果数据包含 Nodes 字段
				GAMEMODE.ProfilerNodes = data.Nodes -- 使用 data.Nodes
			else
				GAMEMODE.ProfilerNodes = data -- 否则直接使用 data
			end
			GAMEMODE.ProfilerIsPreMade = true -- 标记为预设节点（从在线获取的通常是预设的）

			if GAMEMODE.DidInitPostEntity then -- 如果实体初始化后阶段已经完成
				gamemode.Call("CreateSigils", false, true) -- 调用游戏模式的 CreateSigils 函数来创建 sigil
			end
		end
	end
end

-- 加载节点配置数据
function GM:LoadNodeProfile(data)
	-- 如果没有版本号且当前游戏模式版本号为0（旧格式）
	if not data.Version and self.ProfilerVersion == 0 then
		if data.Nodes then
			self.ProfilerNodes = data.Nodes
		else
			self.ProfilerNodes = data
		end
		return true -- 加载成功
	-- 如果数据有版本号且版本号大于等于当前游戏模式版本号
	elseif data.Nodes and data.Version >= self.ProfilerVersion then
		if data.Nodes then
			self.ProfilerNodes = data.Nodes
		else
			self.ProfilerNodes = data
		end
		return true -- 加载成功
	end

	return false -- 加载失败（版本不兼容或数据无效）
end

-- 加载分析器节点
function GM:LoadProfiler()
	-- 如果分析器未启用或当前使用的是预设节点，则不加载
	if not self:ProfilerEnabled() or self.ProfilerIsPreMade then return end

	-- 如果启用了在线配置文件且存在NDB库（此处NDB可能是一个未定义的全局变量，需注意）
	if self.UseOnlineProfiles and not NDB then
		-- 从指定URL获取在线节点数据
		http.Fetch("http://www.noxiousnet.com/zs_nodes/"..mapname..".txt", FetchNodes)
	end

	local filename = self:GetProfilerFile() -- 获取自动生成节点的文件名
	if file.Exists(filename, "DATA") then -- 如果文件存在
		local data = Deserialize(file.Read(filename, "DATA")) -- 读取并反序列化数据
		if data then
			self:LoadNodeProfile(data) -- 尝试加载节点配置
		end
	end
end

-- 获取自动生成节点的文件路径
function GM:GetProfilerFile()
	return self.ProfilerFolder.."/"..string.lower(game.GetMap())..".txt"
end

-- 获取预设节点的文件路径
function GM:GetProfilerFilePreMade()
	return self.ProfilerFolderPreMade.."/"..string.lower(game.GetMap())..".txt"
end

-- 检查分析器是否启用
-- 如果不是僵尸逃生模式（ZombieEscape）或目标地图模式（ObjectiveMap），则启用
function GM:ProfilerEnabled()
	return not self.ZombieEscape and not self.ObjectiveMap
end

-- 检查是否需要继续进行分析（添加新节点）
-- 如果当前节点数量小于最大节点数且当前不是预设模式，则需要
function GM:NeedsProfiling()
	return #self.ProfilerNodes <= self.MaxProfilerNodes and not self.ProfilerIsPreMade
end

-- 调试分析器：在地图上显示节点位置
function GM:DebugProfiler()
	for _, node in pairs(self.ProfilerNodes) do
		local spawned = false
		-- 检查是否已经有调试用的实体存在于该节点位置
		for __, e in pairs(ents.FindByClass("prop_dynamic*")) do
			if e.IsNode and e:GetPos() == node then spawned = true end
		end
		if not spawned then -- 如果没有，则创建一个
			local ent = ents.Create("prop_dynamic_override")
			if ent:IsValid() then
				ent:SetModel("models/player/breen.mdl") -- 设置一个模型（例如Breen博士）
				ent:SetKeyValue("solid", "0") -- 设置为非碰撞
				ent:SetColor(Color(255, 0, 0)) -- 设置颜色为红色
				ent:SetPos(node) -- 设置位置
				ent:Spawn() -- 生成实体
				ent.IsNode = true -- 标记为调试节点
			end
		end
	end
end

-- 常量：用于玩家位置和碰撞检测
local playerheight = Vector(0, 0, 92) -- 玩家站立时的高度（用于射线检测）
local playermins = Vector(-24, -24, 0) -- 玩家碰撞盒的最小边界
local playermaxs = Vector(24, 24, 4) -- 玩家碰撞盒的最大边界 (这里 Z 轴的 4 可能表示一个微小的高度修正)
local vecsky = Vector(0, 0, 32000) -- 用于向上检测天空的向量

-- 计算带有 Z 轴偏斜的距离（用于考虑高度差对距离的影响）
-- 如果 a 的 Z 坐标高于 b，则 Z 轴距离会被放大 skew 倍
local function SkewedDistance(a, b, skew)
	if a.z > b.z then
		return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + ((a.z - b.z) * skew) ^ 2)
	end
	return a:Distance(b) -- 否则使用标准距离
end

-- 检查玩家位置是否适合添加为分析器节点
function GM:ProfilerPlayerValid(pl)
	-- 初步检查：玩家是否被标记为“不可分析”
	if pl.NoProfiling then return false end

	-- 基本检查：
	-- 玩家必须是人类队伍，存活，移动类型为行走，未蹲伏，在地面上，并且脚下的实体是世界（非其他实体）
	if not (pl:Team() == TEAM_HUMAN and pl:Alive()
	and pl:GetMoveType() == MOVETYPE_WALK and not pl:Crouching()
	and pl:OnGround() and pl:IsOnGround() and pl:GetGroundEntity() == game.GetWorld()) then return false end

	local plcenter = pl:LocalToWorld(pl:OBBCenter()) -- 玩家碰撞盒中心的世界坐标
	local plpos = pl:GetPos() -- 玩家的脚部位置

	-- 检查玩家是否靠近现有节点
	for _, node in pairs(self.ProfilerNodes) do
		if SkewedDistance(node, plpos, 3) <= 128 then -- 如果玩家与任何现有节点的偏斜距离小于等于128单位
			--print('near')
			return false -- 不添加
		end
	end

	-- 检查玩家是否卡在物体内部（向上进行碰撞盒检测）
	local pos = plpos + Vector(0, 0, 1) -- 玩家脚部上方一点
	-- 从玩家脚部上方到头部高度进行碰撞盒追踪，如果碰到实体，说明玩家被卡住
	if util.TraceHull({start = pos, endpos = pos + playerheight, mins = playermins, maxs = playermaxs, mask = MASK_SOLID, filter = team.GetPlayers(TEAM_HUMAN)}).Hit then
		--print('inside')
		return false -- 不添加
	end

	-- 检查玩家是否靠近 trigger_hurt 实体（伤害触发器）
	for _, ent in pairs(ents.FindInSphere(plcenter, 256)) do -- 在玩家中心256单位半径内查找实体
		if ent and ent:IsValid() then
			local entclass = ent:GetClass()
			if entclass == "trigger_hurt" then
				--print('trigger hurt')
				return false -- 不添加
			end
		end
	end

	-- 检查玩家是否靠近僵尸刷新点
	for _, ent in pairs(team.GetValidSpawnPoint(TEAM_UNDEAD)) do -- 遍历所有有效的僵尸刷新点
		if ent:GetPos():DistToSqr(plcenter) < 176400 then -- 如果玩家距离僵尸刷新点距离平方小于 176400 (即距离小于 420 单位)
			--print('near spawn')
			return false -- 不添加
		end
	end

	-- 复杂检查：检查玩家是否暴露在“天空”下或在“无绘图”区域
	local trace = {start = plcenter, endpos = plcenter + vecsky, mins = playermins, maxs = playermaxs, mask = MASK_SOLID_BRUSHONLY}
	local trsky = util.TraceHull(trace)
	if trsky.HitSky or trsky.HitNoDraw then -- 如果射线击中天空或无绘图区域
		--print('outside')
		return false -- 不添加 (通常节点不应在室外或地图边界外)
	end

	-- 检查玩家是否靠近窗户或入口，这也兼作检查长走廊。
	-- 通过向四周不同方向发射射线并检查是否击中天花板和地板。
	local tr
	local ang = Angle(0, 0, 0)
	for t = 0, 359, 15 do -- 遍历 360 度，每隔 15 度
		ang.yaw = t

		for d = 32, 92, 24 do -- 距离从 32 到 92，每隔 24
			trace.start = plcenter + ang:Forward() * d -- 射线起点从玩家中心向外延伸
			trace.endpos = trace.start + Vector(0, 0, 640) -- 向上延伸 640 单位
			tr = util.TraceHull(trace)
			-- 如果没有击中任何物体（即开放空间）或者击中物体的法线Z分量大于-0.65（表示击中不是平坦的天花板，可能是一个坡度或入口）
			if not tr.Hit or tr.HitNormal.z > -0.65 then
				--print('not hit ceiling')
				return false -- 不添加
			end
			trace.endpos = trace.start + Vector(0, 0, -64) -- 向下延伸 64 单位
			tr = util.TraceHull(trace)
			-- 如果没有击中任何物体（即开放空间）或者击中物体的法线Z分量小于0.65（表示击中不是平坦的地板，可能是一个坡度或入口）
			if not tr.Hit or tr.HitNormal.z < 0.65 then
				--print('not hit floor')
				return false -- 不添加
			end
		end
	end

	-- 剩余的注释掉的代码块是额外的检查，可能用于更严格地判断是否在室内，或检查地面是否平整。
	-- 目前它们被注释掉了，所以不影响当前逻辑。

	--print('valid')
	return true -- 通过所有检查，玩家位置有效
end

-- 分析器计时器函数，定期检查并添加节点
function GM:ProfilerTick()
	-- 如果分析器未启用或不需要添加更多节点，则不执行
	if not self:ProfilerEnabled() or not self:NeedsProfiling() then return end

	local changed = false -- 标志，表示节点列表是否发生改变
	for _, pl in pairs(player.GetAll()) do -- 遍历所有玩家
		if not self:ProfilerPlayerValid(pl) then continue end -- 如果玩家位置无效，则跳过

		table.insert(self.ProfilerNodes, pl:GetPos()) -- 将玩家当前位置添加到节点列表
		changed = true -- 标记为已改变
	end

	if changed then
		self:SaveProfiler() -- 保存分析器节点 (可以取消注释 self:DebugProfiler() 在调试模式下可视化节点)
	end
end
-- 创建一个计时器，每 3 秒调用一次 ProfilerTick 函数
timer.Create("ZSProfiler", 3, 0, function() GAMEMODE:ProfilerTick() end)
-- 添加一个钩子，在波次状态改变时触发
hook.Add("OnWaveStateChanged", "ZSProfiler", function()
	-- 如果当前波次大于 0（即游戏已经开始），则移除分析器计时器，停止自动添加节点
	if GAMEMODE:GetWave() > 0 then
		timer.Remove("ZSProfiler")
	end
end)