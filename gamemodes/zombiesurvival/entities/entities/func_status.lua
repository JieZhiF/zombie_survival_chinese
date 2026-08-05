-- ============================================================================
-- func_status - 状态区域触发实体（刷子实体）
-- 负责：玩家进入/离开区域时自动给予/移除状态效果，支持 Hammer 键值配置状态名、持续时长与残留模式
-- ============================================================================

-- 实体类型：刷子（触发器）实体
ENT.Type = "brush"

-- 状态施加的检查间隔（秒）：每 0.5 秒对区域内玩家刷新一次状态
ENT.TickTime = 0.5

-- ==== Initialize - 设置为触发器并按间隔循环触发 attack 输入，补全各 Hammer 键值默认值 ====
function ENT:Initialize()
	self:SetTrigger(true)
	self:Fire("attack", "", self.TickTime)

	-- 键值缺省时采用默认值：默认开启、缓慢状态、不残留、持续 5 秒
	if self.On == nil then self.On = true end
	if self.Status == nil then self.Status = "slow" end
	if self.Linger == nil then self.Linger = false end
	if self.Duration == nil then self.Duration = 5 end
end

-- ==== Think - 空实现（核心逻辑由周期性 attack 输入驱动） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理 seton/enable/disable/attack 输入，attack 时对区域内存活人类周期性施加状态 ====
function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	if name == "seton" then
		self.On = tonumber(arg) == 1
		return true
	elseif name == "enable" then
		self.On = true
		return true
	elseif name == "disable" then
		self.On = false
		return true
	elseif name == "attack" then
		self:Fire("attack", "", self.TickTime)

		-- 遍历所有存活人类玩家：若其处于本区域内且尚未携带该状态则给予
		for k,v in pairs(player.GetAll()) do
			if v:IsValidLivingHuman() and v.StatusZone == self then
				if not IsValid(v["status_" .. self.Status]) then
					v:GiveStatus(self.Status, self.Duration)
				end
			end
		end

		return true
	end
end

-- ==== KeyValue - 解析 Hammer 键值：enabled/status/linger/duration ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "enabled" then
		self.On = tonumber(value) == 1
	elseif key == "status" then
		-- 状态名仅允许 slow/dimvision/enfeeble/frost，其余一律回退为 slow
		local val = string.lower(value)
		self.Status = (val == "slow" or val == "dimvision" or val == "enfeeble" or val == "frost") and val or "slow"
	elseif key == "linger" then
		self.Linger = tonumber(value) == 1
	elseif key == "duration" then
		self.Duration = tonumber(value)
	end
end

-- ==== Enter - 玩家进入区域时登记其状态区域归属 ====
function ENT:Enter(ent)
	ent.StatusZone = self
end

-- ==== Leave - 玩家离开区域时按 linger 配置决定是否立即移除状态 ====
function ENT:Leave(ent)
	-- 未开启残留模式时，离开即移除该状态
	if not self.Linger then
		if IsValid(ent["status_" .. self.Status]) then
			ent:RemoveStatus(self.Status)
		end
	end

	ent.StatusZone = nil
end

-- ==== Touch - 区域被关闭时，仍停留在区域内的玩家立即移除状态 ====
function ENT:Touch(ent)
	if not self.On and ent:IsPlayer() and ent.StatusZone == self then
		self:Leave(ent)
	end
end

-- ==== StartTouch - 开启状态下的区域：存活人类玩家进入时登记并开始施加状态 ====
function ENT:StartTouch(ent)
	if self.On and ent:IsPlayer() and ent:Alive() and ent:Team() == TEAM_HUMAN and not ent.StatusZone then
		self:Enter(ent)
	end
end

-- ==== EndTouch - 玩家离开区域时解除登记 ====
function ENT:EndTouch(ent)
	if ent:IsPlayer() and ent.StatusZone == self then
		self:Leave(ent)
	end
end
