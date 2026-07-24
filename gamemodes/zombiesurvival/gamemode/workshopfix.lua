-- ============================================================
-- 文件: workshopfix.lua
-- 作用: 共享脚本（同时在服务器和客户端运行）
-- 功能: 修复工坊版本中自定义实体、特效和武器未能正确加载的问题
--       当通过 Workshop 订阅本 Addon 时，标准的实体注册机制可能失效
--       此脚本手动遍历并注册所有自定义内容
-- ============================================================

-- 注册本文件为 CSLua 文件，使其能被发送到客户端
AddCSLuaFile()

-- 感谢 Garry 先生修复了这个存在数月的 bug！（备注：实际上这是在手动修复加载问题）

-- ============================================================
-- 检测实体常量
-- 用于判断我们的自定义实体是否已通过正常机制加载
-- 如果 prop_nail 没有被注册，说明加载失败，需要手动加载
-- ============================================================
local ENTITYCLASS = "prop_nail"

-- ============================================================
-- 主加载 Hook
-- 在游戏初始化时触发，检查并手动加载所有自定义内容
-- ============================================================
hook.Add("Initialize", "workshop", function()

	-- 如果目标实体已存在于注册表中，说明正常加载成功，无需处理
	if scripted_ents.GetStored(ENTITYCLASS) ~= nil then return end

	-- 打印日志，提示正在使用 Workshop 版本的手动加载方式
	print("Workshop version...")

	-- 获取游戏模式的文件夹名称
	local gmfoldername = GAMEMODE.FolderName

	-- 构建实体、特效和武器的路径前缀
	local entitiespath = gmfoldername .. "/entities/entities/"
	local effectspath = gmfoldername .. "/entities/effects/"
	local weaponspath = gmfoldername .. "/entities/weapons/"

	-- ============================================================
	-- 实体加载（单文件形式）
	-- 扫描实体目录下的所有文件，逐文件注册
	-- ============================================================
	local files, folders = file.Find(entitiespath .. "*", "LUA")

	-- 处理单文件实体
	for _, filename in pairs(files) do
		ENT = {}
		ENT.Folder = entitiespath
		ENT.FolderName = filename

		include(entitiespath .. filename)

		scripted_ents.Register(ENT, string.StripExtension(filename))
	end

	-- ============================================================
	-- 实体加载（文件夹形式，包含 init.lua / cl_init.lua / shared.lua）
	-- ============================================================
	for _, foldername in pairs(folders) do
		ENT = {}
		ENT.Folder = entitiespath .. foldername
		ENT.FolderName = foldername

		-- 服务端加载 init.lua 或 shared.lua
		if SERVER then
			if file.Exists(entitiespath .. foldername .. "/init.lua", "LUA") then
				include(entitiespath .. foldername .. "/init.lua")
			elseif file.Exists(entitiespath .. foldername .. "/shared.lua", "LUA") then
				include(entitiespath .. foldername .. "/shared.lua")
			end
		end

		-- 客户端加载 cl_init.lua 或 shared.lua
		if CLIENT then
			if file.Exists(entitiespath .. foldername .. "/cl_init.lua", "LUA") then
				include(entitiespath .. foldername .. "/cl_init.lua")
			elseif file.Exists(entitiespath .. foldername .. "/shared.lua", "LUA") then
				include(entitiespath .. foldername .. "/shared.lua")
			end
		end

		-- 注册实体
		scripted_ents.Register(ENT, foldername)
	end

	-- ============================================================
	-- 特效加载（单文件形式）
	-- 扫描特效目录下的所有文件，在客户端注册
	-- ============================================================
	files, folders = file.Find(effectspath .. "*", "LUA")

	-- 处理单文件特效
	for _, filename in pairs(files) do
		-- 在服务端，只需要将文件添加到 CSLua 列表以便发送给客户端
		if SERVER then
			AddCSLuaFile(effectspath .. filename)
		end
		-- 在客户端，实际包含并注册特效
		if CLIENT then
			EFFECT = {}
			EFFECT.Folder = effectspath
			EFFECT.FolderName = filename

			include(effectspath .. filename)

			effects.Register(EFFECT, string.StripExtension(filename))
		end
	end

	-- ============================================================
	-- 特效加载（文件夹形式）
	-- ============================================================
	for _, foldername in pairs(folders) do
		-- 服务端：将 init.lua 添加到 CSLua 传输列表
		if SERVER and file.Exists(effectspath .. foldername .. "/init.lua", "LUA") then
			AddCSLuaFile(effectspath .. foldername .. "/init.lua")
		end

		-- 客户端：包含并注册特效
		if CLIENT and file.Exists(effectspath .. foldername .. "/init.lua", "LUA") then
			EFFECT = {}
			EFFECT.Folder = effectspath .. foldername
			EFFECT.FolderName = foldername

			include(effectspath .. foldername .. "/init.lua")

			effects.Register(EFFECT, foldername)
		end
	end

	-- ============================================================
	-- 武器加载（单文件形式）
	-- 扫描武器目录下的所有文件，逐文件注册 SWEP
	-- ============================================================
	files, folders = file.Find(weaponspath .. "*", "LUA")

	-- 处理单文件武器
	for _, filename in pairs(files) do
		SWEP = {}
		SWEP.Folder = weaponspath
		SWEP.FolderName = filename
		SWEP.Base = "weapon_base"

		SWEP.Primary = {}
		SWEP.Secondary = {}

		include(weaponspath .. filename)

		weapons.Register(SWEP, string.StripExtension(filename))
	end

	-- ============================================================
	-- 武器加载（文件夹形式，包含 init.lua / cl_init.lua / shared.lua）
	-- ============================================================
	for _, foldername in pairs(folders) do
		SWEP = {}
		SWEP.Folder = weaponspath .. foldername
		SWEP.FolderName = foldername
		SWEP.Base = "weapon_base"

		SWEP.Primary = {}
		SWEP.Secondary = {}

		-- 服务端加载 init.lua 或 shared.lua
		if SERVER then
			if file.Exists(weaponspath .. foldername .. "/init.lua", "LUA") then
				include(weaponspath .. foldername .. "/init.lua")
			elseif file.Exists(weaponspath .. foldername .. "/shared.lua", "LUA") then
				include(weaponspath .. foldername .. "/shared.lua")
			end
		end

		-- 客户端加载 cl_init.lua 或 shared.lua
		if CLIENT then
			if file.Exists(weaponspath .. foldername .. "/cl_init.lua", "LUA") then
				include(weaponspath .. foldername .. "/cl_init.lua")
			elseif file.Exists(weaponspath .. foldername .. "/shared.lua", "LUA") then
				include(weaponspath .. foldername .. "/shared.lua")
			end
		end

		-- 注册武器
		weapons.Register(SWEP, foldername)
	end

	-- 清理全局变量，避免污染全局命名空间
	ENT = nil
	EFFECT = nil
	SWEP = nil

end)
