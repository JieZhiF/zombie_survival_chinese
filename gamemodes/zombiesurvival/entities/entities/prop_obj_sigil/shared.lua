-- ============================================================================
-- prop_obj_sigil/shared.lua - 符印目标实体（共享端）
-- 负责：符印血量/回复/腐蚀状态的网络同步与访问接口，以及可被伤害阵营判定
-- ============================================================================

INC_SHARED()
ENT.Type = "anim"

-- 符印最大生命值
ENT.MaxHealth = 888
-- 每秒生命回复量
ENT.HealthRegen = 40
-- 受击后开始回复的延迟秒数
ENT.RegenDelay = 2

-- 模型缩放比例
ENT.ModelScale = 0.55

-- 禁止被钉子拆解/固定（符印不可被玩家建造系统修改）
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true
-- 符印属于路障类物体（正常状态可被僵尸攻击）
ENT.IsBarricadeObject = true

-- 网络变量：基础血量 / 每秒回复量 / 上次受击时间
AccessorFuncDT(ENT, "SigilHealthBase", "Float", 0)
AccessorFuncDT(ENT, "SigilHealthRegen", "Float", 1)
AccessorFuncDT(ENT, "SigilLastDamaged", "Float", 2)

-- ==== SetSigilCorrupted - 设置腐蚀状态 ====
-- 符印被腐蚀后不再是路障，且碰撞组改变；服务器负责同步腐蚀标记
function ENT:SetSigilCorrupted(corrupt)
	-- 腐蚀后不再是路障物体（转为可穿透碰撞组）
	self.IsBarricadeObject = not corrupt

	if SERVER then
		self:SetCollisionGroup(corrupt and COLLISION_GROUP_DEBRIS_TRIGGER or COLLISION_GROUP_NONE)
	end

	-- 通知引擎碰撞规则已变更
	self:CollisionRulesChanged()

	-- 同步腐蚀状态到客户端
	self:SetDTBool(0, corrupt)
end

-- ==== GetSigilCorrupted - 读取腐蚀状态 ====
function ENT:GetSigilCorrupted()
	return self:GetDTBool(0)
end

-- ==== SetSigilHealth - 设置血量 ====
-- 写入基础血量并刷新上次受击时间（重置回复倒计时）
function ENT:SetSigilHealth(health)
	self:SetSigilHealthBase(health)

	self:SetSigilLastDamaged(math.max(self:GetSigilLastDamaged(), self:GetSigilHealthRegen() - self.RegenDelay))
end

-- ==== GetSigilHealth - 计算当前血量 ====
-- 基础血量 + 延迟后随时间累积的回复量，限制在 0 与最大生命之间
function ENT:GetSigilHealth()
	local base = self:GetSigilHealthBase()
	if base == 0 then return 0 end

	return math.Clamp(base + self:GetSigilHealthRegen() * math.max(0, CurTime() - (self:GetSigilLastDamaged() + self.RegenDelay)), 0, self.MaxHealth)
end

-- ==== GetSigilMaxHealth - 读取最大生命 ====
function ENT:GetSigilMaxHealth()
	return self.MaxHealth
end

-- ==== CanBeDamagedByTeam - 阵营可伤害判定 ====
-- 正常状态只有僵尸能打；腐蚀后只有人类能打
function ENT:CanBeDamagedByTeam(teamid)
	if self:GetSigilCorrupted() then
		return teamid == TEAM_HUMAN
	end

	return teamid == TEAM_UNDEAD
end
