-- ============================================================================
-- sv_devreload - 开发者热重载（开发用）
-- 监视 vgui 目录全部 .lua 及字体/选项文件，变化时自动把新内容广播给所有客户端执行
-- （等效于自动执行 lua_openscript_cl，UI 迭代免 restartmap）
-- 开关：zs_devreload 1（默认关闭）
-- ============================================================================
if SERVER then
	CreateConVar("zs_devreload", "0", FCVAR_ARCHIVE, "开发用：自动监听 vgui 文件修改并广播热重载")

	local vguiDir = "gamemodes/zombiesurvival/gamemode/vgui"
	local ExtraFiles = {
		"gamemodes/zombiesurvival/gamemode/cl_fontdlc.lua",
		"gamemodes/zombiesurvival/gamemode/cl_options.lua",
	}

	local LastTimes = {}

	-- 当前监视列表（vgui 目录全部 .lua + 额外文件）
	local function GetWatchList()
		local list = {}
		for _, f in ipairs(file.Find(vguiDir .. "/*.lua", "GAME")) do
			list[vguiDir .. "/" .. f] = true
		end
		for _, p in ipairs(ExtraFiles) do
			list[p] = true
		end
		return list
	end

	-- 新文件记录基线时间（不立即重载）
	local function InitBaselines()
		for path in pairs(GetWatchList()) do
			if not LastTimes[path] then
				LastTimes[path] = file.Time(path, "GAME")
			end
		end
	end

	InitBaselines()

	timer.Create("ZSDevReload", 2, 0, function()
		if not GetConVar("zs_devreload"):GetBool() then return end

		-- 刷新列表：捕获新增文件、清理已删除文件
		local watch = GetWatchList()
		for path in pairs(LastTimes) do
			if not watch[path] then LastTimes[path] = nil end
		end
		InitBaselines()

		for path, last in pairs(LastTimes) do
			local t = file.Time(path, "GAME")
			if t and t ~= last then
				LastTimes[path] = t

				local content = file.Read(path, "GAME")
				if content then
					for _, pl in ipairs(player.GetAll()) do
						pl:SendLua("RunString(" .. string.format("%q", content) .. ")")
					end

					-- 购买/查看器菜单开着时重建以应用新样式
					BroadcastLua("if pWorth and pWorth:IsValid() then MakepWorth() end")
					-- 字体定义文件重载后需重新应用字体
					if path:EndsWith("cl_fontdlc.lua") then
						BroadcastLua("ZSFontDLC.Initialize()")
					end

					print("[ZSDevReload] 已热重载 " .. path)
				end
			end
		end
	end)
end
