
SWEP.PrintName = "特斯拉武士刀"


DEFINE_BASECLASS("weapon_zs_basemelee")
 

SWEP.Weight         = 5

SWEP.Slot           = 0
SWEP.SlotPos        = 1

SWEP.Base           = "weapon_zs_basemelee"
SWEP.HoldType       = "melee2"

SWEP.UseHands = true
SWEP.ViewModelFOV   = 50
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFlip  = false
SWEP.ShowWorldModel = false
SWEP.MeleeDamage = 50
SWEP.MeleeRange = 65
SWEP.MeleeSize = 1.5
SWEP.Tier = 2
SWEP.MeleeDamageSecondaryMul = 2
SWEP.MeleeKnockBack = 0
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-23.519, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(50, 0, 0) },
	["ValveBiped.Bip01_R_Clavicle"] = { scale = Vector(1, 1, 1), pos = Vector(-8.334, 3.888, 5.741), angle = Angle(10, 0, 0) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0.925), angle = Angle(-47.778, 0, 0) }
}
SWEP.VElements = {
	["hils++"] = { type = "Model", model = "models/items/battery.mdl", bone = "v_weapon.Knife_Handle", rel = "hils", pos = Vector(0, -0.201, 4.8), angle = Angle(0, 90, 0), size = Vector(0.1, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["hils+++"] = { type = "Model", model = "models/items/battery.mdl", bone = "v_weapon.Knife_Handle", rel = "hils", pos = Vector(0, 0.2, 4.8), angle = Angle(0, -90, 0), size = Vector(0.1, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["blade++"] = { type = "Model", model = "models/hunter/triangles/1x1x1carved025.mdl", bone = "v_weapon.Knife_Handle", rel = "hils", pos = Vector(0, 0, 15), angle = Angle(180, 45, 0), size = Vector(0.014, 0.014, 0.5), color = Color(0, 255, 255, 255), surpresslightning = false, material = "effects/tp_eyefx/tpeye2", skin = 0, bodygroup = {} },
	["blade"] = { type = "Model", model = "models/hunter/triangles/1x1x1carved025.mdl", bone = "v_weapon.Knife_Handle", rel = "hils", pos = Vector(0, 0, 15), angle = Angle(180, 45, 0), size = Vector(0.014, 0.014, 0.5), color = Color(0, 255, 255, 255), surpresslightning = false, material = "effects/tvscreen_noise002a", skin = 0, bodygroup = {} },
	["blade+"] = { type = "Model", model = "models/hunter/triangles/1x1x1carved025.mdl", bone = "v_weapon.Knife_Handle", rel = "hils", pos = Vector(0, 0, 15), angle = Angle(180, 45, 0), size = Vector(0.014, 0.014, 0.5), color = Color(0, 255, 255, 255), surpresslightning = false, material = "effects/tp_eyefx/tpeye", skin = 0, bodygroup = {} },
	["hils"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(0, 0, -0.7), angle = Angle(0, 45, 0), size = Vector(0.05, 0.039, 0.109), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/bluemetal", skin = 0, bodygroup = {} },
	["hils+"] = { type = "Model", model = "models/hunter/misc/sphere1x1.mdl", bone = "v_weapon.Knife_Handle", rel = "hils", pos = Vector(0, 0, -0.101), angle = Angle(0, 90, 0), size = Vector(0.029, 0.039, 0.029), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["hils++"] = { type = "Model", model = "models/items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hils", pos = Vector(0, -0.201, 4.8), angle = Angle(0, 90, 0), size = Vector(0.1, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["hils+"] = { type = "Model", model = "models/hunter/misc/sphere1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hils", pos = Vector(0, 0, -0.101), angle = Angle(0, 90, 0), size = Vector(0.029, 0.039, 0.029), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/torpedo", skin = 0, bodygroup = {} },
	["blade++"] = { type = "Model", model = "models/hunter/triangles/1x1x1carved025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hils", pos = Vector(0, 0, 15), angle = Angle(180, 45, 0), size = Vector(0.014, 0.014, 0.5), color = Color(0, 255, 255, 255), surpresslightning = false, material = "effects/tp_eyefx/tpeye2", skin = 0, bodygroup = {} },
	["hils"] = { type = "Model", model = "models/props_c17/oildrum001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, 2.5), angle = Angle(-170, 50, 8), size = Vector(0.05, 0.039, 0.109), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/bluemetal", skin = 0, bodygroup = {} },
	["hils+++"] = { type = "Model", model = "models/items/battery.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hils", pos = Vector(0, 0.2, 4.8), angle = Angle(0, -90, 0), size = Vector(0.1, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["blade"] = { type = "Model", model = "models/hunter/triangles/1x1x1carved025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hils", pos = Vector(0, 0, 15), angle = Angle(180, 45, 0), size = Vector(0.014, 0.014, 0.5), color = Color(0, 255, 255, 255), surpresslightning = false, material = "effects/tvscreen_noise002a", skin = 0, bodygroup = {} },
	["blade+"] = { type = "Model", model = "models/hunter/triangles/1x1x1carved025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "hils", pos = Vector(0, 0, 15), angle = Angle(180, 45, 0), size = Vector(0.014, 0.014, 0.5), color = Color(0, 255, 255, 255), surpresslightning = false, material = "effects/tp_eyefx/tpeye", skin = 0, bodygroup = {} }
}

local SwingSound = Sound( "WeaponFrag.Roll" )


function SWEP:PlaySwingSound()
	self:EmitSound("WeaponFrag.Roll")
end

function SWEP:PlayStartSwingSound()
	self:EmitSound( SwingSound )
end
SWEP.HitAnim = ACT_VM_MISSCENTER -- ACT_VM_PRIMARYATTACK
SWEP.MissAnim = ACT_VM_PRIMARYATTACK -- ACT_VM_MISSCENTER
SWEP.SwingTime = 0
SWEP.SwingRotation = Angle(0, 0, 0)
SWEP.SwingOffset = Vector(0, 0, 0) //挥舞位置

function SWEP:PlayHitSound()
	self:EmitSound("GlassBottle.ImpactHard")
end

function SWEP:PlayHitFleshSound()
self:EmitSound("Flesh_Bloody.ImpactHard")
end

--[[
    说明:
    这个函数负责启动右键攻击。
    我们在这里添加了一个 `self.IsHeavyAttack = true` 的标志。
    这个标志就像一个临时便签，告诉后面的伤害计算函数：“注意，下一次攻击是重击！”
]]
function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() then return end
	if self:IsBlocking() then return end
	self:SetNextAttack()

	-- 设置一个标志，表明这是一次重击
	self.IsHeavyAttack = true

	-- 调用挥舞逻辑
	if self.SwingTime == 0 then
		self:MeleeSwing2()
	else
		self:StartSwinging()
	end
end

--[[
    说明:
    这个函数被 SecondaryAttack 调用来执行实际的攻击动作。
    您原来的版本中存在一些重复的逻辑（例如，在调用基类函数后又进行了一次追踪）。
    这个优化后的版本会临时将武器的命中/未命中动画设置为您的次要攻击动画 (ACT_VM_SECONDARYATTACK)，
    然后调用基类的 MeleeSwing 函数。这样做更简洁，并且能确保基类函数使用正确的重击动画。
]]
function SWEP:MeleeSwing2()
	-- 保存原始的主攻击动画
	local oldHitAnim = self.HitAnim
	local oldMissAnim = self.MissAnim

	-- 为本次重击设置专门的动画
	self.HitAnim = ACT_VM_SECONDARYATTACK
	self.MissAnim = ACT_VM_SECONDARYATTACK

	-- 调用基类的核心挥舞函数，它会处理所有事情（追踪、伤害、音效、以及我们刚设置的动画）
	self.BaseClass.MeleeSwing(self)

	-- 攻击结束后，恢复原始动画，以免影响主攻击
	self.HitAnim = oldHitAnim
	self.MissAnim = oldMissAnim
end


--[[
    说明:
    这个函数是从您的 base 中复制并修改而来的。您必须将它放在您的武器文件中，
    这样它就会覆盖（override）基类的版本，从而让我们能自定义伤害。

    核心改动：我们在计算最终伤害前，检查 `self.IsHeavyAttack` 标志。
    如果标志存在，我们就施加一个伤害倍率（例如乘以 2.5），然后立刻将标志移除，
    以免影响下一次的普通攻击。
]]
function SWEP:MeleeHitEntity(tr, hitent, damagemultiplier)
	if not IsFirstTimePredicted() then return end

	if self.MeleeFlagged then self.IsMelee = true end

	local owner = self:GetOwner()

	if SERVER and hitent:IsPlayer() and not self.NoGlassWeapons and owner:IsSkillActive(SKILL_GLASSWEAPONS) then
		damagemultiplier = damagemultiplier * 3.5
		owner.GlassWeaponShouldBreak = not owner.GlassWeaponShouldBreak
	end

	-- ==================== 主要修改在此 ====================
	local damage = self.MeleeDamage

	-- 检查是否为重击
	if self.IsHeavyAttack then
		-- 如果是重击，应用伤害倍率。您可以修改 2.5 这个值
		damage = damage * 2
		-- **非常重要**：使用后立即重置标志，防止普通攻击也变成重击
		self.IsHeavyAttack = false
	end
	-- =======================================================

	-- 应用其他的伤害乘数
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
		self:PlayerHitUtil(owner, damage, hitent, dmginfo)

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

	self:PostHitUtil(owner, hitent, dmginfo, tr, vel)
end