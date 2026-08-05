-- ============================================================================
-- weapon_zs_powerfists.lua - 动力拳套（近战武器）
-- 负责：高伤害拳击、命中附加腿部伤害与脉冲减速、击退与音效
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 继承基础拳套武器
SWEP.Base = "weapon_zs_fists"

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_powerfists")
SWEP.Description = ""..translate.Get("weapon_zs_powerfists_description")

if CLIENT then
	-- 客户端专属：第一人称视野 / 模型翻转
	SWEP.ViewModelFOV = 65
	SWEP.ViewModelFlip = false

	-- 隐藏原始模型（用附加模型代替显示）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 第一人称附加模型：双手上的动力发动机拳套
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1.129, 0.087, -1), angle = Angle(0, 90.421, 90.749), size = Vector(0.18, 0.18, 0.3), color = Color(105, 75, 65, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Finger2", rel = "base", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.28, 0.21, 0.15), color = Color(135, 115, 95, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(1.129, -1.087, 2), angle = Angle(230, 90, 90), size = Vector(0.18, 0.18, 0.3), color = Color(105, 75, 65, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Finger2", rel = "base+", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.28, 0.21, 0.15), color = Color(135, 115, 95, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
	}

	-- 第三人称附加模型：双手上的动力发动机拳套
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.129, -1.087, 0), angle = Angle(0, 90.421, 90.749), size = Vector(0.18, 0.18, 0.3), color = Color(105, 75, 65, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["base++"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Finger2", rel = "base", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.28, 0.21, 0.15), color = Color(135, 115, 95, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["base+"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(3.129, -1.087, 0), angle = Angle(230, 90, 90), size = Vector(0.18, 0.18, 0.3), color = Color(105, 75, 65, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["base+++"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Finger2", rel = "base+", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.28, 0.21, 0.15), color = Color(135, 115, 95, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
	}
end

-- 持拳套移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/c_arms_hev.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"

-- 武器栏权重
SWEP.Weight = 4

-- 近战伤害 / 命中腿部附加伤害
SWEP.MeleeDamage = 86
SWEP.LegDamage = 17

-- 非赤手空拳状态（拥有武器实体）
SWEP.Unarmed = false

-- 允许丢弃 / 捡起显示提示 / 允许拆除
SWEP.Undroppable = false
SWEP.NoPickupNotification = false
SWEP.NoDismantle = false

-- 玻璃武器（可被摧毁的特性）
SWEP.NoGlassWeapons = false

-- 允许强化 / 挥击音效 / 命中音效
SWEP.AllowQualityWeapons = true
SWEP.SwingSound = Sound( "weapons/zs_power/power1.ogg" )
SWEP.HitSound = Sound( "weapons/zs_power/power4.wav" )

-- 拳击附加强击退 / 击退力度
SWEP.FistKnockback = true
SWEP.MeleeKnockBack = 200

-- 攻击间隔（秒）
SWEP.Primary.Delay = 0.65
-- 格挡音效与音调
SWEP.BlockSound = "weapons/rpg/shotdown.wav"
SWEP.BlockSoundPitch = 100
-- 武器等级（Tier 4）
SWEP.Tier = 4

-- 强化词条：攻击间隔 -0.07 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.07, 1)

-- ==== OnMeleeHit - 近战命中附加效果 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() then
		-- 命中点生成脉冲冲击特效
		util.CreatePulseImpactEffect(tr.HitPos, tr.HitNormal)

		-- 命中玩家时附加腿部伤害与脉冲减速，并播放电击命中音效
		if hitent:IsPlayer() then
			hitent:AddLegDamageExt(self.LegDamage, self:GetOwner(), self, SLOWTYPE_PULSE)
			hitent:EmitSound("Weapon_StunStick.Melee_Hit")
		end
	end
end
