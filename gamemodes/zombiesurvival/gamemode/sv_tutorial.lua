-- ============================================================================
-- sv_tutorial.lua - 服务器端教程数据管理
-- 负责在 data/zstutorial/ 下存储玩家是否已完成新手教程。
-- Bot 不保存、不显示教程。
-- ============================================================================

GM.TutorialFolder = "zstutorial"

util.AddNetworkString("zs_tutorial_done")

-- ============================================================================
-- 获取玩家教程数据文件路径
-- ============================================================================
function GM:GetTutorialFile(pl)
	local steamid = pl:SteamID64() or "invalid"
	return self.TutorialFolder.."/"..steamid..".txt"
end

-- ============================================================================
-- 判断玩家是否已完成教程
-- ============================================================================
function GM:HasCompletedTutorial(pl)
	if pl:IsBot() then return true end

	local filename = self:GetTutorialFile(pl)
	if not file.Exists(filename, "DATA") then return false end

	local contents = file.Read(filename, "DATA")
	if not contents or #contents == 0 then return false end

	local data = Deserialize(contents)
	if data and data.Completed then
		return true
	end

	return false
end

-- ============================================================================
-- 保存玩家已完成教程的状态
-- ============================================================================
function GM:SaveTutorialCompleted(pl)
	if pl:IsBot() then return end

	local filename = self:GetTutorialFile(pl)
	file.CreateDir(self.TutorialFolder)

	local tosave = {
		Completed = true,
		CompletedAt = os.time()
	}

	file.Write(filename, Serialize(tosave))
end

-- ============================================================================
-- 检查并在需要时向玩家显示教程
-- ============================================================================
function GM:CheckAndShowTutorial(pl)
	if not pl:IsValid() then return end
	if pl:IsBot() then return end
	if self:HasCompletedTutorial(pl) then return end

	pl:SendLua("MakepTutorial()")
end

-- ============================================================================
-- 客户端报告完成教程
-- ============================================================================
net.Receive(NET_MSG.TUTORIAL_DONE, function(length, pl)
	if not pl:IsValid() then return end
	if pl:IsBot() then return end

	GAMEMODE:SaveTutorialCompleted(pl)
end)

-- ============================================================================
-- 玩家完全加载后显示教程
-- ============================================================================
hook.Add("PlayerReady", "zstutorial_show", function(pl)
	if not pl:IsValid() then return end

	-- 延迟一帧以确保客户端 VGUI 已加载完毕
	timer.Simple(1, function()
		if pl:IsValid() then
			GAMEMODE:CheckAndShowTutorial(pl)
		end
	end)
end)
-- 调试钩子：聊天输入 !tutorial 可手动打开教程面板
hook.Add("PlayerSay", "zs_tutorial_test", function(pl,text,team)
	if not pl:IsValid() then return end
	if text == "!tutorial" then
		pl:SendLua("MakepTutorial()")
	end
end)
