-- ============================================================================
-- init.lua - 初始配装逻辑实体（服务器）：设置人类初始/赎回配装
-- 负责：解析地图键值与输入，把"物品:数量"列表写入全局配装表
-- ============================================================================
-- 点实体类型（无模型，纯逻辑）
ENT.Type = "point"

-- ==== Initialize - 空实现：初始化阶段无需处理 ====
function ENT:Initialize()
end

-- ==== Think - 空实现：本实体不执行周期逻辑 ====
function ENT:Think()
end

-- ==== AcceptInput - 地图输入处理：动态修改初始/赎回配装 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "setstartingloadout" then
		-- 设置初始配装（键值格式："物品1:数量,物品2:数量"）
		self:SetKeyValue("startingloadout", args)

		return true
	elseif name == "setredeemloadout" then
		-- 设置赎回配装
		self:SetKeyValue("redeemloadout", args)

		return true
	end
end

-- ==== KeyValue - Hammer 键值处理：解析配装字符串并写入全局配置 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "startingloadout" then
		if value == "worth" then
			-- "worth"：按初始资金购买力决定配装
			GAMEMODE.StartingLoadout = nil
		elseif value == "none" then
			-- "none"：空配装
			GAMEMODE.StartingLoadout = {}
		else
			-- 解析"物品:数量"逗号分隔列表，写入初始配装表
			local tab = {}
			for k, v in pairs(string.Explode(",", value)) do
				local item, amount = string.match(v, "(.+):(%d+)")
				if item and amount then
					tab[item] = tonumber(amount) or 1
				end
			end

			GAMEMODE.StartingLoadout = tab
		end
	elseif key == "redeemloadout" then
		if value == "none" then
			-- "none"：空赎回配装
			GAMEMODE.RedeemLoadout = {}
		else
			-- 解析"物品:数量"列表，写入赎回配装表
			local tab = {}
			for k, v in pairs(string.Explode(",", value)) do
				local item, amount = string.match(v, "(.+):(%d+)")
				if item and amount then
					tab[item] = tonumber(amount) or 1
				end
			end

			GAMEMODE.RedeemLoadout = tab
		end
	end
end
