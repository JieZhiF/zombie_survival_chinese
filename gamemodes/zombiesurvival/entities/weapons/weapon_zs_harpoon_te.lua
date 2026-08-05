-- ============================================================================
-- weapon_zs_harpoon_te.lua - 鱼叉发射器（牵引者专用变体）
-- 负责：继承基础鱼叉武器，右键投掷牵引鱼叉投射物（projectile_harpoon_te），
--       投掷后自动移除武器（一次性消耗品）
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_harpoon_te")

-- 继承基础鱼叉武器
SWEP.Base = "weapon_zs_harpoon"

-- ==== SecondaryAttack - 右键投掷牵引鱼叉 ====
function SWEP:SecondaryAttack()
	-- 冷却/弹药检查
	if not self:CanPrimaryAttack() then return end
	local owner = self:GetOwner()
	-- 前方60单位射线检测，命中世界或非玩家实体时禁止投掷（防止贴墙投掷）
	local tr = owner:TraceLine(60)
	if tr.HitWorld or (tr.Entity:IsValid() and not tr.Entity:IsPlayer()) then return end
	-- 设置攻击冷却
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 播放挥空动画和投掷手势
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
	owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)

	-- 设置部署完成时间（0.75秒后可切换武器）
	self.NextDeploy = CurTime() + 0.75

	if SERVER then
		-- 创建牵引鱼叉投射物
		local ent = ents.Create("projectile_harpoon_te")
		if ent:IsValid() then
			-- 从玩家射击位置发射
			ent:SetPos(owner:GetShootPos())
			ent:SetAngles(owner:EyeAngles())
			ent:SetOwner(owner)
			-- 标记投掷者（用于牵引功能）
			ent:SetPuller(owner)
			-- 投射物伤害为近战伤害的75%
			ent.ProjDamage = self.MeleeDamage * 0.75
			-- 记录基础武器类名（用于回收）
			ent.BaseWeapon = self:GetClass()
			ent:Spawn()
			ent.Team = owner:Team()
			-- 设置初速度（700单位/秒，受投掷力度倍率影响）
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * 700 * (owner.ObjectThrowStrengthMul or 1))
			end
		end

		-- 投掷后移除武器（一次性消耗）
		owner:StripWeapon(self:GetClass())
	end
end
