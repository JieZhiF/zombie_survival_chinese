-- 本文件主要负责管理游戏中的“印记（Sigil）”目标和相关的“逃脱阶段”逻辑。它提供了一系列函数来获取、计数和检查地图上不同状态（正常、已腐化）的印记实体，并控制逃脱流程的各个阶段。

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

ESCAPESTAGE_NONE = 0
ESCAPESTAGE_ESCAPE = 1
ESCAPESTAGE_BOSS = 2
ESCAPESTAGE_DEATH = 3

-- 在 sh_sigils.lua 中
function GM:GetSigils()
    local sigils = {}

    for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
        if ent:IsValid() and ent.GetSigilHealthBase and ent:GetSigilHealthBase() ~= 0 then
            sigils[#sigils + 1] = ent
        end
    end

    return sigils
end

function GM:GetUncorruptedSigils()
	local sigils = {}

	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and not ent:GetSigilCorrupted() then
			sigils[#sigils + 1] = ent
		end
	end

	return sigils
end
GM.GetSigilsUncorrupted = GM.GetUncorruptedSigils

function GM:GetCorruptedSigils()
	local sigils = {}

	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and ent:GetSigilCorrupted() then
			sigils[#sigils + 1] = ent
		end
	end

	return sigils
end
GM.GetSigilsCorrupted = GM.GetCorruptedSigils

function GM:NumSigils()
	local sigils = 0

	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 then
			sigils = sigils + 1
		end
	end

	return sigils
end

function GM:HasSigils()
	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 then
			return true
		end
	end

	return false
end

function GM:NumUncorruptedSigils()
	local sigils = 0

	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and not ent:GetSigilCorrupted() then
			sigils = sigils + 1
		end
	end

	return sigils
end
GM.NumSigilsUncorrupted = GM.NumUncorruptedSigils

function GM:NumCorruptedSigils()
	local sigils = 0

	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:GetSigilHealthBase() ~= 0 and ent:GetSigilCorrupted() then
			sigils = sigils + 1
		end
	end

	return sigils
end
GM.NumSigilsCorrupted = GM.NumCorruptedSigils

function GM:GetUseSigils()
	return GetGlobalBool("sigils", false)
end

function GM:IsEscapeDoorOpen()
	if not self:GetEscapeSequence() then return false end

	for _, ent in pairs(ents.FindByClass("prop_obj_exit")) do
		if ent:IsOpened() then
			return true
		end
	end

	return false
end

--[[function GM:SetAllSigilsDestroyed(destroyed)
	self:SetSigilsDestroyed(destroyed and self.MaxSigils or 0)
end

function GM:GetAllSigilsDestroyed()
	return self.MaxSigils > 0 and self:GetUseSigils() and self:GetSigilsDestroyed() >= self.MaxSigils
end

function GM:SetSigilsDestroyed(destroyed)
	--SetGlobalInt("destroyedsigils", destroyed)
end

function GM:GetSigilsDestroyed()
	return self:GetWave() > 0 and (self.MaxSigils - self:NumSigils()) or 0
	--return GetGlobalInt("destroyedsigils", 0)
end]]

function GM:GetEscapeSequence()
	return self:GetUseSigils() and self:GetEscapeStage() ~= ESCAPESTAGE_NONE
end
GM.IsEscapeSequence = GM.GetEscapeSequence

function GM:SetEscapeStage(stage)
	SetGlobalInt("esstg", stage)
end

function GM:GetEscapeStage()
	return GetGlobalInt("esstg", ESCAPESTAGE_NONE)
end
