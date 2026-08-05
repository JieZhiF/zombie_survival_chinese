-- ============================================================================
-- weapon_zs_butt_a/init.lua - 腐尸击打者（服务器端）：投掷钩爪攻击逻辑
-- 负责：重载触发右键攻击、生成飞行的爪子投射物
-- ============================================================================
INC_SERVER()

-- ==== Reload - 重载时触发右键（副攻击） ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== ThrowHook - 生成并发射飞行钩爪投射物 ====
function SWEP:ThrowHook()
	local owner = self:GetOwner()

	-- 记录最近一次远程攻击时间
	owner.LastRangedAttack = CurTime()

	-- 创建投射物实体
	local ent = ents.Create("projectile_devourer")
	if ent:IsValid() then
		-- 面向旋转 90 度后生成
		local ang = owner:EyeAngles()
		ang:RotateAroundAxis(ang:Up(), 90)

		ent:SetPos(owner:GetShootPos())
		ent:SetAngles(ang)
		ent:SetOwner(owner)
		ent:Spawn()

		-- 沿瞄准方向以高速推出
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(owner:GetAimVector() * 2150)
		end
	end
end
