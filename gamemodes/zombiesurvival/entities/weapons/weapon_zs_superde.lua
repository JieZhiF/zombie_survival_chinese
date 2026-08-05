-- ============================================================================
-- weapon_zs_superde.lua - 超级沙漠之鹰（Super Deagle）
-- 负责：定义大威力手枪属性，以及"白焰"强化分支（子弹附加燃烧效果）
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_superde")
-- 武器商店描述
SWEP.Description = "继续加油吧"

-- 武器栏内的位置
SWEP.SlotPos = 0

-- 客户端专属配置块
if CLIENT then
	
-- 武器栏位：手枪栏
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型：手枪
SWEP.WeaponType = "pistol"
	-- 武器栏分组
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 视图模型不镜像翻转
	SWEP.ViewModelFlip = false
	-- 第一人称视野角度
	SWEP.ViewModelFOV = 65

	-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置、角度与缩放
	SWEP.HUD3DBone = "v_weapon.Deagle_Slide"
	SWEP.HUD3DPos = Vector(-1, 0, 1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.015

	-- 机瞄（开镜）时的位置偏移
	SWEP.IronSightsPos = Vector(-6.35, 5, 1.7)
end

-- 继承的武器基类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（左轮/大威力手枪）
SWEP.HoldType = "revolver"

-- 视图模型与世界模型文件
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 开火音效
SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")
-- 单发伤害
SWEP.Primary.Damage = 64
-- 每次射击的弹丸数
SWEP.Primary.NumShots = 1
-- 射击间隔
SWEP.Primary.Delay = 0.32
-- 击退力度倍率（强击退）
SWEP.Primary.KnockbackScale = 2

-- 弹匣容量 7 发
SWEP.Primary.ClipSize = 7
-- 半自动：每发需手动扣扳机
SWEP.Primary.Automatic = false
-- 使用的弹药类型
SWEP.Primary.Ammo = "pistol"
-- 按幸存模式规则计算初始备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 机瞄（开镜）时的角度与位置偏移
SWEP.IronSightsAng = Vector(-1, -1, 0)
SWEP.IronSightsPos = Vector(-3, 4, 3)


-- 最大/最小准星扩散（移动中/静止时）
SWEP.ConeMax = 3.4
SWEP.ConeMin = 1.25

-- 开火动画速度倍率
SWEP.FireAnimSpeed = 1.3

-- 武器等级（Tier 4）
SWEP.Tier = 4

-- 强化修饰器：提升伤害、降低射击间隔
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_DAMAGE, 2)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.02)

-- 注册"白焰"强化分支：每发子弹附加燃烧效果，伤害不减反增
GAMEMODE:AddNewRemantleBranch(SWEP, 1, "白焰", "每发子弹附加燃烧效果，伤害不减反增", function(wept)
	-- 分支效果：伤害提升 5%
	wept.Primary.Damage = wept.Primary.Damage * 1.05

	-- 分支效果：命中僵尸时点燃目标并转移火焰归属
	wept.BulletCallback = function(attacker, tr, dmginfo)
		local ent = tr.Entity
		if SERVER and math.random(1) == 1 and ent:IsValidLivingZombie() then
			-- 点燃目标并记录火焰熄灭时间
			ent:Ignite(2)
			ent:SetNWFloat("FireDieTime", CurTime() + 2)
			-- 将已附着在目标身上的火焰归属转移给攻击者
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
