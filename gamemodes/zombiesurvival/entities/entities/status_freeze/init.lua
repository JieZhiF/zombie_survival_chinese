-- ============================================================================
-- init.lua - 冰冻 buff 状态（服务端）
-- 负责：时长累加(Extend)、阶段3定身/禁攻/冰刺生成、阶段1/2减速
--       冰刺：生成 env_protrusionspike 附着玩家（半透明蓝刺，跟随移动）
-- ============================================================================
INC_SERVER()

local CurTime = CurTime
local IsValid = IsValid

-- ==== SetDie - 设置状态结束时间：覆盖基类以支持特殊时长值 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		-- 0 或空值：立即解除冰冻
		self.DieTime = 0
	elseif fTime == -1 then
		-- -1：永久冻结（近似无限时长）
		self.DieTime = 999999999
	else
		-- 普通数值：按当前时间加上给定秒数，并同步客户端总时长
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end

-- ==== Extend - 累加冰冻时长 ====
-- 供连续命中时叠加冰冻效果；若已到期则重新开始计时
function ENT:Extend(fTime)
	if self.DieTime <= CurTime() then
		self:SetDie(fTime)
	else
		self.DieTime = self.DieTime + fTime
		self:SetDuration(self:GetDuration() + fTime)
	end
	Msg("[FREEZE-DBG] 状态累加 -> 剩余 " .. self:GetRemaining() .. "s 阶段=" .. self:GetStage() .. "\n")
end

-- ==== PlayerSet - 状态附加到玩家：记录开始时间并注册服务端钩子 ====
-- 注意：服务端会覆盖 shared.lua 的同名方法，必须在此设置 StartTime，
--       否则阶段计算（StartTime + Duration - CurTime）恒为 0，效果全部失效
function ENT:PlayerSet(pPlayer, bExists)
	self:SetStartTime(CurTime())

	hook.Add("Move", self, self.Move)
	hook.Add("PlayerButtonDown", self, self.PlayerButtonDown)

	if pPlayer:IsValid() then
		pPlayer:PrintMessage(HUD_PRINTTALK, "[冰冻] 冰冻开始生效 (减速 40%)")
	end
	Msg("[FREEZE-DBG] 状态附加到 " .. (pPlayer:IsValid() and pPlayer:Name() or "?") .. " 时长=" .. self:GetDuration() .. "s\n")
end

-- ==== Move - 移动钩子：阶段1/2按阶段比例减速 ====
function ENT:Move(pl, move)
	if pl ~= self:GetOwner() then return end

	local factor = self:GetSlowFactor()
	if factor < 1 then
		move:SetMaxSpeed(move:GetMaxSpeed() * factor)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * factor)
	end
end

-- ==== PlayerButtonDown - 按键拦截：完全冻结时禁止攻击 ====
function ENT:PlayerButtonDown(pl, button)
	if pl ~= self:GetOwner() then return end
	if not self:IsFullyFrozen() then return end

	if button == IN_ATTACK or button == IN_ATTACK2 then
		return true
	end
end

-- ==== Think - 每帧逻辑：死亡解除 + 阶段3定身/冰刺切换 ====
function ENT:Think()
	self.BaseClass.Think(self)

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	-- 死亡立即解除冰冻
	if not owner:Alive() then
		Msg("[FREEZE-DBG] " .. owner:Name() .. " 死亡, 解除冰冻\n")
		self:Remove()
		return
	end

	local stage = self:GetStage()

	-- 阶段升级提示（阶段2/3）
	if stage > (self.LastStage or 1) then
		if stage == 2 then
			owner:PrintMessage(HUD_PRINTTALK, "[冰冻] 冰冻加深! (减速 75%)")
		elseif stage == 3 then
			owner:PrintMessage(HUD_PRINTTALK, "[冰冻] 完全冻结! 无法移动和攻击")
		end
		Msg("[FREEZE-DBG] " .. owner:Name() .. " 阶段 " .. (self.LastStage or 1) .. " -> " .. stage .. " 剩余=" .. self:GetRemaining() .. "s\n")
	end
	self.LastStage = stage

	-- 进入/离开完全冻结阶段时：定身 + 生成/移除冰刺
	if self:IsFullyFrozen() and not self.Frozen then
		self.Frozen = true
		owner:Freeze(true)
		self:CreateSpikes()
	elseif not self:IsFullyFrozen() and self.Frozen then
		self.Frozen = nil
		owner:Freeze(false)
		self:RemoveSpikes()
	end
end

-- ==== CreateSpikes - 完全冻结：生成 env_protrusionspike 冰刺附着玩家 ====
-- 半透明蓝色尖刺从玩家身体伸出并跟随移动（类似 RA3 冰冻效果）
function ENT:CreateSpikes()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local spike = ents.Create("env_protrusionspike")
	if IsValid(spike) then
		spike:SetOwner(owner)
		spike:SetFreezeMode(true)
		spike:SetPos(owner:GetPos())
		spike:Spawn()
		self.Spike = spike
		Msg("[FREEZE-DBG] " .. owner:Name() .. " 完全冻结, 生成 env_protrusionspike 冰刺\n")
	end
end

-- ==== RemoveSpikes - 解冻：移除冰刺 ====
function ENT:RemoveSpikes()
	if self.Spike and self.Spike:IsValid() then
		self.Spike:Remove()
	end
	self.Spike = nil
end

-- ==== OnRemove - 移除时：解冻、清冰刺、移除钩子 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if IsValid(owner) and self.Frozen then
		owner:Freeze(false)
	end

	self:RemoveSpikes()

	hook.Remove("Move", self)
	hook.Remove("PlayerButtonDown", self)
end
