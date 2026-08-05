-- ========== 保险库系统配置常量 ==========

-- 保险库数据文件存储目录名
GM.VaultFolder = "zombiesurvival_vault"
-- 当前技能树版本号（用于检测是否需要重置技能）
GM.SkillTreeVersion = 1

-- ========== 判断是否应保存玩家保险库 ==========

-- 检查玩家是否有需要保存的数据（点数、经验、技能等）
function GM:ShouldSaveVault(pl)
	-- Bot不保存保险库数据
	if pl:IsBot() then return false end

	-- 如果有累积点数未保存，返回true
	if self.PointSaving > 0 and pl.PointsVault ~= nil then
		return true
	end

	-- 如果有经验值、已使用的技能点或转生等级，返回true
	if pl:GetZSXP() > 0 or pl:GetZSSPUsed() > 0 or pl:GetZSRemortLevel() > 0 then
		return true
	end

	return false
end

-- ========== 判断是否应加载玩家保险库 ==========

-- Bot不加载保险库数据
function GM:ShouldLoadVault(pl)
	return not pl:IsBot()
end

-- ========== 注释掉的旧保险库启用条件 ==========

--[[function GM:ShouldUseVault(pl)
	return not self.ZombieEscape and not self:IsClassicMode()
end]]

-- ========== 获取玩家保险库文件路径 ==========

-- 根据玩家的SteamID64生成存储文件路径（按末两位分目录）
function GM:GetVaultFile(pl)
	local steamid = pl:SteamID64() or "invalid"

	return self.VaultFolder.."/"..steamid:sub(-2).."/"..steamid..".txt"
end

-- ========== 保存所有玩家的保险库 ==========

-- 遍历所有在线玩家，逐个保存保险库数据
function GM:SaveAllVaults()
	for _, pl in pairs(player.GetAll()) do
		self:SaveVault(pl)
	end
end

-- ========== 初始化玩家保险库 ==========

-- 为新玩家创建默认的保险库数据（点数为0）
function GM:InitializeVault(pl)
	pl.PointsVault = 0
	pl:SetZSXP(0)
end

-- ========== 加载玩家保险库数据 ==========

-- 从文件中读取并恢复玩家的点数、经验、技能等数据
function GM:LoadVault(pl)
	if not self:ShouldLoadVault(pl) then return end

	local filename = self:GetVaultFile(pl)
	if file.Exists(filename, "DATA") then
		local contents = file.Read(filename, "DATA")
		if contents and #contents > 0 then
			contents = Deserialize(contents)
			if contents then
				pl.PointsVault = math.max(0, tonumber(contents.Points) or 0)

				-- 恢复转生等级
				if contents.RemortLevel then
					pl:SetZSRemortLevel(math.max(0, math.floor(tonumber(contents.RemortLevel) or 0)))
				end
				-- 恢复经验值
				if contents.XP then
					pl:SetZSXP(math.max(0, tonumber(contents.XP) or 0))
				end
				-- 恢复已解锁技能
				if contents.UnlockedSkills then
					pl:SetUnlockedSkills(util.DecompressBitTable(contents.UnlockedSkills), true)
				end
				-- 恢复已选择的主动技能
				if contents.DesiredActiveSkills then
					pl:SetDesiredActiveSkills(util.DecompressBitTable(contents.DesiredActiveSkills), true)
				end
				-- 恢复下次技能重置时间
				if contents.NextSkillReset then
					local reset = tonumber(contents.NextSkillReset)
					pl.NextSkillReset = reset and math.max(os.time(), reset) or nil
				end
				-- 如果版本号不同，重置技能并标记为已退款
				if not contents.Version or contents.Version < self.SkillTreeVersion then
					pl:SkillsReset()
					pl.SkillsRefunded = true
				end

				pl.SkillVersion = self.SkillTreeVersion
			end
		end
	end

	-- 确保点数不为nil
	pl.PointsVault = pl.PointsVault or 0
end

-- ========== 发送技能数据给就绪的玩家 ==========

-- 玩家准备就绪时，发送已解锁和已选择的技能数据
function GM:PlayerReadyVault(pl)
	local unlocked = pl:GetUnlockedSkills()
	local desired = pl:GetDesiredActiveSkills()
	local active = pl:GetActiveSkills()

	net.Start(NET_MSG.SKILLS_INIT)
	self:WriteSkillBits(unlocked)
	self:WriteSkillBits(desired)

	-- 如果有激活的技能，发送标记和技能位
	for k in pairs(active) do
		net.WriteBool(true)
		self:WriteSkillBits(active)
		net.Send(pl)

		return
	end

	net.WriteBool(false)
	net.Send(pl)

	-- 发送下次技能重置倒计时
	if pl.NextSkillReset then
		local time = os.time()
		if time < pl.NextSkillReset then
			net.Start(NET_MSG.SKILLS_NEXTRESET)
			net.WriteUInt(pl.NextSkillReset - time, 32)
			net.Send(pl)
		end
	end
end

-- ========== 保存玩家保险库数据 ==========

-- 将玩家的点数、经验、技能等数据序列化并写入文件
function GM:SaveVault(pl)
	if not self:ShouldSaveVault(pl) then return end

	local tosave = {
		Points = math.floor(pl.PointsVault),
		XP = pl:GetZSXP(),
		RemortLevel = pl:GetZSRemortLevel(),
		DesiredActiveSkills = util.CompressBitTable(pl:GetDesiredActiveSkills()),
		UnlockedSkills = util.CompressBitTable(pl:GetUnlockedSkills()),
		Version = pl.SkillVersion or self.SkillTreeVersion
	}

	-- 如果技能重置时间在将来，保存该时间戳
	if pl.NextSkillReset and os.time() < pl.NextSkillReset then
		tosave.NextSkillReset = pl.NextSkillReset
	end

	-- 应用保存点数上限
	if tosave.Points and self.PointSavingLimit > 0 and tosave.Points > self.PointSavingLimit then
		tosave.Points = self.PointSavingLimit
	end

	local filename = self:GetVaultFile(pl)
	file.CreateDir(string.GetPathFromFilename(filename))
	file.Write(filename, Serialize(tosave))
end
