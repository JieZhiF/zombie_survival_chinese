-- ============================================================================
-- weapon_zs_galestorm.lua - 风暴冲锋枪（MAC-10 改造，可强化改装）
-- 负责：高射速双弹丸冲锋枪，机瞄模式下伤害降低但弹丸数 ×1.5；
--       含重口径强化分支与机瞄音效
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_galestorm")
SWEP.Description = ""..translate.Get("weapon_zs_galestorm_description")

-- 武器栏内位置
SWEP.SlotPos = 0

if CLIENT then
	-- 武器栏：冲锋枪槽
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotSMGs")
	SWEP.SlotGroup = WEPSELECT_SMG
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	-- HUD 3D 图标（大图标预览）参数
	SWEP.HUD3DBone = "v_weapon.mac10_bolt"
	SWEP.HUD3DPos = Vector(-1.75, 1, 0)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	-- 视图模型拼装件（枪管、上导轨、激光指示器）
	SWEP.VElements = {
		["top2"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top", pos = Vector(0, -1.201, -0.602), angle = Angle(180, 0, 0), size = Vector(0.057, 0.611, 0.068), color = Color(170, 170, 160, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "v_weapon.mac10_parent", rel = "", pos = Vector(-0.064, -3.751, -0.304), angle = Angle(180, -90, 0), size = Vector(0.177, 0.079, 0.342), color = Color(170, 170, 160, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["top"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "v_weapon.mac10_parent", rel = "", pos = Vector(-0.178, -5.091, -1.982), angle = Angle(180, 0, 90), size = Vector(0.021, 0.009, 0.009), color = Color(170, 170, 160, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["laser+"] = { type = "Model", model = "models/hunter/blocks/cube075x1x025.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top2", pos = Vector(0, 0, 0.843), angle = Angle(90, 90, 0), size = Vector(0.023, 0.037, 0.021), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} },
		["laser"] = { type = "Model", model = "models/hunter/blocks/cube075x1x025.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "top2", pos = Vector(0, 0, 0.577), angle = Angle(-90, 90, 0), size = Vector(0.023, 0.037, 0.021), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} }
	}

	-- 世界模型拼装件
	SWEP.WElements = {
		["top2"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(1.906, 0.238, 3.084), angle = Angle(0, 90, 90), size = Vector(0.057, 0.611, 0.068), color = Color(170, 170, 160, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_c17/TrapPropeller_Engine.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5.876, 1.121, -3.771), angle = Angle(-91.623, -4.99, 0), size = Vector(0.177, 0.101, 0.418), color = Color(170, 170, 160, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["top"] = { type = "Model", model = "models/props_combine/combine_train02b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(1.287, 0.241, 2.313), angle = Angle(0, -90, 90), size = Vector(0.021, 0.009, 0.009), color = Color(170, 170, 160, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["laser+"] = { type = "Model", model = "models/hunter/blocks/cube075x1x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top2", pos = Vector(0, 0, 0.843), angle = Angle(90, 90, 0), size = Vector(0.023, 0.037, 0.021), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} },
		["laser"] = { type = "Model", model = "models/hunter/blocks/cube075x1x025.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "top2", pos = Vector(0, 0, 0.577), angle = Angle(-90, 90, 0), size = Vector(0.023, 0.037, 0.021), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/weapons/v_smg1/texture5", skin = 0, bodygroup = {} }
	}
end

-- 注册自定义开火音效（P90 声，随机音高）
sound.Add(
{
	name = "Weapon_Gale.Single",
	channel = CHAN_WEAPON,
	volume = 1.0,
	soundlevel = 100,
	pitch = {120, 125},
	sound = "weapons/p90/p90-1.wav"
})

SWEP.Base = "weapon_zs_base"

-- 持枪姿势
SWEP.HoldType = "pistol"

-- 模型与手臂
SWEP.ViewModel = "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.UseHands = true

-- 每次射击 2 颗弹丸
SWEP.Primary.Sound = Sound("Weapon_Gale.Single")
SWEP.Primary.Damage = 8.5
SWEP.Primary.NumShots = 2
SWEP.Primary.Delay = 0.12

-- 弹匣
SWEP.Primary.ClipSize = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散
SWEP.ConeMax = 6.3
SWEP.ConeMin = 3.5

-- 换弹速度倍率
SWEP.ReloadSpeed = 0.95

-- 开火/换弹动作手势
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

-- 移动速度
SWEP.WalkSpeed = SPEED_NORMAL

-- 武器等级
SWEP.Tier = 2

-- 机瞄位置
SWEP.IronSightsPos = Vector(-7, 15, 0)
SWEP.IronSightsAng = Vector(3, -3, -10)

-- 强化：扩散降低 + 射速提升
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.7, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.4, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.01, 1)
-- ==== 强化分支 1：重口径改装 ====
-- 射速/伤害 ×4、改用 .357 弹、12 发弹匣，大幅缩小扩散
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_galestorm_r1"), ""..translate.Get("weapon_zs_galestorm_r1_description"), function(wept)
	wept.Primary.Delay = wept.Primary.Delay * 4
	wept.Primary.Damage = wept.Primary.Damage * 4
	wept.Primary.Ammo = "357"
	wept.Primary.ClipSize = 12
	wept.Recoil = 1

	wept.ConeMin = wept.ConeMin * 0.6
	wept.ConeMax = wept.ConeMax * 0.5

	-- 分支开火音效（P90 主声 + 高速连发声）
	wept.EmitFireSound = function(self)
		self:EmitSound("weapons/p90/p90-1.wav", 70, 105, 0.65, CHAN_AUTO)
		self:EmitSound("weapons/sg552/sg552-1.wav", 70, 235, 0.65, CHAN_AUTO)
	end
end)


-- ==== PrimaryAttack - 左键开火 ====
-- 机瞄时射速放缓（×1.2）、伤害降为 0.7255 倍但弹丸数 ×1.5
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	local ironsights = self:GetIronsights()

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * (ironsights and 1.2 or 1))

	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage * (ironsights and 0.7255 or 1), self.Primary.NumShots * (ironsights and 1.5 or 1), self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== SetIronsights - 切换机瞄（带提示音） ====
function SWEP:SetIronsights(b)
	if self:GetIronsights() ~= b then
		if b then
			self:EmitSound("npc/scanner/scanner_scan4.wav", 40)
		else
			self:EmitSound("npc/scanner/scanner_scan2.wav", 40)
		end
	end

	self.BaseClass.SetIronsights(self, b)
end

-- ==== CanPrimaryAttack - 能否开火 ====
-- 机瞄时剩最后一发会自动取消机瞄（避免哑火状态）
function SWEP:CanPrimaryAttack()
	if self:GetIronsights() and self:Clip1() == 1 then
		self:SetIronsights(false)
	end

	return self.BaseClass.CanPrimaryAttack(self)
end

-- ==== SecondaryAttack - 右键开镜 ====
-- 空闲（未搬运/未换弹）时切换机瞄
function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end

-- 预缓存机瞄提示音效
util.PrecacheSound("npc/scanner/scanner_scan4.wav")
util.PrecacheSound("npc/scanner/scanner_scan2.wav")
