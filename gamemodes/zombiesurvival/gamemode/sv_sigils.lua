-- 本文件主要负责处理服务器端的"符文"（Sigil）系统，这是一种游戏目标。文件包含了创建、放置符文的逻辑，以及当符文状态（被腐化或净化）改变时触发的事件和网络通信。

-- GM:PreOnSigilCorrupted 在符文被腐化之前调用的钩子函数，用于执行前置逻辑。
-- GM:OnSigilCorrupted 当符文被腐化时调用，并向所有客户端广播当前已腐化的符文数量。
-- GM:PreOnSigilUncorrupted 在符文被净化之前调用的钩子函数。
-- GM:OnSigilUncorrupted 当符文被净化时调用，并向所有客户端广播事件。
-- SortDistFromLast 一个排序辅助函数，用于根据距离对节点进行升序排序。
-- GM:CreateSigils 核心函数，负责在地图上创建和布置符文实体。它会从地图预设的节点或分析器（Profiler）生成的节点中，通过一套复杂的加权选择算法来挑选出合适的位置，以确保符文的分布既分散又合理。
-- GM:SetUseSigils 设置是否启用符文系统，并将这个状态同步为一个全局变量。
-- GM:GetUseSigils 获取当前是否启用了符文系统。

-- 在Sigil被腐化前调用（钩子函数，用于在事件发生前插入自定义逻辑）
function GM:PreOnSigilCorrupted(ent, dmginfo)
end

-- Sigil被腐化时调用：向所有客户端广播当前已腐化的Sigil数量
function GM:OnSigilCorrupted(ent, dmginfo)
	net.Start(NET_MSG.SIGILCORRUPTED) -- 开始一个网络消息
		net.WriteUInt(self:NumCorruptedSigils(), 8) -- 写入当前腐化的Sigil数量 (8位无符号整数)
	net.Broadcast() -- 广播给所有客户端
end

-- 在Sigil被净化前调用
function GM:PreOnSigilUncorrupted(ent, dmginfo)
end

-- Sigil被净化时调用：向所有客户端广播净化事件
function GM:OnSigilUncorrupted(ent, dmginfo)
	net.Start(NET_MSG.SIGILUNCORRUPTED) -- 开始一个网络消息
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

-- 创建Sigil实体：核心函数，负责在地图上选择合适的位置并创建符文
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

	-- 第一步：获取候选节点。优先使用地图放置的 info_sigilnode 实体
	local vec
	local mapplacednodes = ents.FindByClass("info_sigilnode")
	if #mapplacednodes > 0 and not self.ProfilerIsPreMade then
		for _, placednode in pairs(mapplacednodes) do
			nodes[#nodes + 1] = {v = placednode:GetPos(), en = placednode}
		end
	else
		-- 如果没有地图节点，则使用分析器（Profiler）中保存的节点
		for _, node in pairs(self.ProfilerNodes) do
			-- 检查节点是否"卡在"物体中（通过向上发射检测射线）
			validity_trace.start:Set(node)
			validity_trace.start.z = node.z + 1
			validity_trace.endpos:Set(node)
			validity_trace.endpos.z = node.z + 73
			if util.TraceHull(validity_trace).Hit then
				print("bad sigil node at", node)
			else
				vec = Vector(0, 0, 0)
				vec:Set(node)
				nodes[#nodes + 1] = {v = vec}
			end
		end
	end

	-- 注释掉的代码：在节点不足时从人类出生点随机选取补充
	--[[if secondtry then
		local needed = self.MaxSigils - #nodes - alreadycreated
		if needed > 0 then
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

	-- 循环创建Sigil，直到达到最大数量
	for i = 1 + (rearrange and 0 or alreadycreated), self.MaxSigils do
		local id
		local sigs = ents.FindByClass("prop_obj_sigil")
		local numsigs = #sigs

		-- 重排模式下，将所有现有Sigil的节点位置设为极远值以便重新计算
		if rearrange then
			for _, sig in pairs(sigs) do
				sig.NodePos = Vector(99999, 99999, 99999)
			end
		end

		local force -- 存储强制刷新的节点

		-- 计算每个节点到最近参考点的距离，并考虑上方空间
		for _, n in pairs(nodes) do
			if n.en and n.en.ForceSpawn then
				force = n
			end

			n.d = 999999

			-- 第一次创建时计算到最近僵尸出生点的距离；否则计算到最近现有Sigil的距离
			if numsigs == 0 then
				for __, spawn in pairs(spawns) do
					n.d = math.min(n.d, n.v:Distance(spawn:GetPos()))
				end
			else
				for __, sig in pairs(sigs) do
					n.d = math.min(n.d, n.v:Distance(sig.NodePos))
				end
			end

			-- 向上追踪射线检查上方空间，空间越大距离权重越小，使其更优先被选择
			local tr = util.TraceLine({start = n.v + Vector(0, 0, 8), endpos = n.v + Vector(0, 0, 512), mask = MASK_SOLID_BRUSHONLY})
			n.d = n.d * (2 - tr.Fraction)
		end

		-- 按距离排序（距离越近越靠前）
		table.sort(nodes, SortDistFromLast)

		-- 使用指数权重随机选择一个节点：使近处节点被选中几率更高，但仍保留随机性
		id = math.Rand(0, 0.7) ^ 0.3
		id = math.Clamp(math.ceil(id * #nodes), 1, #nodes)

		-- 如果有强制刷新节点则覆盖随机选择
		if force then
			id = table.KeyFromValue(nodes, force)
		end

		-- 从候选列表中移除已选节点并创建Sigil实体
		local node = nodes[id]
		if node then
			local point = node.v
			table.remove(nodes, id)

			-- 重排模式复用现有实体，否则创建新实体
			local ent = rearrange and sigs[i] or ents.Create("prop_obj_sigil")
			if ent:IsValid() then
				ent:SetPos(point)
				if not rearrange then
					ent:Spawn()
				end
				ent.NodePos = point
			end
		end
	end

	-- 根据Sigil创建结果启用或禁用Sigil功能
	self:SetUseSigils(self:NumSigils() > 0)
end

-- 设置是否使用Sigil系统，并同步为全局变量
function GM:SetUseSigils(use)
	--if self:GetUseSigils() ~= use then
		self.UseSigils = use
		SetGlobalBool("sigils", use) -- 客户端可以通过这个全局变量判断
	--end
end

-- 获取当前是否使用Sigil系统
function GM:GetUseSigils(use)
	return self.UseSigils
end
