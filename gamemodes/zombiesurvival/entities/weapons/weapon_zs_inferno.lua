-- ============================================================================
-- weapon_zs_inferno.lua - 地狱火步枪（AUG 造型全自动突击步枪）
-- 负责：定义步枪属性，以及"燃烧弹幕"改装分支（概率点燃僵尸）
-- ============================================================================

-- 客户端共享加载声明（本文件双端加载）
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_inferno")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_inferno_description")


-- 武器在栏位内的排序位置
SWEP.SlotPos = 0

-- 客户端专用属性：栏位分组与视角模型显示
if CLIENT then
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- HUD 3D 预览图标：挂在 AUG 模型父骨骼上
	SWEP.HUD3DBone = "v_weapon.aug_Parent"
	SWEP.HUD3DPos = Vector(-1, -2.5, -3)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015
end

-- 继承武器基础类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：AR2
SWEP.HoldType = "ar2"

-- 第一人称视角模型（CS 版 AUG）
SWEP.ViewModel = "models/weapons/cstrike/c_rif_aug.mdl"
-- 第三人称世界模型
SWEP.WorldModel = "models/weapons/w_rif_aug.mdl"
-- 使用玩家手臂模型握持
SWEP.UseHands = true

-- 左键开火音效（AUG 单发声）
SWEP.Primary.Sound = Sound("Weapon_AUG.Single")
-- 单发伤害
SWEP.Primary.Damage = 23
-- 每次射击的子弹数量
SWEP.Primary.NumShots = 1
-- 射击间隔（高射速）
SWEP.Primary.Delay = 0.095

-- 弹匣容量
SWEP.Primary.ClipSize = 40
-- 全自动射击
SWEP.Primary.Automatic = true
-- 使用的弹药类型
SWEP.Primary.Ammo = "ar2"
-- 按游戏规则填充默认备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 开火与换弹时播放的姿态动作
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

-- 扩散范围：最大/最小准星
SWEP.ConeMax = 4
SWEP.ConeMin = 1

-- 手持移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级
SWEP.Tier = 4
-- 可同时持有的最大库存数量
SWEP.MaxStock = 3

-- 机瞄时的准星偏移
SWEP.IronSightsAng = Vector(-1, -1, 0)
SWEP.IronSightsPos = Vector(-3, 4, 3)

-- 附加改装：换弹速度提升 10%
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)
-- 注册"燃烧弹幕"改装分支：伤害降低 15%，换取子弹命中时概率点燃僵尸
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_inferno_r1"), ""..translate.Get("weapon_zs_inferno_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.85

	-- 命中回调：1/6 概率点燃命中的僵尸，持续 6 秒，并把火焰归属到攻击者
	wept.BulletCallback = function(attacker, tr, dmginfo)
		local ent = tr.Entity
		if SERVER and math.random(6) == 1 and ent:IsValidLivingZombie() then
			ent:Ignite(6)
			ent:SetNWFloat("FireDieTime", CurTime() + 6)
			for __, fire in pairs(ents.FindByClass("entityflame")) do
				if fire:IsValid() and fire:GetParent() == ent then
					fire:SetOwner(attacker)
					fire:SetPhysicsAttacker(attacker)
					fire.AttackerForward = attacker
				end
			end
		end
	end
end)

