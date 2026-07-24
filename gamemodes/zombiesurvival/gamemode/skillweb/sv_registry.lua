-- ============================================================
-- 技能树系统 - 服务端注册表
-- 注册仅在服务端使用的技能修饰符函数，
-- 以及技能修饰符的具体数值定义
-- ============================================================

-- ============================================================
-- 生命值修饰符：设置玩家最大生命值（基础100 + 修饰值）
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_HEALTH, function(pl, amount)
	local current = pl:GetMaxHealth()
	local new = 100 + math.Clamp(amount, -99, 1000)
	pl:SetMaxHealth(new)
	pl:SetHealth(math.max(1, pl:Health() / current * new))
end)

-- ============================================================
-- 初始点数修饰符：在首次应用时增加/减少玩家起始点数
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_POINTS, function(pl, amount)
	if not pl.AdjustedStartPointsSkill then
		pl:SetPoints(pl:GetPoints() + amount)
		pl.AdjustedStartPointsSkill = true
	end
end)

-- ============================================================
-- 初始废料修饰符：在首次应用时给予玩家额外废料弹药
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_SCRAP_START, function(pl, amount)
	if not pl.AdjustedStartScrapSkill then
		pl:GiveAmmo(amount, "scrap")
		pl.AdjustedStartScrapSkill = true
	end
end)

-- ============================================================
-- 食物恢复倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_FOODRECOVERY_MUL, function(pl, amount)
	pl.FoodRecoveryMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

-- ============================================================
-- 坠落伤害倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_FALLDAMAGE_DAMAGE_MUL, function(pl, amount)
	pl.FallDamageDamageMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

-- ============================================================
-- 坠落恢复倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_FALLDAMAGE_RECOVERY_MUL, function(pl, amount)
	pl.FallDamageRecoveryMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

-- ============================================================
-- 点数收入倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_POINT_MULTIPLIER, function(pl, amount)
	pl.PointIncomeMul = math.Clamp(amount + 1.0, 0.0, 1000.0)
end)

-- ============================================================
-- 可控单位（无人机/滚球等）速度倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_CONTROLLABLE_SPEED_MUL, function(pl, amount)
	pl.ControllableSpeedMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

-- ============================================================
-- 可控单位操控性倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_CONTROLLABLE_HANDLING_MUL, function(pl, amount)
	pl.ControllableHandlingMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

-- ============================================================
-- 可控单位生命值倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_CONTROLLABLE_HEALTH_MUL, function(pl, amount)
	pl.ControllableHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 机械螳螂生命值倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_MANHACK_HEALTH_MUL, function(pl, amount)
	pl.ManhackHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 机械螳螂伤害倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_MANHACK_DAMAGE_MUL, function(pl, amount)
	pl.ManhackDamageMul = math.Clamp(amount + 1.0, 0.0, 10.0)
end)

-- ============================================================
-- 无人机速度倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_DRONE_SPEED_MUL, function(pl, amount)
	pl.DroneSpeedMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

-- ============================================================
-- 无人机载重倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_DRONE_CARRYMASS_MUL, function(pl, amount)
	pl.DroneCarryMassMul = math.Clamp(amount + 1.0, 0.01, 1000.0)
end)

-- ============================================================
-- 炮塔生命值倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_TURRET_HEALTH_MUL, function(pl, amount)
	pl.TurretHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 炮塔扫描速度倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_TURRET_SCANSPEED_MUL, function(pl, amount)
	pl.TurretScanSpeedMul = math.Clamp(amount + 1.0, 0, 10.0)
end)

-- ============================================================
-- 炮塔扫描角度倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_TURRET_SCANANGLE_MUL, function(pl, amount)
	pl.TurretScanAngleMul = math.Clamp(amount + 1.0, 0, 2.0)
end)

-- ============================================================
-- 可部署物生命值倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_DEPLOYABLE_HEALTH_MUL, function(pl, amount)
	pl.DeployableHealthMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 可部署物打包时间倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_DEPLOYABLE_PACKTIME_MUL, function(pl, amount)
	pl.DeployablePackTimeMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 补给延迟倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_RESUPPLY_DELAY_MUL, function(pl, amount)
	pl.ResupplyDelayMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 维修立场范围倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_FIELD_RANGE_MUL, function(pl, amount)
	pl.FieldRangeMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 维修立场延迟倍率修饰符
-- ============================================================
GM:SetSkillModifierFunction(SKILLMOD_FIELD_DELAY_MUL, function(pl, amount)
	pl.FieldDelayMul = math.Clamp(amount + 1.0, 0.01, 10.0)
end)

-- ============================================================
-- 以下为技能修饰符数值定义
-- GM:AddSkillModifier(skillId, modifierType, amount)
-- ============================================================

-- 炮塔超载 → 炮塔扫描速度 +100%
GM:AddSkillModifier(SKILL_TURRETOVERLOAD, SKILLMOD_TURRET_SCANSPEED_MUL, 1.0)

-- 炮塔锁定 → 炮塔扫描角度 -90%
GM:AddSkillModifier(SKILL_TURRETLOCK, SKILLMOD_TURRET_SCANANGLE_MUL, -0.9)

-- 价值 I / II / III / IV → 各减3初始点数
GM:AddSkillModifier(SKILL_WORTHINESS1, SKILLMOD_POINTS, -3)
GM:AddSkillModifier(SKILL_WORTHINESS2, SKILLMOD_POINTS, -3)
GM:AddSkillModifier(SKILL_WORTHINESS3, SKILLMOD_POINTS, -3)
GM:AddSkillModifier(SKILL_WORTHINESS4, SKILLMOD_POINTS, -3)

-- 重载船体 → 可控单位生命 -10%
GM:AddSkillModifier(SKILL_LOADEDHULL, SKILLMOD_CONTROLLABLE_HEALTH_MUL, -0.1)

-- 强化船体 → 可控单位生命 +25%，操控性 -20%，速度 -20%
GM:AddSkillModifier(SKILL_REINFORCEDHULL, SKILLMOD_CONTROLLABLE_HEALTH_MUL, 0.25)
GM:AddSkillModifier(SKILL_REINFORCEDHULL, SKILLMOD_CONTROLLABLE_HANDLING_MUL, -0.2)
GM:AddSkillModifier(SKILL_REINFORCEDHULL, SKILLMOD_CONTROLLABLE_SPEED_MUL, -0.2)

-- 强化刀片 → 螳螂伤害 +25%，螳螂生命 -15%
GM:AddSkillModifier(SKILL_REINFORCEDBLADES, SKILLMOD_MANHACK_DAMAGE_MUL, 0.25)
GM:AddSkillModifier(SKILL_REINFORCEDBLADES, SKILLMOD_MANHACK_HEALTH_MUL, -0.15)

-- 稳定船体 → 可控单位速度 -20%
GM:AddSkillModifier(SKILL_STABLEHULL, SKILLMOD_CONTROLLABLE_SPEED_MUL, -0.2)

-- 飞行员 → 可控单位速度 +40%，操控性 +40%，生命 -25%
GM:AddSkillModifier(SKILL_AVIATOR, SKILLMOD_CONTROLLABLE_SPEED_MUL, 0.4)
GM:AddSkillModifier(SKILL_AVIATOR, SKILLMOD_CONTROLLABLE_HANDLING_MUL, 0.4)
GM:AddSkillModifier(SKILL_AVIATOR, SKILLMOD_CONTROLLABLE_HEALTH_MUL, -0.25)

-- 轻量构造 → 可部署物生命 -25%，打包时间 -25%
GM:AddSkillModifier(SKILL_LIGHTCONSTRUCT, SKILLMOD_DEPLOYABLE_HEALTH_MUL, -0.25)
GM:AddSkillModifier(SKILL_LIGHTCONSTRUCT, SKILLMOD_DEPLOYABLE_PACKTIME_MUL, -0.25)

-- 觅食者 → 补给延迟 +20%
GM:AddSkillModifier(SKILL_FORAGER, SKILLMOD_RESUPPLY_DELAY_MUL, 0.2)

-- 立场增幅器 → 维修立场范围 -40%，延迟 -20%
GM:AddSkillModifier(SKILL_FIELDAMP, SKILLMOD_FIELD_RANGE_MUL, -0.4)
GM:AddSkillModifier(SKILL_FIELDAMP, SKILLMOD_FIELD_DELAY_MUL, -0.2)

-- 技师 → 维修立场范围 +3%，延迟 -3%
GM:AddSkillModifier(SKILL_TECHNICIAN, SKILLMOD_FIELD_RANGE_MUL, 0.03)
GM:AddSkillModifier(SKILL_TECHNICIAN, SKILLMOD_FIELD_DELAY_MUL, -0.03)

-- 投手 → 投掷力量 +10%
GM:AddSkillModifier(SKILL_PITCHER, SKILLMOD_PROP_THROW_STRENGTH_MUL, 0.1)
