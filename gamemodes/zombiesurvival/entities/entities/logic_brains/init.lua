-- ============================================================================
-- init.lua - 大脑点数逻辑实体（服务器）：供地图对僵尸玩家操作大脑点数
-- 负责：增删/设定僵尸玩家的脑数，并支持赎回（Redeem）相关地图输入
-- ============================================================================
-- 继承点数逻辑实体（复用其通用输入处理框架）
ENT.Base = "logic_points"
-- 点实体类型（无模型，纯逻辑）
ENT.Type = "point"

-- ==== Add - 增删脑数：仅对僵尸玩家生效，负数取脑、正数加脑 ====
function ENT:Add(pl, amount)
	if pl and pl:IsValidZombie() then
		amount = math.Round(amount)
		if amount < 0 then
			pl:TakeBrains(-amount)
		else
			pl:AddBrains(amount)
		end
	end
end

-- ==== SetAmount - 设定脑数：直接写入击杀数并修正累计"已吃脑"统计 ====
function ENT:SetAmount(pl, amount)
	local diff = amount - self:GetAmount(pl)
	pl:SetFrags(amount)
	pl.BrainsEaten = pl.BrainsEaten + diff
	-- 更新后检查是否达到赎回条件
	pl:CheckRedeem()
end

-- ==== GetAmount - 读取脑数：脑数以玩家的击杀数（Frags）存储 ====
function ENT:GetAmount(pl)
	return pl:Frags()
end

-- ==== AcceptInput - 地图输入处理：设置赎回脑数、触发僵尸赎回 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	if name == "setredeembrains" then
		-- 设定全局赎回所需脑数
		GAMEMODE:SetRedeemBrains(tonumber(args) or 0)
	elseif name == "redeemactivator" then
		-- 让触发者（须为亡灵阵营）执行赎回
		if activator and activator:IsValid() and activator:IsPlayer() and activator:Team() == TEAM_UNDEAD then
			activator:Redeem()
		end
	elseif name == "redeemcaller" then
		-- 让调用者（须为亡灵阵营）执行赎回
		if caller and caller:IsValid() and caller:IsPlayer() and caller:Team() == TEAM_UNDEAD then
			caller:Redeem()
		end
	else
		-- 其余输入交给父类（点数逻辑）处理
		self.BaseClass.AcceptInput(self, name, activator, caller, args)
	end
end
