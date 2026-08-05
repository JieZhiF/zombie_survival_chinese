-- ============================================================================
-- noxapi/shared.lua - noxapi 网络 API 层的共享逻辑
-- 负责：为 Player 元表扩展 IsNoxSupporter 方法，用于判断玩家是否为
--       noxiousnet 金/钻石会员（支持者），服务器与客户端通用；
--       支持者不享有任何游戏性优势，仅为身份标识（详见 noxapi.lua 说明）
-- ============================================================================

-- 获取 Player 元表；服务器尚未初始化玩家元表时直接返回
local meta = FindMetaTable("Player")
if not meta then return end

-- ==== Player:IsNoxSupporter - 判断玩家是否为支持者（金/钻石会员） ====
function meta:IsNoxSupporter()
	-- 若存在 noxiousnet 数据库模块(NDB)，直接读取玩家会员等级判断
	if NDB then
		local memberlevel = self:GetMemberLevel()
		-- 金/钻石会员即为支持者
		return memberlevel == MEMBER_GOLD or memberlevel == MEMBER_DIAMOND
	end

	-- 否则读取服务器经 HTTP 查询后写入的网络数据表布尔值（索引 15）
	return self:GetDTBool(15)
end
