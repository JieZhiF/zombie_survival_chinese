-- ============================================================================
-- weapon_zs_shadowgorechild/shared.lua - 暗影血童（僵尸召唤物武器）
-- 负责：定义暗影血童的拳击攻击、左右拳动画与挥击节奏
-- ============================================================================
-- 基于血童武器母本
SWEP.Base = "weapon_zs_gorechild"

-- 武器名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_shadowgorechild")

-- 近战伤害
SWEP.MeleeDamage = 2

-- ==== MeleeHit - 近战命中：对玩家目标为主人累计生命伤害 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if ent:IsPlayer() then
		local owner = self:GetOwner()

		-- 主人为存活僵尸领主时，把本次伤害计入其生命吸取
		if owner.Master and owner.Master:IsValidLivingZombie() then
			owner.Master:AddLifeHumanDamage(damage)
		end
	end

	self.BaseClass.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== Think - 每帧逻辑：松开攻击键且挥击超时后结束挥击 ====
function SWEP:Think()
	self.BaseClass.BaseClass.Think(self)

	if IsFirstTimePredicted() then
		local curtime = CurTime()
		local owner = self:GetOwner()

		-- 松开攻击键且挥击动画超时后结束挥击状态
		if self:GetSwinging() then
			if not owner:KeyDown(IN_ATTACK) and self.SwingStop and self.SwingStop <= curtime then
				self:SetSwinging(false)
				self.SwingStop = nil
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

-- ==== Swung - 挥击执行：交替左右拳并播放对应动画 ====
function SWEP:Swung()
	if not IsFirstTimePredicted() then return end

	-- 记录挥击结束时间（0.5 秒后）
	self.SwingStop = CurTime() + 0.5

	if not self:GetSwinging() then
		self:SetSwinging(true)
	end

	-- 交替左右拳动画
	self.AltSwing = not self.AltSwing

	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(self.AltSwing and "fists_left" or "fists_right"))

	self.BaseClass.BaseClass.Swung(self)
end

-- ==== Deploy - 出枪：播放拳头出鞘动画 ====
function SWEP:Deploy()
	local vm = self:GetOwner():GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))

	return self.BaseClass.BaseClass.Deploy(self)
end
