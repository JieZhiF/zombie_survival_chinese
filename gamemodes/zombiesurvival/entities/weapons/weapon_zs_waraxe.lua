-- ============================================================================
-- weapon_zs_waraxe.lua - 战斧手枪
-- 负责：手枪类武器，每次发射3发子弹（霰弹效果），改造分支为对满血僵尸额外造成
--       10%最大生命值直接伤害
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_waraxe")

-- 栏位内排序位置
SWEP.SlotPos = 0

if CLIENT then
-- 武器栏位（手枪栏）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型：手枪
SWEP.WeaponType = "pistol"
	-- 武器栏位分组（手枪）
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 第一人称视角设置
	SWEP.ViewModelFOV = 50
	SWEP.ViewModelFlip = false

	-- 3D HUD 绘制参数（在 Glock 滑块骨上绘制弹药信息）
	SWEP.HUD3DBone = "v_weapon.Glock_Slide"
	SWEP.HUD3DPos = Vector(-1.55, 0.25, 0.1)
	SWEP.HUD3DAng = Angle(90, 0, 0)

	-- 第一人称视角模型元素（由道具拼装的自定义枪身外观）
	SWEP.VElements = {
		["barrel"] = { type = "Model", model = "models/props_phx/wheels/drugster_front.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(0, 0, -4.448), angle = Angle(180, 0, 0), size = Vector(0.019, 0.019, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_trainstation/pole_448Connection002b.mdl", bone = "v_weapon.Glock_Slide", rel = "", pos = Vector(3.292, 0.305, -0.005), angle = Angle(13.053, -90.301, 89.9), size = Vector(0.085, 0.045, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["sides"] = { type = "Model", model = "models/props_trainstation/Column_Arch001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "base", pos = Vector(-0.06, 0, -0.08), angle = Angle(0, 0, 0), size = Vector(0.119, 0.013, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}

	-- 世界模型元素（第三人称显示的自定义枪身外观）
	SWEP.WElements = {
		["barrel"] = { type = "Model", model = "models/props_phx/wheels/drugster_front.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, 0, -4.448), angle = Angle(180, 0, 0), size = Vector(0.019, 0.019, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["base"] = { type = "Model", model = "models/props_trainstation/pole_448Connection002b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6, 1.71, -3.711), angle = Angle(87.421, -5.053, 0), size = Vector(0.085, 0.045, 0.02), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["sides"] = { type = "Model", model = "models/props_trainstation/Column_Arch001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(-0.06, 0, -0.072), angle = Angle(0, 0, 0), size = Vector(0.119, 0.013, 0.09), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} }
	}
end

-- 继承基础武器类
SWEP.Base = "weapon_zs_base"

-- 持握姿势：手枪
SWEP.HoldType = "pistol"

-- 第一人称/世界模型（Glock 18手枪）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
-- 使用 C 模型手部
SWEP.UseHands = true

-- 主攻击设置：伤害14、3发子弹、0.3秒延迟
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 3
SWEP.Primary.Delay = 0.3

-- 弹匣容量9发、非全自动、手枪弹药
SWEP.Primary.ClipSize = 9
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
-- 开火音效
SWEP.Primary.Sound = ")weapons/usp/usp_unsil-1.wav"
-- 设置默认弹药（根据弹匣容量自动计算）
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 准星扩散
SWEP.ConeMax = 2.75
SWEP.ConeMin = 1.2
-- 爆头伤害倍率
SWEP.HeadshotMulti = 2

-- 武器等级
SWEP.Tier = 2

-- 机瞄位置
SWEP.IronSightsPos = Vector(-5.75, 10, 2.7)

-- 武器修饰符：弹匣容量+1、爆头倍率+0.07
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEADSHOT_MULTI, 0.07)

-- 改造分支1：对满血僵尸额外造成10%最大生命值直接伤害
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_waraxe_r1"), ""..translate.Get("weapon_zs_waraxe_r1_description"), function(wept)
	-- 伤害降低至85%
	wept.Primary.Damage = wept.Primary.Damage * 0.85

	-- 覆盖子弹命中回调
	wept.BulletCallback = function(attacker, tr, dmginfo)
		if SERVER then
			local hitent = tr.Entity
			-- 命中满血僵尸时额外造成10%最大生命值直接伤害
			if hitent:IsValidLivingZombie() and hitent:Health() == hitent:GetMaxHealthEx() and gamemode.Call("PlayerShouldTakeDamage", hitent, attacker) then
				hitent:TakeSpecialDamage(hitent:Health() * 0.1, DMG_DIRECT, attacker, attacker:GetActiveWeapon(), tr.HitPos)
			end
		end
	end
end)

-- ==== EmitFireSound - 发射音效 ====
function SWEP:EmitFireSound()
	-- 播放开火音效（随机音调）
	self:EmitSound(self.Primary.Sound, 80, math.random(78, 82))
end
