-- ============================================================================
-- gmapex/shared.lua - 地图扩展(GMAPEX)系统的共享逻辑
-- 负责：初始化时注册地图扩展脚本实体；定义 scripted_ents.RegisterFromFile
--       实体注册辅助函数，以及为实体网络数据表(DT)生成 Set/Get 访问器的
--       AccessorFuncDT；并挂接 Initialize 钩子完成初始化
-- ============================================================================

-- ==== GMAPEX:Initialize - 初始化地图扩展系统 ====
-- 在 Initialize 阶段注册本系统所需的脚本实体
function GMAPEX:Initialize()
	-- 按文件名注册脚本实体（point_lentmanentity.lua 实体脚本由外部提供，本仓库未包含）
	scripted_ents.RegisterFromFile("point_lentmanentity.lua")
end

-- ==== scripted_ents.RegisterFromFile - 从 Lua 脚本文件注册脚本实体 ====
-- 定义(或覆盖)全局注册函数：清空 ENT 表后 include 实体脚本，
-- 并以"去掉 .lua 后缀并转小写"的文件名作为类名注册到 scripted_ents
function scripted_ents.RegisterFromFile(filename)
	-- 清空全局 ENT 表，供被 include 的脚本填充实体定义
	ENT = {}
	-- 加载实体脚本文件（脚本内写入 ENT.* 定义）
	include(filename)
	-- 以去除扩展名并转为小写的文件名作为类名注册脚本实体
	scripted_ents.Register(filename:sub(1, -5):lower(), filename)
end

-- ==== AccessorFuncDT - 生成实体网络数据表(DT)的访问器方法 ====
-- 为传入的表(通常是 ENT 定义)生成 Set<成员名>/Get<成员名> 两个方法，
-- 封装对实体网络数据表(DT)指定索引的读写，用于跨服务器/客户端同步数据
-- @param tab 要挂载访问器的表（如 ENT）
-- @param membername 成员名，将拼出 SetXXX/GetXXX 方法名
-- @param type 网络数据类型（String/Int/Float/Bool 等，对应 GetDTXXX/SetDTXXX）
-- @param id 网络数据表(DT)中的索引号
function AccessorFuncDT(tab, membername, type, id)
	local emeta = FindMetaTable("Entity")
	-- 按类型取出对应的网络数据表写函数（如 SetDTString）
	local setter = emeta["SetDT"..type]
	local getter = emeta["GetDT"..type]

	-- 生成 Set 方法：把值写入指定 DT 索引
	tab["Set"..membername] = function(me, val)
		setter(me, id, val)
	end

	-- 生成 Get 方法：从指定 DT 索引读出值
	tab["Get"..membername] = function(me)
		return getter(me, id)
	end
end

-- 挂接 Initialize 钩子：游戏初始化时调用 GMAPEX:Initialize 完成注册
hook.Add("Initialize", "gmapex", function() GMAPEX:Initialize() end)
