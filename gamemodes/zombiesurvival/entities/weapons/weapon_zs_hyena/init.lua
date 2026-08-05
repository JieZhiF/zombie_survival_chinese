-- ============================================================================
-- weapon_zs_hyena/init.lua - 鬣狗粘性炸弹发射器（服务端逻辑）
-- 负责：定义主键发射的粘性炸弹弹体属性，以及右键引爆场上全部炸弹
-- ============================================================================
INC_SERVER()

-- 主键发射的弹体：粘性炸弹（命中后可粘附在物体/敌人身上）
SWEP.Primary.Projectile = "projectile_bomb_sticky"
-- 弹体出膛速度
SWEP.Primary.ProjVelocity = 850

-- ==== EntModify - 弹体生成时回调 ====
-- 弹体生成时同步设置右键引爆冷却，保证引爆节奏
function SWEP:EntModify(ent)
	self:SetNextSecondaryFire(CurTime() + 0.2)
end

-- ==== SecondaryAttack - 右键引爆所有粘性炸弹 ====
-- 遍历场景中本武器发射的粘性炸弹（按持有者匹配），全部引爆
function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() > CurTime() then return end
	for k,v in pairs(ents.FindByClass(self.Primary.Projectile)) do
		if v:GetOwner() == self:GetOwner() then
			v:Explode()
		end
	end

	self:SetNextSecondaryFire(CurTime() + 0.2)
end
