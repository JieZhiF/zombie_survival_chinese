-- ============================================================
-- 技能树系统 - 共享层
-- 包含服务端与客户端公用的核心逻辑：
--   经验/等级计算、技能解锁判断、玩家技能状态管理
-- ============================================================

-- 引入技能注册表（技能定义、修饰符、函数）
include("registry.lua")

-- ============================================================
-- 经验值转等级：f(xp) = floor(1 + 0.2673 * sqrt(xp))
-- ============================================================
function GM:LevelForXP(xp)
    return math.floor(1 + 0.2673 * math.sqrt(xp))
end

-- ============================================================
-- 等级转经验值：f(level) = 14 * (level-1)^2
-- ============================================================
function GM:XPForLevel(level)
    return 14 * (level - 1) * (level - 1)
end

-- ============================================================
-- 计算当前经验值在本级内的进度（0~1）
-- ============================================================
function GM:ProgressForXP(xp)
    local current_level = self:LevelForXP(xp)
    if current_level >= self.MaxLevel then return 1 end

    local current_level_xp = self:XPForLevel(current_level)
    local next_level_xp = self:XPForLevel(current_level + 1)

    return (xp - current_level_xp) / (next_level_xp - current_level_xp)
end

-- 等级上限提升至60
GM.MaxLevel = 60
-- 自动计算最大经验值：12*(60-1)^2 = 41,772
GM.MaxXP = GM:XPForLevel(GM.MaxLevel)

-- 技能连接逻辑保持不变
function GM:FixSkillConnections()
    for skillid, skill in pairs(self.Skills) do
        for connectid, _ in pairs(skill.Connections) do
            local otherskill = self.Skills[connectid]
            if otherskill and not otherskill.Connections[skillid] then
                otherskill.Connections[skillid] = true
            end
        end
    end
end

-- ============================================================
-- 判断两个技能是否为相邻技能（有连接线）
-- ============================================================
function GM:SkillIsNeighbor(skillid, otherskillid)
	local myskill = self.Skills[skillid]
	return myskill ~= nil and self.Skills[otherskillid] ~= nil and myskill.Connections[otherskillid]
end

-- ============================================================
-- 判断玩家是否能解锁指定技能
-- @param pl 玩家对象
-- @param skillid 技能ID
-- @param skilllist 已解锁技能列表
-- @return boolean
-- ============================================================
function GM:SkillCanUnlock(pl, skillid, skilllist)
	local skill = self.Skills[skillid]
	if skill then
		-- 检查转生等级要求
		if skill.RemortLevel and pl:GetZSRemortLevel() < skill.RemortLevel then
			return false
		end

		local connections = skill.Connections

		-- SKILL_NONE 表示根技能，无需前置即可解锁
		if connections[SKILL_NONE] then
			return true
		end

		-- 检查是否已解锁了任意一个相邻前置技能
		for _, myskillid in pairs(skilllist) do
			if connections[myskillid] then
				return true
			end
		end
	end

	return false
end

-- ============================================================
-- 获取 Player 元表，用于扩展玩家方法
-- ============================================================
local meta = FindMetaTable("Player")
if not meta then return end

-- ============================================================
-- 判断技能是否已解锁
-- ============================================================
function meta:IsSkillUnlocked(skillid)
	return table.HasValue(self:GetUnlockedSkills(), skillid)
end

-- ============================================================
-- 判断技能当前是否可解锁（调用共享函数）
-- ============================================================
function meta:SkillCanUnlock(skillid)
	return GAMEMODE:SkillCanUnlock(self, skillid, self:GetUnlockedSkills())
end

-- ============================================================
-- 判断技能是否已被标记为"想要激活"
-- ============================================================
function meta:IsSkillDesired(skillid)
	return table.HasValue(self:GetDesiredActiveSkills(), skillid)
end

-- ============================================================
-- 判断技能当前是否处于激活状态
-- ============================================================
function meta:IsSkillActive(skillid)
	return self:GetActiveSkills()[skillid]
end

-- ============================================================
-- 判断玩家是否拥有指定饰品
-- ============================================================
function meta:HasTrinket(trinket)
	return self:HasInventoryItem("trinket_" .. trinket)
end

-- ============================================================
-- 创建饰品状态实体
-- 查找是否已存在同类型状态，若无则创建
-- ============================================================
function meta:CreateTrinketStatus(status)
	for _, ent in pairs(ents.FindByClass("status_" .. status)) do
		if ent:GetOwner() == self then return end
	end

	local ent = ents.Create("status_" .. status)
	if ent:IsValid() then
		ent:SetPos(self:EyePos())
		ent:SetParent(self)
		ent:SetOwner(self)
		ent:Spawn()
	end
end

-- ============================================================
-- 应用关联数组格式的技能修饰符
-- 遍历所有已激活技能，累加各修饰符的数值，再调用修饰符函数
-- ============================================================
function meta:ApplyAssocModifiers(assoc)
	local skillmodifiers = {}
	local gm_modifiers = GAMEMODE.SkillModifiers
	for skillid in pairs(assoc) do
		local modifiers = gm_modifiers[skillid]
		if modifiers then
			for modid, amount in pairs(modifiers) do
				skillmodifiers[modid] = (skillmodifiers[modid] or 0) + amount
			end
		end
	end

	for modid, func in pairs(GAMEMODE.SkillModifierFunctions) do
		func(self, skillmodifiers[modid] or 0)
	end
end

-- ============================================================
-- 应用技能（在人类重生时调用）
-- 检查技能是否已解锁，应用修饰符，切换技能函数状态
-- ============================================================
function meta:ApplySkills(override)
	if GAMEMODE.ZombieEscape or GAMEMODE.ClassicMode then return end -- 这些模式不使用技能系统

	local allskills = GAMEMODE.Skills
	local desired = override or self:Alive() and self:Team() == TEAM_HUMAN and self:GetDesiredActiveSkills() or {}
	local current_active = self:GetActiveSkills()
	local desired_assoc = table.ToAssoc(desired)

	-- 检查这些技能是否真的已经解锁
	if not override then
		for skillid in pairs(desired_assoc) do
			if not self:IsSkillUnlocked(skillid) or allskills[skillid] and allskills[skillid].Disabled then
				desired_assoc[skillid] = nil
			end
		end
	end

	self:ApplyAssocModifiers(desired_assoc)

	-- 管理技能函数状态的切换（开/关）
	local funcs
	local gm_functions = GAMEMODE.SkillFunctions
	for skillid in pairs(allskills) do

		funcs = gm_functions[skillid]
		if funcs then
			if current_active[skillid] and not desired_assoc[skillid] then -- 当前开启，但想要关闭
				for _, func in pairs(funcs) do
					func(self, false)
				end
			elseif desired_assoc[skillid] and not current_active[skillid] then -- 当前关闭，但想要开启
				for _, func in pairs(funcs) do
					func(self, true)
				end
			end -- 否则状态无需改变
		end
	end

	-- 存储并与客户端同步状态
	self:SetActiveSkills(desired_assoc, not self.PlayerReady)

	if SERVER and self.ExtraStartingWorth ~= self.LastSentESW then
		self.LastSentESW = self.ExtraStartingWorth
		net.Start(NET_MSG.EXTRASTARTINGWORTH)
			net.WriteUInt(self.ExtraStartingWorth, 16)
		net.Send(self)
	end
end

-- ============================================================
-- 应用饰品技能（在ApplySkills之后调用）
-- 饰品的激活方式不同，基于玩家是否拥有该饰品
-- ============================================================
function meta:ApplyTrinkets(override)
	if GAMEMODE.ZombieEscape or GAMEMODE.ClassicMode then return end -- 这些模式不使用技能系统

	local allskills = GAMEMODE.Skills
	local current_active = self:GetActiveSkills()
	local real_assoc = table.ToAssoc(current_active)

	if not override then
		for skillid, skilltbl in pairs(allskills) do
			if skilltbl.Trinket then
				local hastrinket = self:HasTrinket(skilltbl.Trinket)
				real_assoc[skillid] = hastrinket and true or nil

				if SERVER then
					-- 处理配对的武器给予/移除
					if skilltbl.PairedWeapon then
						local pairedwep = "weapon_zs_t_"..skilltbl.Trinket
						if hastrinket and not self:HasWeapon(pairedwep) then
							self:Give(pairedwep)
						elseif not hastrinket and self:HasWeapon(pairedwep) then
							self:StripWeapon(pairedwep)
						end
					end

					-- 处理饰品状态实体
					if hastrinket and skilltbl.Status then
						self:CreateTrinketStatus(skilltbl.Status)
					end
				end
			end
		end
	end

	self:ApplyAssocModifiers(real_assoc)

	-- 管理饰品技能函数状态
	local funcs
	local gm_functions = GAMEMODE.SkillFunctions
	for skillid in pairs(allskills) do

		funcs = gm_functions[skillid]
		if funcs then
			if not real_assoc[skillid] then -- 当前开启，但想关闭
				for _, func in pairs(funcs) do
					func(self, false)
				end
			elseif real_assoc[skillid] then -- 当前关闭，但想开启
				for _, func in pairs(funcs) do
					func(self, true)
				end
			end
		end
	end
end

-- ============================================================
-- 判断玩家是否可以进行转生（等级达到上限）
-- ============================================================
function meta:CanSkillsRemort()
	return self:GetZSLevel() >= GAMEMODE.MaxLevel
end
meta.CanSkillRemort = meta.CanSkillsRemort

-- ============================================================
-- 将技能设置为激活/非激活
-- ============================================================
function meta:SetSkillActive(skillid, active, nosend)
	local skills = table.ToAssoc(self:GetActiveSkills())
	skills[active] = active
	self:SetActiveSkills(skills, nosend)
end

-- ============================================================
-- 获取玩家当前等级
-- ============================================================
function meta:GetZSLevel()
	return math.floor(GAMEMODE:LevelForXP(self:GetZSXP()))
end

-- ============================================================
-- 获取玩家转生等级
-- ============================================================
function meta:GetZSRemortLevel()
	return self:GetDTInt(DT_PLAYER_INT_REMORTLEVEL)
end

-- ============================================================
-- 获取分档后的转生等级（每4级一档）
-- ============================================================
function meta:GetZSRemortLevelGraded()
	return math.floor(self:GetZSRemortLevel() / 4)
end

-- ============================================================
-- 获取玩家经验值
-- ============================================================
function meta:GetZSXP()
	return self:GetDTInt(DT_PLAYER_INT_XP)
end

-- ============================================================
-- 获取已使用的技能点数量（等于已解锁技能数）
-- ============================================================
function meta:GetZSSPUsed()
	return #self:GetUnlockedSkills()
end

-- ============================================================
-- 获取剩余技能点
-- ============================================================
function meta:GetZSSPRemaining()
	return self:GetZSSPTotal() - self:GetZSSPUsed()
end

-- ============================================================
-- 获取技能点总数（等级 + 转生等级）
-- ============================================================
function meta:GetZSSPTotal()
	return self:GetZSLevel() + self:GetZSRemortLevel()
end

-- ============================================================
-- 获取期望激活的技能列表
-- ============================================================
function meta:GetDesiredActiveSkills()
	return self.DesiredActiveSkills or {}
end

-- ============================================================
-- 获取当前实际激活的技能表
-- ============================================================
function meta:GetActiveSkills()
	return self.ActiveSkills or {}
end

-- ============================================================
-- 获取已解锁的技能列表
-- ============================================================
function meta:GetUnlockedSkills()
	return self.UnlockedSkills or {}
end

-- ============================================================
-- 计算多个修饰符的累加总倍数
-- 将多个 modifier 值合并为一个总倍数
-- ============================================================
function meta:GetTotalAdditiveModifier(...)
	local totalmod = 1
	for i, modifier in ipairs({...}) do
		totalmod = totalmod + (self[modifier] or 1) - 1
	end
	return totalmod
end
