-- 在Sigil被腐化前调用（钩子函数，用于在事件发生前插入自定义逻辑）
function GM:PreOnSigilCorrupted(ent, dmginfo)
end

-- Sigil被腐化时调用
function GM:OnSigilCorrupted(ent, dmginfo)
	net.Start("zs_sigilcorrupted") -- 开始一个网络消息
		net.WriteUInt(self:NumCorruptedSigils(), 8) -- 写入当前腐化的Sigil数量 (8位无符号整数)
	net.Broadcast() -- 广播给所有客户端
end

-- 在Sigil被净化前调用
function GM:PreOnSigilUncorrupted(ent, dmginfo)
end

-- Sigil被净化时调用
function GM:OnSigilUncorrupted(ent, dmginfo)
	net.Start("zs_sigiluncorrupted") -- 开始一个网络消息
		--net.WriteUInt(self:NumCorruptedSigils(), 8) -- (这行被注释掉了，但原本可能用于发送净化后的数量)
	net.Broadcast() -- 广播给所有客户端
end

-- 排序函数：根据距离最后一个点（或其他参考点）的距离进行升序排序
local function SortDistFromLast(a, b)
	return a.d < b.d
end

-- 用于节点有效性检查的射线追踪参数
local validity_trace = {
	start = Vector(0, 0, 0), endpos = Vector(0, 0, 0), mins = Vector(-18, -18, 0), maxs = Vector(18, 18, 2), mask = MASK_SOLID_BRUSHONLY
}
-- 创建Sigil实体
function GM:CreateSigils(secondtry, rearrange)
	local alreadycreated = self:NumSigils() -- 获取当前已创建的Sigil数量

	-- 如果是僵尸逃生模式、目标地图模式、经典模式、PantsMode或BabyMode，则禁用Sigil功能
	if self.ZombieEscape or self.ObjectiveMap
	or self:IsClassicMode() or self.PantsMode or self:IsBabyMode() then
		self:SetUseSigils(false)
		return
	end

	-- 如果已创建的Sigil数量已达到最大值且不是重排模式，则不执行
	if alreadycreated >= self.MaxSigils and not rearrange then return end

	local nodes = {} -- 用于存储候选Sigil点的表

	-- 尝试从地图放置的 info_sigilnode 实体中获取节点
	local vec
	local mapplacednodes = ents.FindByClass("info_sigilnode")
	-- 如果地图上有放置的节点且当前不是预设模式（即没有手动编辑的profiler节点）
	if #mapplacednodes > 0 and not self.ProfilerIsPreMade then
		for _, placednode in pairs(mapplacednodes) do
			nodes[#nodes + 1] = {v = placednode:GetPos(), en = placednode} -- 将实体位置添加到候选节点列表
		end
	else
		-- 否则，从游戏模式的 ProfilerNodes（自动或手动保存的）中复制节点
		for _, node in pairs(self.ProfilerNodes) do
			-- 检查节点是否“卡在”某个物体中（例如墙里或天花板里）
			validity_trace.start:Set(node)
			validity_trace.start.z = node.z + 1 -- 起点略高于节点位置
			validity_trace.endpos:Set(node)
			validity_trace.endpos.z = node.z + 73 -- 终点在节点上方 73 单位
			if util.TraceHull(validity_trace).Hit then -- 如果追踪击中物体，说明节点无效
				print("bad sigil node at", node) -- 打印错误信息
			else
				vec = Vector(0, 0, 0)
				vec:Set(node)
				nodes[#nodes + 1] = {v = vec} -- 将有效节点添加到候选列表
			end
		end
	end

	--[[ 已注释的代码块：
	-- 这段代码原本可能用于在节点不足时，从人类玩家的刷新点随机选取一些点作为Sigil点。
	-- 目前被注释，不执行。
	if secondtry then
		local needed = self.MaxSigils - #nodes - alreadycreated
		if needed > 0 then
			-- We seem to be missing some nodes...
			-- This might happen if nobody seeds the map and the round begins.
			for i = 1, needed do
				local spawns = team.GetSpawnPoint(TEAM_HUMAN)
				if #spawns > 0 then
					local spawnid = math.random(#spawns)
					local spawn = spawns[spawnid]

					nodes[#nodes + 1] = {v = spawn:GetPos()}
					spawn.Disabled = true
				end
			end
		end
	end]]

	local spawns = team.GetSpawnPoint(TEAM_UNDEAD) -- 获取僵尸刷新点
	-- 循环创建 Sigil，直到达到 MaxSigils 数量
	for i = 1 + (rearrange and 0 or alreadycreated), self.MaxSigils do
		local id
		local sigs = ents.FindByClass("prop_obj_sigil") -- 获取当前地图上已存在的 Sigil 实体
		local numsigs = #sigs
		if rearrange then -- 如果是重排模式
			for _, sig in pairs(sigs) do
				sig.NodePos = Vector(99999, 99999, 99999) -- 临时将所有现有Sigil的节点位置设置为一个极远的值，以便重新计算距离
			end
		end

		local force -- 用于存储强制刷新的节点
		for _, n in pairs(nodes) do
			if n.en and n.en.ForceSpawn then -- 如果节点是地图放置的且有强制刷新标志
				force = n -- 标记为强制刷新节点
			end

			n.d = 999999 -- 初始化节点距离为极大值

			if numsigs == 0 then -- 如果当前没有Sigil实体（第一次创建）
				for __, spawn in pairs(spawns) do
					n.d = math.min(n.d, n.v:Distance(spawn:GetPos())) -- 计算节点与最近僵尸刷新点的距离
				end
			else
				for __, sig in pairs(sigs) do
					n.d = math.min(n.d, n.v:Distance(sig.NodePos)) -- 计算节点与最近现有Sigil的距离
				end
			end

			-- 向上追踪射线，检查节点上方是否有空间（例如天花板）
			local tr = util.TraceLine({start = n.v + Vector(0, 0, 8), endpos = n.v + Vector(0, 0, 512), mask = MASK_SOLID_BRUSHONLY})
			-- 调整节点距离：如果上方空间越大 (Fraction 越接近 1)，则距离权重越小 (2 - Fraction 越小)，使其更优先被选择
			n.d = n.d * (2 - tr.Fraction)
		end

		-- 根据计算出的距离对节点进行排序
		table.sort(nodes, SortDistFromLast)

		-- 使用指数权重选择一个节点
		-- 生成一个0到0.7之间的随机数，然后进行0.3次幂运算。
		-- 这样做的目的是使索引较小的节点（即距离最近的节点）有更高的选中几率，但仍保留选中较远节点的可能性。
		id = math.Rand(0, 0.7) ^ 0.3
		id = math.Clamp(math.ceil(id * #nodes), 1, #nodes) -- 将计算出的 id 限制在有效范围内
		if force then
			id = table.KeyFromValue(nodes, force) -- 如果有强制刷新节点，则使用它的索引
		end

		-- 从临时列表中移除选中的节点，并创建Sigil
		local node = nodes[id]
		if node then
			local point = node.v
			table.remove(nodes, id) -- 从候选列表中移除已选择的节点

			local ent = rearrange and sigs[i] or ents.Create("prop_obj_sigil") -- 如果是重排模式，则重用现有Sigil实体；否则创建新实体
			if ent:IsValid() then
				ent:SetPos(point) -- 设置Sigil位置
				if not rearrange then
					ent:Spawn() -- 如果不是重排，则生成实体
				end
				ent.NodePos = point -- 存储Sigil所关联的节点位置
			end
		end
	end

	-- 根据当前Sigil数量设置是否启用Sigil功能
	self:SetUseSigils(self:NumSigils() > 0)
end

-- 设置是否使用Sigil
function GM:SetUseSigils(use)
	--if self:GetUseSigils() ~= use then -- (这行被注释掉，但原本可能用于避免不必要的设置)
		self.UseSigils = use -- 更新游戏模式内部的标志
		SetGlobalBool("sigils", use) -- 设置一个全局布尔量，客户端和其他脚本可以读取
	--end
end

-- 获取是否使用Sigil
function GM:GetUseSigils(use) -- (参数 use 是多余的，可以移除)
	return self.UseSigils
end