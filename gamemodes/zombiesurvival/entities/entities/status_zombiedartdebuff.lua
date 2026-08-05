-- ============================================================================
-- status_zombiedartdebuff - 僵尸飞镖减益状态
-- 负责：僵尸被飞镖击中后获得本状态，持续期间僵尸造成的伤害降低 25%，
--       通过全局 EntityTakeDamage 钩子监听伤害事件实现
-- ============================================================================

-- 客户端与服务器同时加载本文件
AddCSLuaFile()

-- 实体类型：动画实体，继承状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- ==== Initialize - 状态初始化 ====
function ENT:Initialize()
	-- 调用基类初始化（设置持续时间等基础字段）
	self.BaseClass.Initialize(self)

	if SERVER then
		-- 服务器端注册全局伤害钩子，监听状态持有者造成的伤害
		hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)

		-- 初始化自定义数据槽
		self:SetDTInt(1, 0)
	end
end

-- ==== EntityTakeDamage - 全局伤害拦截 ====
-- 仅处理状态持有者（僵尸）造成的伤害：对目标伤害乘以 0.75（减伤 25%）
function ENT:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	-- 非本状态持有者造成的伤害不处理
	if attacker ~= self:GetOwner() then return end

	-- 持有者为有效的僵尸阵营玩家时削减其输出伤害
	if attacker:IsValid() and attacker:IsPlayer() and attacker:Team() == TEAM_UNDEAD then
		local dmg = dmginfo:GetDamage()
		dmginfo:SetDamage(dmg * 0.75)
	end
end
