-- ============================================================================
-- init.lua - 僵尸毒气区域（服务端）：周期性对范围内的玩家施加状态
-- 负责：按 TickTime 周期触发攻击输入，对圈内可见的活人施加增益/减速状态
-- ============================================================================
INC_SERVER()

-- 毒气攻击的触发间隔（秒），用于 Fire("attack") 自循环计时
ENT.TickTime = 0.5

-- ==== Initialize - 实体初始化：关闭阴影并启动周期攻击循环 ====
function ENT:Initialize()
	self:DrawShadow(false)
	self:Fire("attack", "", self.TickTime)

	-- 未通过 KeyValue 指定半径时使用默认值 400
	if self:GetRadius() == 0 then self:SetRadius(400) end
end

-- ==== KeyValue - 解析 Hammer 地图实体键值 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "radius" then
		self:SetRadius(tonumber(value))
	end
end

-- ==== AcceptInput - 处理攻击输入：对圈内可见活人施加对应状态 ====
function ENT:AcceptInput(name, activator, caller, arg)
	if name ~= "attack" then return end

	-- 僵尸逃跑模式下禁用毒气效果
	if GAMEMODE.ZombieEscape then
		return true
	end

	-- 重新调度下一次攻击，形成周期循环
	self:Fire("attack", "", self.TickTime)

	local vPos = self:GetPos()

	-- 遍历毒气半径内的实体，仅处理与世界空间互相可见的存活玩家
	for _, ent in pairs(ents.FindInSphere(vPos, self:GetRadius())) do
		if ent and ent:IsValidLivingPlayer() and WorldVisible(vPos, ent:WorldSpaceCenter()) then
			if ent:Team() == TEAM_UNDEAD then
				-- 僵尸每 3 秒仅能获得一次出生增益，防止刷新叠加
				if CurTime() >= (ent.LastRangedAttack or 0) + 3 then
					ent:GiveStatus("zombiespawnbuff", self.TickTime + 0.1)
				end
			elseif GAMEMODE:GetWave() ~= 0 then
				-- 人类在波次进行中受到出生减速状态
				ent:GiveStatus("spawnslow", self.TickTime + 0.1)
			end
		end
	end

	return true
end
