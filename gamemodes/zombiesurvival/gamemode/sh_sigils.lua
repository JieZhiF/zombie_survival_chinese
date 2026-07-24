-- 本文件主要负责管理游戏中的"印记（Sigil）"目标和相关的"逃脱阶段"逻辑。它提供了一系列函数来获取、计数和检查地图上不同状态（正常、已腐化）的印记实体，并控制逃脱流程的各个阶段。

-- ESCAPESTAGE_NONE, ESCAPESTAGE_ESCAPE, ESCAPESTAGE_BOSS, ESCAPESTAGE_DEATH -- 定义逃脱阶段的常量
-- GM:GetSigils 获取地图上所有有效的印记实体
-- GM:GetUncorruptedSigils 获取所有未被腐化的印记实体
-- GM.GetSigilsUncorrupted 是GM:GetUncorruptedSigils的别名
-- GM:GetCorruptedSigils 获取所有已被腐化的印记实体
-- GM.GetSigilsCorrupted 是GM:GetCorruptedSigils的别名
-- GM:NumSigils 计算地图上有效印记的总数
-- GM:HasSigils 检查地图上是否存在任何有效的印记
-- GM:NumUncorruptedSigils 计算未被腐化的印记数量
-- GM.NumSigilsUncorrupted 是GM:NumUncorruptedSigils的别名
-- GM:NumCorruptedSigils 计算已被腐化的印记数量
-- GM.NumSigilsCorrupted 是GM:NumCorruptedSigils的别名
-- GM:GetUseSigils 检查当前游戏是否启用了印记目标
-- GM:IsEscapeDoorOpen 检查是否有逃脱门已经打开
-- GM:GetEscapeSequence 判断逃脱程序是否已经启动
-- GM.IsEscapeSequence 是GM:GetEscapeSequence的别名
-- GM:SetEscapeStage 设置当前的逃脱阶段
-- GM:GetEscapeStage 获取当前的逃脱阶段

-- 逃脱阶段常量：未开始
ESCAPESTAGE_NONE = 0
-- 逃脱阶段常量：逃生阶段
ESCAPESTAGE_ESCAPE = 1
-- 逃脱阶段常量：BOSS战阶段
ESCAPESTAGE_BOSS = 2
-- 逃脱阶段常量：死亡阶段
ESCAPESTAGE_DEATH = 3

-- 获取地图上所有有效的印记实体
-- @return 包含所有有效印记实体的数组
function GM:GetSigils()
    local sigils = {}

    -- 遍历所有 "prop_obj_sigil" 类实体，筛选出有效的印记
    for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
        if ent:IsValid() and ent.GetSigilHealthBase and ent:GetSigilHealthBase() ~= 0 then
            sigils[#sigils + 1] = ent
        end
    end

    return sigils
end

-- 获取所有未被腐化的印记实体
-- @return 包含所有未腐化印记实体的数组
function GM:GetUncorruptedSigils()
	local sigils = {}

	-- 遍历所有印记实体，筛选出有基础血量且未被腐化的
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and not ent:GetSigilCorrupted() then
			sigils[#sigils + 1] = ent
		end
	end

	return sigils
end
-- 为 GetUncorruptedSigils 设置别名
GM.GetSigilsUncorrupted = GM.GetUncorruptedSigils

-- 获取所有已被腐化的印记实体
-- @return 包含所有已腐化印记实体的数组
function GM:GetCorruptedSigils()
	local sigils = {}

	-- 遍历所有印记实体，筛选出有基础血量且已被腐化的
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and ent:GetSigilCorrupted() then
			sigils[#sigils + 1] = ent
		end
	end

	return sigils
end
-- 为 GetCorruptedSigils 设置别名
GM.GetSigilsCorrupted = GM.GetCorruptedSigils

-- 计算地图上有效印记的总数
-- @return 有效印记的数量
function GM:NumSigils()
	local sigils = 0

	-- 遍历所有印记实体，统计有基础血量的个数
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 then
			sigils = sigils + 1
		end
	end

	return sigils
end

-- 检查地图上是否存在任何有效的印记
-- @return 存在则返回 true，否则返回 false
function GM:HasSigils()
	-- 遍历所有印记实体，一旦找到有效印记立即返回 true
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 then
			return true
		end
	end

	return false
end

-- 计算未被腐化的印记数量
-- @return 未腐化印记的数量
function GM:NumUncorruptedSigils()
	local sigils = 0

	-- 遍历所有印记实体，统计有基础血量且未被腐化的个数
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and not ent:GetSigilCorrupted() then
			sigils = sigils + 1
		end
	end

	return sigils
end
-- 为 NumUncorruptedSigils 设置别名
GM.NumSigilsUncorrupted = GM.NumUncorruptedSigils

-- 计算已被腐化的印记数量
-- @return 已腐化印记的数量
function GM:NumCorruptedSigils()
	local sigils = 0

	-- 遍历所有印记实体，统计有基础血量且已被腐化的个数
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and ent:GetSigilCorrupted() then
			sigils = sigils + 1
		end
	end

	return sigils
end
-- 为 NumCorruptedSigils 设置别名
GM.NumSigilsCorrupted = GM.NumCorruptedSigils

-- 检查当前游戏是否启用了印记目标系统
-- @return 是否启用了印记
function GM:GetUseSigils()
	return GetGlobalBool("sigils", false)
end

-- 检查是否有逃脱门已经打开
-- @return 存在已打开的门则返回 true，否则返回 false
function GM:IsEscapeDoorOpen()
	-- 如果逃脱序列未启动，直接返回 false
	if not self:GetEscapeSequence() then return false end

	-- 遍历所有 "prop_obj_exit" 类实体，检查是否有门已打开
	for _, ent in pairs(ents.FindByClass("prop_obj_exit")) do
		if ent:IsOpened() then
			return true
		end
	end

	return false
end

--[[
-- 以下为已废弃的印记销毁相关函数，保留注释以供参考：
-- function GM:SetAllSigilsDestroyed(destroyed)
--     self:SetSigilsDestroyed(destroyed and self.MaxSigils or 0)
-- end
-- 
-- function GM:GetAllSigilsDestroyed()
--     return self.MaxSigils > 0 and self:GetUseSigils() and self:GetSigilsDestroyed() >= self.MaxSigils
-- end
-- 
-- function GM:SetSigilsDestroyed(destroyed)
--     --SetGlobalInt("destroyedsigils", destroyed)
-- end
-- 
-- function GM:GetSigilsDestroyed()
--     return self:GetWave() > 0 and (self.MaxSigils - self:NumSigils()) or 0
--     --return GetGlobalInt("destroyedsigils", 0)
-- end
--]]

-- 判断逃脱程序是否已经启动
-- @return 启用了印记且逃脱阶段非 NONE 则返回 true
function GM:GetEscapeSequence()
	return self:GetUseSigils() and self:GetEscapeStage() ~= ESCAPESTAGE_NONE
end
-- 为 GetEscapeSequence 设置别名
GM.IsEscapeSequence = GM.GetEscapeSequence

-- 设置当前的逃脱阶段
-- @param stage 要设置的逃脱阶段常量值
function GM:SetEscapeStage(stage)
	SetGlobalInt("esstg", stage)
end

-- 获取当前的逃脱阶段
-- @return 当前阶段常量值，默认为 ESCAPESTAGE_NONE
function GM:GetEscapeStage()
	return GetGlobalInt("esstg", ESCAPESTAGE_NONE)
end
