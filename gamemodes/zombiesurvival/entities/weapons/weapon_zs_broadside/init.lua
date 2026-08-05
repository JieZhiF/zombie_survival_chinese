-- ============================================================================
-- weapon_zs_broadside/init.lua - 舷侧火箭炮（服务器端）
-- 负责：定义投射物参数（火箭弹）、发射时给玩家反向速度（后坐力位移）、
--       右键遥控引爆已发射的火箭弹
-- ============================================================================
INC_SERVER()

-- 主攻击投射物类型：火箭弹
SWEP.Primary.Projectile = "projectile_rocket"
-- 投射物初速度
SWEP.Primary.ProjVelocity = 900
-- 爆炸锥形衰减参数（影响爆炸范围递减）
SWEP.Primary.ProjExplosionTaper = 0.95

-- ==== EntModify - 投射物生成后的修改（发射时回调） ====
function SWEP:EntModify(ent)
	local owner = self:GetOwner()
	-- 记录遥控火箭引用到持有者（用于右键引爆）
	owner.RemoteDetRocket = ent
	-- 使持有者离开地面
	owner:SetGroundEntity(NULL)
	-- 给持有者施加反向速度（模拟发射后坐力位移）
	owner:SetVelocity(-220 * owner:GetAimVector())

	-- 设置投射物锥形爆炸参数
	ent.ProjTaper = self.Primary.ProjExplosionTaper

	-- 设置副攻击冷却
	self:SetNextSecondaryFire(CurTime() + 0.5)
end

-- ==== SecondaryAttack - 右键遥控引爆所有已发射的火箭弹 ====
function SWEP:SecondaryAttack()
	-- 副攻击冷却检查
	if self:GetNextSecondaryFire() > CurTime() then return end

	-- 遍历所有属于本持有者的火箭弹投射物并引爆
	for k,v in pairs(ents.FindByClass(self.Primary.Projectile)) do
		if v:GetOwner() == self:GetOwner() then
			v:Explode()
		end
	end

	-- 设置副攻击冷却
	self:SetNextSecondaryFire(CurTime() + 0.5)
end
