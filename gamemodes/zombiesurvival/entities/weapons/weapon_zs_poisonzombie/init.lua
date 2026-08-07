-- ============================================================================
-- weapon_zs_poisonzombie/init.lua - 毒液僵尸（服务端入口）
-- 负责：定义扇形毒液喷射模式并生成毒液投射物
-- ============================================================================
INC_SERVER()

-- 毒液喷射模式：相对瞄准方向的角度偏移表（{水平偏移系数, 垂直偏移系数}）
SWEP.PoisonPattern = {
	{-1, 0},
	{-0.66, 0},
	{-0.33, 0},
	{0, 0},
	{0, 1},
	{0, -1},
	{0.33, 0},
	{0.66, 0},
	{1, 0}
}

-- ==== DoThrow - 按喷射模式向各方向生成毒液投射物并赋予速度 ====
function SWEP:DoThrow()
	local owner = self:GetOwner()
	local startpos = owner:GetShootPos()
	local aimang = owner:EyeAngles()
	local ang

	for k, spr in pairs(self.PoisonPattern) do
		if k ~= "BaseClass" then
			-- 基于瞄准方向做水平/垂直偏移后生成毒液投射物
			ang = Angle(aimang.p, aimang.y, aimang.r)
			ang:RotateAroundAxis(ang:Up(), spr[1] * 12.5)
			ang:RotateAroundAxis(ang:Right(), spr[2] * 5)
			local heading = ang:Forward()

			local ent = ents.Create("projectile_poisonflesh")
			if ent:IsValid() then
				ent:SetPos(startpos + heading * 8)
				ent:SetOwner(owner)
				ent:Spawn()

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(heading * self.PoisonThrowSpeed)
				end
			end
		end
	end
end
