-- ============================================================================
-- gmapex/gmapex.lua - 地图扩展(GMAPEX)系统的入口文件
-- 负责：定义 GMAPEX 全局命名空间，并按照运行环境（服务器/客户端）
--       分发加载本模块的其余文件：config / sh_serialization / server / client
-- ============================================================================

-- 防重复加载：GMAPEX 已存在时直接返回
if GMAPEX then return end

-- 地图扩展系统的全局命名空间表
GMAPEX = {}

-- 服务器端：把共享与客户端文件加入客户端下载列表
if SERVER then
	-- 权限配置与序列化工具需要在客户端同步
	AddCSLuaFile("config.lua")
	AddCSLuaFile("sh_serialization.lua")
	AddCSLuaFile("client.lua")
end

-- 服务器与客户端都需加载：权限配置与序列化工具
include("config.lua")
include("sh_serialization.lua")

-- 服务器端额外加载服务器逻辑
if SERVER then
	include("server.lua")
end

-- 客户端额外加载客户端逻辑
if CLIENT then
	include("client.lua")
end
