
-- ============================================================================
-- sh_translate.lua - 多语言翻译系统（i18n）
-- 负责：管理已注册语言（Languages）与全部翻译条目（Translations）、
--       提供 translate.Get/Format 以及按玩家语言动态解析的
--       ClientGet/ClientFormat（服务端读取玩家 gmod_language_rep 变量），
--       自动加载 gamemode/languages/ 目录下所有语言文件，
--       并扩展 Player:PrintTranslatedMessage 方法。
-- ============================================================================
-- =====================================================================
-- 翻译库 by William Moodhe
-- 欢迎在你的插件中使用本库
-- 查看 languages 文件夹以添加你自己的语言
-- =====================================================================

-- =====================================================================
-- translate 全局表：所有翻译相关函数都挂载在此表下
-- =====================================================================
translate = {}

-- =====================================================================
-- 内部变量定义
-- =====================================================================

-- Languages 表：存储所有已注册的语言，key=短名称，value=长名称
-- 例如：Languages["zh-CN"] = "简体中文"
local Languages = {}

-- Translations 表：存储所有语言的所有翻译条目，三层结构：
-- Translations[语言短名称][翻译ID] = 翻译文本
local Translations = {}

-- AddingLanguage：当前正在添加翻译的语言短名称，由 AddLanguage() 设置
local AddingLanguage

-- DefaultLanguage：默认语言，当玩家语言没有对应翻译时回退到此语言
local DefaultLanguage = "zh-CN"

-- CurrentLanguage：当前使用的语言，会随玩家设置动态变化
local CurrentLanguage = DefaultLanguage

-- =====================================================================
-- 客户端初始化
-- 创建控制台变量、监听语言变化并通知服务器
-- =====================================================================
if CLIENT then
    -- 创建客户端控制台变量 gmod_language_rep，
    -- 因为 gmod_language 不会被自动发送到服务器，需要这个副本变量来传递
    CreateClientConVar("gmod_language_rep", "en", false, true)

    -- 读取当前游戏语言设置
    CurrentLanguage = GetConVarString("gmod_language")

    -- 每秒检查一次语言是否改变
    timer.Create("checklanguagechange", 1, 0, function()
        CurrentLanguage = GetConVarString("gmod_language")
        if CurrentLanguage ~= GetConVarString("gmod_language_rep") then
            -- 如果语言发生变化，通过 RunConsoleCommand 通知服务器
            RunConsoleCommand("gmod_language_rep", CurrentLanguage)
        end
    end)
end

-- =====================================================================
-- translate.GetLanguages()
-- 功能：获取所有已注册的语言列表
-- 返回：Languages 表（key=语言短名称，value=语言长名称）
-- =====================================================================
function translate.GetLanguages()
	return Languages
end

-- =====================================================================
-- translate.GetLanguageName(short)
-- 功能：根据语言短名称获取语言长名称
-- 参数：short - 语言短名称字符串，如 "zh-CN"
-- 返回：语言长名称字符串，如 "简体中文"
-- =====================================================================
function translate.GetLanguageName(short)
	return Languages[short]
end

-- =====================================================================
-- translate.GetTranslations(short)
-- 功能：获取指定语言的所有翻译条目
-- 参数：short - 语言短名称字符串
-- 返回：翻译条目表，如果该语言不存在则返回默认语言的翻译表
-- =====================================================================
function translate.GetTranslations(short)
	return Translations[short] or Translations[DefaultLanguage]
end

-- =====================================================================
-- translate.AddLanguage(short, long)
-- 功能：注册一种新语言
-- 参数：short - 语言短名称（如 "zh-CN"）
--       long  - 语言长名称（如 "简体中文"）
-- 说明：同时会初始化该语言的翻译空表，并设置 AddingLanguage
--       为后续 AddTranslation 调用指定目标语言
-- =====================================================================
function translate.AddLanguage(short, long)
	Languages[short] = long
	Translations[short] = Translations[short] or {}
	AddingLanguage = short
end

-- =====================================================================
-- translate.AddTranslation(id, text)
-- 功能：向当前正在添加的语言中添加一条翻译条目
-- 参数：id   - 翻译标识符字符串
--       text - 翻译文本字符串
-- 说明：必须在 AddLanguage 之后调用，AddingLanguage 必须有效
-- =====================================================================
function translate.AddTranslation(id, text)
	if not AddingLanguage or not Translations[AddingLanguage] then return end

	Translations[AddingLanguage][id] = text
end

-- =====================================================================
-- translateGet(id) - 内部函数
-- 功能：根据当前语言的翻译表获取指定翻译 ID 的文本
-- 参数：id - 翻译标识符字符串
-- 返回：翻译文本字符串
--       当前语言找不到则回退到默认语言，还找不到则返回 "@id@" 格式的占位符
-- =====================================================================
local function translateGet(id)
	return translate.GetTranslations(CurrentLanguage)[id] or translate.GetTranslations(DefaultLanguage)[id] or ("@"..id.."@")
end

-- =====================================================================
-- translateFormat(id, ...) - 内部函数
-- 功能：获取翻译文本并用指定参数进行格式化（string.format）
-- 参数：id - 翻译标识符字符串
--       ... - string.format 需要的额外参数
-- 返回：格式化后的翻译文本字符串
-- =====================================================================
local function translateFormat(id, ...)
	return string.format(translateGet(id), ...)
end

-- =====================================================================
-- 服务端翻译函数
-- 客户端调用这些函数时，CurrentLanguage 会从玩家信息中获取
-- =====================================================================
if SERVER then
	-- =====================================================================
	-- translate.Get(id) - 服务端版本
	-- 功能：获取默认语言的翻译文本（服务端直接使用默认语言）
	-- 参数：id - 翻译标识符字符串
	-- 返回：翻译文本字符串
	-- =====================================================================
	function translate.Get(id)
		CurrentLanguage = DefaultLanguage
		return translateGet(id)
	end
	
	-- =====================================================================
	-- translate.ClientGet(pl, ...)
	-- 功能：根据指定玩家的语言设置获取翻译文本
	-- 参数：pl  - 玩家 Player 对象
	--       ... - 不定参数，第一个应为翻译 ID
	-- 返回：翻译文本字符串
	-- 说明：从玩家的 gmod_language_rep 控制台变量获取其语言设置
	-- =====================================================================
	function translate.ClientGet(pl, ...)
		CurrentLanguage = pl:GetInfo("gmod_language_rep")
		return translateGet(...)
	end
	
	-- =====================================================================
	-- translate.Format(id, ...) - 服务端版本
	-- 功能：获取默认语言翻译文本并进行格式化
	-- 参数：id - 翻译标识符字符串
	--       ... - string.format 参数
	-- 返回：格式化后的翻译文本字符串
	-- =====================================================================
	function translate.Format(id, ...)
		CurrentLanguage = DefaultLanguage
		return translateFormat(id, ...)
	end
	
	-- =====================================================================
	-- translate.ClientFormat(pl, ...)
	-- 功能：根据指定玩家的语言设置获取格式化后的翻译文本
	-- 参数：pl  - 玩家 Player 对象
	--       ... - 不定参数，第一个应为翻译 ID，后续为格式化参数
	-- 返回：格式化后的翻译文本字符串
	-- =====================================================================
	function translate.ClientFormat(pl, ...)
		CurrentLanguage = pl:GetInfo("gmod_language_rep")
		return translateFormat(...)
	end
	
	-- =====================================================================
	-- PrintTranslatedMessage(printtype, str, ...)
	-- 功能：向所有玩家发送翻译后的提示消息
	-- 参数：printtype - 消息类型（如 HUD_PRINTTALK）
	--       str       - 翻译 ID 字符串
	--       ...       - 格式化参数
	-- 说明：遍历所有在线玩家，根据各自的语言设置发送消息
	-- =====================================================================
	function PrintTranslatedMessage(printtype, str, ...)
		for _, pl in pairs(player.GetAll()) do
			pl:PrintMessage(printtype, translate.ClientFormat(pl, str, ...))
		end
	end
end

-- =====================================================================
-- 客户端翻译函数
-- 客户端直接使用自身的 CurrentLanguage 设置
-- =====================================================================
if CLIENT then
	-- =====================================================================
	-- translate.Get(id) - 客户端版本
	-- 功能：获取当前客户端语言设置的翻译文本
	-- 参数：id - 翻译标识符字符串
	-- 返回：翻译文本字符串
	-- =====================================================================
	function translate.Get(id)
		return translateGet(id)
	end
	
	-- =====================================================================
	-- translate.ClientGet(_, ...) - 客户端版本
	-- 功能：客户端忽略玩家参数，直接使用当前语言获取翻译
	-- 参数：_  - 占位，忽略的玩家参数
	--       ... - 不定参数，第一个应为翻译 ID
	-- 返回：翻译文本字符串
	-- =====================================================================
	function translate.ClientGet(_, ...)
		return translateGet(...)
	end
	
	-- =====================================================================
	-- translate.Format(id, ...) - 客户端版本
	-- 功能：获取当前客户端语言设置的翻译文本并进行格式化
	-- 参数：id - 翻译标识符字符串
	--       ... - string.format 参数
	-- 返回：格式化后的翻译文本字符串
	-- =====================================================================
	function translate.Format(id, ...)
		return translateFormat(id, ...)
	end
	
	-- =====================================================================
	-- translate.ClientFormat(_, ...) - 客户端版本
	-- 功能：客户端忽略玩家参数，直接使用当前语言获取格式化翻译
	-- 参数：_  - 占位，忽略的玩家参数
	--       ... - 不定参数，第一个应为翻译 ID，后续为格式化参数
	-- 返回：格式化后的翻译文本字符串
	-- =====================================================================
	function translate.ClientFormat(_, ...)
		return translateFormat(...)
	end
end

-- =====================================================================
-- 加载语言文件
-- 遍历 gamemode/languages/ 目录下的所有 *.lua 语言文件
-- 每个文件应定义全局 LANGUAGE 表，键值对为 id -> 翻译文本
-- =====================================================================
for i, filename in pairs(file.Find(GM.FolderName.. "/gamemode/languages/*.lua", "LUA")) do
	-- 初始化 LANGUAGE 表，语言文件会向此表写入翻译条目
	LANGUAGE = {}
	-- 告知客户端需要下载该语言文件（GMod 的 AddCSLuaFile 机制）
	AddCSLuaFile("languages/"..filename)
	-- 服务端包含并执行该语言文件，填充 LANGUAGE 表
	include("languages/"..filename)
	-- 将 LANGUAGE 表中的所有条目注册到翻译系统
	for k, v in pairs(LANGUAGE) do
		translate.AddTranslation(k, v)
	end
	-- 清理 LANGUAGE 表，避免后续文件混淆
	LANGUAGE = nil
end

-- =====================================================================
-- 扩展 Player 元表：添加翻译消息打印方法
-- 获取 Player 元表以便添加新的成员函数
-- =====================================================================
local meta = FindMetaTable("Player")
if not meta then return end

-- =====================================================================
-- Player:PrintTranslatedMessage(hudprinttype, translateid, ...)
-- 功能：向指定玩家发送翻译后的消息
-- 参数：hudprinttype - HUD 消息类型（如 HUD_PRINTTALK）
--       translateid  - 翻译 ID 字符串
--       ...          - 可选的格式化参数
-- 说明：如果提供了格式化参数则使用 ClientFormat，
--       否则直接使用 ClientGet 获取翻译文本
-- =====================================================================
function meta:PrintTranslatedMessage(hudprinttype, translateid, ...)
	if ... ~= nil then
		self:PrintMessage(hudprinttype, translate.ClientFormat(self, translateid, ...))
	else
		self:PrintMessage(hudprinttype, translate.ClientGet(self, translateid))
	end
end
