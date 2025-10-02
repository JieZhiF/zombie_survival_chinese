AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_firesword")
SWEP.Description = ""..translate.Get("weapon_zs_firesword_description")
SWEP.Base = "weapon_zs_longsword"

SWEP.MeleeDamage = 125
SWEP.MeleeRange = 80
SWEP.MeleeSize = 2.5

SWEP.Primary.Delay = 1.3
SWEP.MaxStock = 2
 
SWEP.Tier = 4
if CLIENT then
	SWEP.ViewModelFOV = 75
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	SWEP.VElements = {
		["base+++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(-90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+++++"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 90, 0), size = Vector(0.223, 0.259, 0.196), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.743, 1.294, 3.095), angle = Angle(6.436, 0, 0), size = Vector(0.412, 0.257, 1.68), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_junk/shoe001a", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_phx/misc/flakshell_big.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.827), angle = Angle(180, 0, 0), size = Vector(0.093, 0.012, 0.97), color = Color(175, 20, 20), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },//剑身
		["base+"] = { type = "Model", model = "models/props_c17/streetsign002b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, 6.59), angle = Angle(0, 0, 0), size = Vector(0.09, 3.848, 0.09), color = Color(156, 155, 173, 255), surpresslightning = false, material = "models/props_pipes/pipesystem01a_skin1", skin = 0, bodygroup = {} },
		["base_right"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(223, 223, 255,255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },//右剑柄
	}

	SWEP.WElements = {
		["base+++++"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 90, 0), size = Vector(0.223, 0.259, 0.196), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.665, 1.264, 2.4), angle = Angle(-5.286, 16.554, -2.345), size = Vector(0.412, 0.257, 1.68), color = Color(175, 20, 20), surpresslightning = false, material = "models/props_junk/shoe001a", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/props_trainstation/trainstation_ornament002.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.791), angle = Angle(-90, 0, 0), size = Vector(0.035, 0.029, 0.3), color = Color(209, 209, 228, 255), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/streetsign002b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, 6.59), angle = Angle(0, 0, 0), size = Vector(0.09, 3.848, 0.09), color = Color(156, 155, 173, 255), surpresslightning = false, material = "models/props_pipes/pipesystem01a_skin1", skin = 0, bodygroup = {} },
		["base++++"] = { type = "Model", model = "models/props_phx/misc/flakshell_big.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -5.827), angle = Angle(180, 0, 0), size = Vector(0.093, 0.012, 0.97), color = Color(175, 20, 20), surpresslightning = false, material = "models/props_pipes/pipemetal004a", skin = 0, bodygroup = {} }
	}

end

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.125)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_DAMAGE, 9)
GAMEMODE:AddNewRemantleBranch(SWEP, 1, "魔狱", "基础伤害提高，攻击范围较小，攻击附加持久烈焰", function(wept)
    -- 改造路线的武器伤害倍率 默认为1，若小于等于1则降低伤害。反之则增加伤害
    wept.MeleeDamage = wept.MeleeDamage * 0.9 
	local BaseMeleeHit = wept.MeleeHitEntity
    -- 近战命中回调
    function wept:MeleeHitEntity(tr, hitent, damagemultiplier, damage)

		-- 先调用原有逻辑
		BaseMeleeHit(self, tr, hitent, damagemultiplier, damage)
		
		-- 添加火焰效果
		if SERVER and hitent:IsValidLivingZombie() then
			local attacker = self:GetOwner()
			local fireduration = 8
			hitent:Ignite(fireduration)
			hitent:SetNWFloat("FireDieTime", CurTime() + fireduration)
			-- 设置火焰所有权
			for _, fire in pairs(ents.FindByClass("entityflame")) do
				if fire:IsValid() and fire:GetParent() == hitent then
					fire:SetOwner(attacker)
					fire:SetPhysicsAttacker(attacker)
					fire.AttackerForward = attacker
				end
			end

		end

    end
end)


function SWEP:MeleeHitEntity(tr, hitent, damagemultiplier, damage)
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()

	if SERVER and hitent:IsPlayer() and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
		damagemultiplier = damagemultiplier * 3.5
		owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
	end

	damage = damage * damagemultiplier

	local dmginfo = DamageInfo()
	dmginfo:SetDamagePosition(tr.HitPos)
	dmginfo:SetAttacker(owner)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamageType(self.DamageType)
	dmginfo:SetDamage(damage)
	dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 50 * owner:GetAimVector())

	local vel
	if hitent:IsPlayer() then

		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(self:GetPowerCombo() + 1)

			damage = damage + damage * (owner.MeleePowerAttackMul - 1) * (self:GetPowerCombo()/4)
			dmginfo:SetDamage(damage)

			if self:GetPowerCombo() >= 4 then
				self:SetPowerCombo(0)
				if SERVER then
					local pitch = math.Clamp(math.random(90, 110) + 15 * (1 - damage/45), 50 , 200)
					owner:EmitSound("npc/strider/strider_skewer1.wav", 75, pitch)
				end
			end
		end

		hitent:MeleeViewPunch(damage)
		if hitent:IsHeadcrab() then
			damage = damage * 2
			dmginfo:SetDamage(damage)
		end

		if SERVER then
			hitent:SetLastHitGroup(tr.HitGroup)
			if tr.HitGroup == HITGROUP_HEAD then
				hitent:SetWasHitInHead()
			end

			if hitent:WouldDieFrom(damage, tr.HitPos) then
				dmginfo:SetDamageForce(math.min(self.MeleeDamage, 50) * 400 * owner:GetAimVector())
			end
		end

		vel = hitent:GetVelocity()
	else
		if owner.MeleePowerAttackMul and owner.MeleePowerAttackMul > 1 then
			self:SetPowerCombo(0)
		end
	end

	--if not hitent.LastHeld or CurTime() >= hitent.LastHeld + 0.1 then -- Don't allow people to shoot props out of their hands
		if self.PointsMultiplier then
			POINTSMULTIPLIER = self.PointsMultiplier
		end

		hitent:DispatchTraceAttack(dmginfo, tr, owner:GetAimVector())

		if self.PointsMultiplier then
			POINTSMULTIPLIER = nil
		end

		-- Invalidate the engine knockback vs. players
		if vel then
			hitent:SetLocalVelocity(vel)
		end
	--end

	-- Perform our own knockback vs. players
	if hitent:IsPlayer() then
		local knockback = self.MeleeKnockBack * (owner.MeleeKnockbackMultiplier or 1)
		if knockback > 0 then
			hitent:ThrowFromPositionSetZ(tr.StartPos, knockback, nil, true)
		end

		if owner.MeleeLegDamageAdd and owner.MeleeLegDamageAdd > 0 then
			hitent:AddLegDamage(owner.MeleeLegDamageAdd)
		end
	end

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetStart(tr.StartPos)
	effectdata:SetNormal(tr.HitNormal)
	util.Effect("RagdollImpact", effectdata)
	if not tr.HitSky then
		effectdata:SetSurfaceProp(tr.SurfaceProps)
		effectdata:SetDamageType(self.DamageType)
		effectdata:SetHitBox(tr.HitBox)
		effectdata:SetEntity(hitent)
		util.Effect("Impact", effectdata)
	end
end
