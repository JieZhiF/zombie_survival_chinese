-- ============================================================================
-- perf/shared/rewrite_player_index.lua - 性能优化：重写 Player 索引元方法
-- 负责：用更快的 __index 实现替换 Player 元表的默认索引查找，降低高频
--       属性访问的开销；查找顺序：Player 元表 -> Entity 元表 -> 实体自身表
-- ============================================================================

-- 缓存常用元表引用，避免每次查找都重复调用 FindMetaTable
local M_Player = FindMetaTable("Player")
local M_Entity = FindMetaTable("Entity")

-- 缓存 GetTable 方法引用（用于获取实体的 Lua 数据表）
local E_GetTable = M_Entity.GetTable

-- 复用局部变量，避免每次索引调用都新建变量（性能微优化）
local val
local pt
-- ==== Player:__index - 自定义玩家索引查找逻辑 ====
-- 依次在 Player 元表、Entity 元表和实体自身表中查找字段
function M_Player:__index(key)
	-- 先在 Player 元表中查找
	val = M_Player[key]
	if val ~= nil then return val end

	-- 再在 Entity 元表中查找（Player 继承自 Entity）
	val = M_Entity[key]
	if val ~= nil then return val end

	-- 最后查实体自身的 Lua 数据表
	pt = E_GetTable(self)
	if pt then
		return pt[key]
	end
end
