-- ============================================================================
-- weapon_zs_basefood/init.lua - 食物母本（服务端）
-- 负责：定义食用逻辑——技能联动（糖冲刺/暴食/脆弱）、生命与血甲回复、弹药消耗
-- ============================================================================

INC_SERVER()

-- ==== Eat - 食用食物 ====
function SWEP:Eat()
	local owner = self:GetOwner()

	-- 糖冲刺技能：获得 14 秒肾上腺素加速状态（速度 +35）
	if owner:IsSkillActive(SKILL_SUGARRUSH) then
		local boost = owner:GiveStatus("adrenalineamp", 14)
		if boost and boost:IsValid() then
			boost:SetSpeed(35)
		end
	end

	-- 脆弱技能：回复量上限仅为最大生命的 25%，否则为最大生命
	local max = owner:IsSkillActive(SKILL_D_FRAIL) and math.floor(owner:GetMaxHealth() * 0.25) or owner:GetMaxHealth()

	if owner:IsSkillActive(SKILL_GLUTTON) then
		-- 暴食技能：转为回复血甲（单次最多 30 点，受恢复倍率影响）
		local healing = self.FoodHealth * (owner.FoodRecoveryMul or 1)

		-- 血甲上限 = 自身上限 + 40 × 上限倍率
		owner:SetBloodArmor(math.min(owner:GetBloodArmor() + (math.min(30, healing) * owner.BloodarmorGainMul), owner.MaxBloodArmor + (40 * owner.MaxBloodArmorMul)))
	else
		-- 常规回复：食物量 × 恢复倍率加成（幽灵血过半时恢复减半）
		local healing = self.FoodHealth * (owner:GetTotalAdditiveModifier("FoodRecoveryMul", "HealingReceived") - (owner:GetPhantomHealth() > 0.5 and 0.5 or 0))

		-- 回复生命（不超过上限），并优先抵消幽灵血
		owner:SetHealth(math.min(owner:Health() + healing, max))
		owner:SetPhantomHealth(math.max(0, math.floor(owner:GetPhantomHealth() - healing)))
	end

	-- 消耗 1 份食物
	self:TakePrimaryAmmo(1)
	-- 食物耗尽后移除该武器
	if self:GetPrimaryAmmoCount() <= 0 then
		owner:StripWeapon(self:GetClass())
	end
end
