-- ============================================================
-- 技能树系统 - 服务端层
-- 负责处理所有服务端网络消息、技能管理逻辑、
-- 经验值/转生/重置等核心操作
-- ============================================================

-- ============================================================
-- 处理客户端发送的单个技能激活/停用请求
-- ============================================================
net.Receive(NET_MSG.SKILL_IS_DESIRED, function(length, pl)
	local skillid = net.ReadUInt(16)
	local desired = net.ReadBool()

	pl:SetSkillDesired(skillid, desired)
end)

-- ============================================================
-- 处理客户端发送的完整期望技能列表（位标记方式）
-- ============================================================
net.Receive(NET_MSG.SKILLS_DESIRED, function(length, pl)
	local desired = {}

	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			table.insert(desired, skillid)
		end
	end
	pl:SetDesiredActiveSkills(desired)
	pl:ApplySkills(desired)
end)

-- ============================================================
-- 处理客户端发送的"全部激活/全部停用"请求
-- ============================================================
net.Receive(NET_MSG.SKILLS_ALL_DESIRED, function(length, pl)
    local desired = {}
    if net.ReadBool() then
        -- 全部激活：将所有已解锁技能设为期望
        desired = table.Copy(pl:GetUnlockedSkills())
        pl:SetDesiredActiveSkills(desired)
    else
        -- 全部停用：仅保留 AlwaysActive 标记的技能
        for _, id in pairs(pl:GetUnlockedSkills()) do
            if GAMEMODE.Skills[id] and GAMEMODE.Skills[id].AlwaysActive then
                desired[#desired + 1] = id
            end
        end
        pl:SetDesiredActiveSkills(desired)
    end
    
    pl:ApplySkills(desired)
end)

-- ============================================================
-- 处理客户端发送的"加载配装"请求（从保存的配装中读取）
-- ============================================================
net.Receive(NET_MSG.SKILL_SET_DESIRED, function(length, pl)
    local skillset = net.ReadTable()
    -- 校验客户端数据：必须是表且为技能ID映射（防恶意畸形包 DoS）
    if type(skillset) ~= "table" then return end

    local assoc = table.ToAssoc(skillset)

    local desired = {}
    for _, id in pairs(pl:GetUnlockedSkills()) do
        if GAMEMODE.Skills[id] and (GAMEMODE.Skills[id].AlwaysActive or assoc[id]) then
            desired[#desired + 1] = id
        end
    end
    pl:SetDesiredActiveSkills(desired)
    pl:ApplySkills(desired)
end)

-- ============================================================
-- 处理客户端发送的技能解锁请求
-- 检查：技能是否存在、是否已解锁、技能点是否充足、是否可解锁、是否被禁用
-- ============================================================
net.Receive(NET_MSG.SKILL_IS_UNLOCKED, function(length, pl)
    local skillid = net.ReadUInt(16)
    local activate = net.ReadBool()
    local skill = GAMEMODE.Skills[skillid]

    if skill and not pl:IsSkillUnlocked(skillid) and pl:GetZSSPRemaining() >= 1 and pl:SkillCanUnlock(skillid) and not skill.Disabled then
        pl:SetSkillUnlocked(skillid, true)
		local skillname = skill.Name
        pl:CenterNotify(translate.ClientFormat(pl, "skill_unlocked_message", skillname))
        pl:PrintTranslatedMessage(HUD_PRINTTALK, "skill_unlocked_message", skillname)

        if activate then
            pl:SetSkillDesired(skillid, true)
        end
    end
end)

-- ============================================================
-- 处理客户端发送的转生请求
-- ============================================================
net.Receive(NET_MSG.SKILLS_REMORT, function(length, pl)
    if pl:CanSkillsRemort() then
        pl:SkillsRemort()
    end
end)

-- ============================================================
-- 处理客户端发送的技能重置请求
-- 检查：等级不低于10、冷却时间是否已过
-- ============================================================
net.Receive(NET_MSG.SKILLS_RESET, function(length, pl)
    if pl:GetZSLevel() < 10 then
        pl:SkillNotify(translate.Get("must_be_level_10"))
        return
    end

    local time = os.time()
    if pl.NextSkillReset and time < pl.NextSkillReset then
        pl:SkillNotify(translate.Get("must_wait_before_reset"))
        return
    end

    pl:SkillsReset()

    net.Start(NET_MSG.SKILLS_NEXTRESET)
        net.WriteUInt(pl.NextSkillReset - time, 32)
    net.Send(pl)
end)

-- ============================================================
-- 处理客户端发送的"检查退款状态"请求
-- 通知玩家是否有技能点被退还（因技能树变更）
-- ============================================================
net.Receive(NET_MSG.SKILLS_REFUNDED, function(length, pl)
    if pl.SkillsRefunded then
        pl:SkillNotify(translate.Get("skill_tree_changed_refunded"))
    end

    pl.SkillsRefunded = false
end)

-- ============================================================
-- 工具函数：将技能表按位写入网络消息
-- 遍历所有技能ID，为每个技能写入一个布尔值
-- ============================================================
function GM:WriteSkillBits(t)
	t = table.ToAssoc(t)

	for skillid in pairs(GAMEMODE.Skills) do
		if t[skillid] then
			net.WriteBool(true)
		else
			net.WriteBool(false)
		end
	end
end

-- ============================================================
-- 获取 Player 元表
-- ============================================================
local meta = FindMetaTable("Player")
if not meta then return end

-- ============================================================
-- 向客户端发送通知消息（带颜色标记）
-- ============================================================
function meta:SkillNotify(message, green)
	net.Start(NET_MSG.SKILLS_NOTIFY)
	net.WriteString(message)
	net.WriteBool(not not green)
	net.Send(self)
end

-- ============================================================
-- 设置某技能的期望状态（激活/停用）
-- 同步修改客户端并重新应用技能效果
-- ============================================================
function meta:SetSkillDesired(skillid, desired)
    local desiredskills = self:GetDesiredActiveSkills()

    if desired then
        if self:IsSkillUnlocked(skillid) then
            if not self:IsSkillDesired(skillid) then
                table.insert(desiredskills, skillid)
            end

            self:SendSkillDesired(skillid, true)
        end
    else
        table.RemoveByValue(desiredskills, skillid)
        self:SendSkillDesired(skillid, false)
    end

    self:SetDesiredActiveSkills(desiredskills)
    self:ApplySkills(desiredskills)
end

-- ============================================================
-- 设置技能的解锁状态
-- 只在实际状态变化时执行操作并通知客户端
-- ============================================================
function meta:SetSkillUnlocked(skillid, unlocked)
	local unlockedskills = self:GetUnlockedSkills()

	if self:IsSkillUnlocked(skillid) ~= unlocked then
		if unlocked then
			table.insert(unlockedskills, skillid)
		else
			table.RemoveByValue(unlockedskills, skillid)
		end

		self:SendSkillUnlocked(skillid, unlocked)
	end

	self:SetUnlockedSkills(unlockedskills)
end

-- ============================================================
-- 直接设置玩家等级（不常用）
-- ============================================================
function meta:SetZSLevel(level)
	self:SetZSXP(GAMEMODE:XPForLevel(level))
end

-- ============================================================
-- 设置转生等级（网络同步）
-- ============================================================
function meta:SetZSRemortLevel(level)
	self:SetDTInt(DT_PLAYER_INT_REMORTLEVEL, level)
end

-- ============================================================
-- 设置经验值（限制在 0 ~ MaxXP 范围内）
-- ============================================================
function meta:SetZSXP(xp)
	self:SetDTInt(DT_PLAYER_INT_XP, math.Clamp(xp, 0, GAMEMODE.MaxXP))
end

-- ============================================================
-- 增加经验值
-- TODO: 在保险箱加载时缓存"下一级所需经验"以优化检查
-- ============================================================
function meta:AddZSXP(xp)
	self:SetZSXP(self:GetZSXP() + xp)
end

-- ============================================================
-- 移除所有技能（切换为人类以外队伍时调用）
-- 只处理技能函数，不处理修饰符（修饰符只影响人类生命周期内的属性）
-- ============================================================
function meta:RemoveSkills()
	local active = self:GetActiveSkills()
	local gm_functions = GAMEMODE.SkillFunctions

	for _, skillid in pairs(active) do
		local funcs = gm_functions[skillid]
		if funcs then
			for __, func in pairs(funcs) do
				func(self, false)
			end
		end
	end
end

-- ============================================================
-- 向客户端发送某技能期望状态变更
-- ============================================================
function meta:SendSkillDesired(skillid, desired)
	net.Start(NET_MSG.SKILL_IS_DESIRED)
		net.WriteUInt(skillid, 16)
		net.WriteBool(desired)
	net.Send(self)
end

-- ============================================================
-- 向客户端发送某技能解锁状态变更
-- ============================================================
function meta:SendSkillUnlocked(skillid, unlocked)
	net.Start(NET_MSG.SKILL_IS_UNLOCKED)
		net.WriteUInt(skillid, 16)
		net.WriteBool(unlocked)
	net.Send(self)
end

-- ============================================================
-- 设置期望激活的技能列表，并同步到客户端
-- ============================================================
function meta:SetDesiredActiveSkills(skills, nosend)
	self.DesiredActiveSkills = table.ToKeyValues(skills)

	if not nosend then
		net.Start(NET_MSG.SKILLS_DESIRED)
		GAMEMODE:WriteSkillBits(skills)
		net.Send(self)
	end
end

-- ============================================================
-- 设置当前激活的技能表（哈希表格式，O(1)访问），并同步到客户端
-- ============================================================
function meta:SetActiveSkills(skills, nosend)
	self.ActiveSkills = table.ToAssoc(skills)

	if not nosend then
		net.Start(NET_MSG.SKILLS_ACTIVE)
		GAMEMODE:WriteSkillBits(skills)
		net.Send(self)
	end
end

-- ============================================================
-- 设置已解锁的技能列表，并同步到客户端
-- ============================================================
function meta:SetUnlockedSkills(skills, nosend)
	self.UnlockedSkills = table.ToKeyValues(skills)

	if not nosend then
		net.Start(NET_MSG.SKILLS_UNLOCKED)
		GAMEMODE:WriteSkillBits(skills)
		net.Send(self)
	end
end

-- ============================================================
-- 执行转生：
-- 转生等级+1，重置经验值，清空所有技能，
-- 向全服玩家发送通知
-- ============================================================
function meta:SkillsRemort()
	local rl = self:GetZSRemortLevel() + 1
	local myname = self:Name()

	self:SetZSRemortLevel(rl)
	self:SetZSXP(0)
	self:SetUnlockedSkills({})
	self:SetDesiredActiveSkills({})
	self.NextSkillReset = nil

	self:CenterNotify(COLOR_CYAN, translate.ClientFormat(self, "you_have_remorted_now_rl_x", rl))
	self:CenterNotify(COLOR_YELLOW, translate.ClientFormat(self, "you_now_have_x_extra_sp", rl))
	for _, pl in pairs(player.GetAll()) do
		if pl ~= self then
			pl:CenterNotify(COLOR_CYAN, translate.ClientFormat(pl, "x_has_remorted_to_rl_y", myname, rl))
		end
	end

	self:EmitSound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav", 90, 65)
	self:SendLua("util.WhiteOut(2)")
	util.ScreenShake(self:GetPos(), 50, 0.5, 1.5, 800)
end

-- ============================================================
-- 执行技能重置：
-- 清空所有已解锁技能和期望技能，
-- 设置重置冷却时间（1小时=3600秒）
-- ============================================================
function meta:SkillsReset()
	self:SetUnlockedSkills({})
	self:SetDesiredActiveSkills({})
	self.NextSkillReset = os.time() + 3600

	self:CenterNotify(COLOR_CYAN, translate.ClientGet(self, "you_have_reset_all"))
end
