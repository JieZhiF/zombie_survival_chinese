-- ============================================================================
-- weapon_zs_devourer/init.lua - 吞噬者僵尸（服务器端）
-- 负责：实现右键钩爪的实际抛射——创建 projectile_devourer 弹体，
--       以 2150 单位/秒的速度沿准星方向射出
-- ============================================================================
INC_SERVER()

-- ==== Reload - 换弹键触发：使用基底右键（扑击）技能 ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== ThrowHook - 抛出钩爪弹体 ====
function SWEP:ThrowHook()
	local owner = self:GetOwner()

	-- 记录最近一次远程攻击时间（供 AI/技能判定使用）
	owner.LastRangedAttack = CurTime()

	-- 创建钩爪弹体实体
	local ent = ents.Create("projectile_devourer")
	if ent:IsValid() then
		-- 弹体初始朝向：视线方向绕上轴旋转 90 度（使钩爪侧面朝前）
		local ang = owner:EyeAngles()
		ang:RotateAroundAxis(ang:Up(), 90)

		-- 出生在枪口位置并绑定所有者
		ent:SetPos(owner:GetShootPos())
		ent:SetAngles(ang)
		ent:SetOwner(owner)
		ent:Spawn()

		-- 沿准星方向瞬时加速抛出
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(owner:GetAimVector() * 2150)
		end
	end
end
