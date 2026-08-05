-- ============================================================================
-- weapon_zs_graveshovel/init.lua - 掘墓铲近战武器（服务器端）
-- 负责：铲击带"蓄力伤害"机制：铲击处于复活状态的玩家（尸体）时
--       积累伤害加成并直接处决；加成随击杀叠加，展开时恢复蓄力
-- ============================================================================
INC_SERVER() -- 服务器专用文件标记

-- 记录母本定义的原始近战伤害（用于每次命中后重置）
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage

-- ==== Deploy - 武器展开时 ====
-- 从玩家身上恢复此前积累的铲击蓄力伤害
function SWEP:Deploy()
	self:SetShovelCharge(self:GetOwner().GraveShovelDamage or 0)

	return self.BaseClass.Deploy(self)
end

-- ==== OnMeleeHit - 近战命中回调 ====
-- 命中时把玩家积累的蓄力伤害加到本次攻击上
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if self:GetOwner().GraveShovelDamage then
		self.MeleeDamage = self.MeleeDamage + self:GetOwner().GraveShovelDamage
	end
end

-- ==== PostOnMeleeHit - 近战命中后处理 ====
-- 若命中正在复活中的玩家，则积累 5 点蓄力伤害并直接处决目标
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	-- 目标必须是正在复活、且允许受到伤害的玩家
	if hitent:IsValid() and hitent:IsPlayer() and hitent.Revive and hitent.Revive:IsValid() and gamemode.Call("PlayerShouldTakeDamage", hitent, self:GetOwner()) then
		local killer = self:GetOwner()

		if killer:IsValid() then
			-- 蓄力伤害累加 5 点（每铲死一个复活者 +5）
			killer.GraveShovelDamage = killer.GraveShovelDamage and killer.GraveShovelDamage + 5 or 5
			killer:EmitSound("hl1/ambience/particle_suck1.wav", 65, 250, 0.65) -- 吸取音效
		end

		self:SetShovelCharge(killer.GraveShovelDamage or 0) -- 更新蓄力显示
		hitent:TakeSpecialDamage(hitent:Health(), DMG_DIRECT, self:GetOwner(), self, tr.HitPos) -- 直接处决（伤害=剩余生命）
	end

	self.MeleeDamage = self.OriginalMeleeDamage -- 重置本次伤害加成
end
