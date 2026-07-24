-- ============================================================================
-- 频道分配系统 (sh_channel.lua)
-- 本文件管理游戏中实体的频道分配，确保每类实体（如炮塔）不超过最大数量限制。
-- 频道用于区分同一类实体中的不同个体，避免冲突。
-- ============================================================================

-- ============================================================================
-- 各类实体的最大频道数
-- ============================================================================

GM.MaxChannels = {}
GM.MaxChannels["turret"] = 7  -- 炮塔类实体最多7个频道

-- ============================================================================
-- 频道到实体类名的映射
-- ============================================================================

GM.ChannelsToClass = {}
GM.ChannelsToClass["turret"] = {"prop_gunturret", "prop_gunturret_buckshot", "prop_gunturret_assault", "prop_gunturret_rocket"}

-- ============================================================================
-- GetFreeChannel
-- 查找指定类别的空闲频道号
-- 遍历所有同类实体，标记已被占用的频道，返回第一个空闲频道
-- @param class string - 类别名称（如"turret"）
-- @return number - 空闲频道号（1~MaxChannels），无空闲时返回-1
-- ============================================================================

function GM:GetFreeChannel(class)
	local max = self.MaxChannels[class]
	if not max then return 1 end

	local taken_channels = {}

	for _, j in pairs(self.ChannelsToClass[class]) do
		for _, ent in pairs(ents.FindByClass(j)) do
			if ent:IsValid() and ent.GetChannel then
				taken_channels[ent:GetChannel()] = true
			end
		end
	end

	for i=1, max do
		if not taken_channels[i] then
			return i
		end
	end

	return -1
end

-- ============================================================================
-- HasFreeChannel
-- 检查指定类别是否有空闲频道
-- @param class string - 类别名称
-- @return boolean - 是否有空闲频道
-- ============================================================================

function GM:HasFreeChannel(class)
	return self:GetFreeChannel(class) >= 1
end
