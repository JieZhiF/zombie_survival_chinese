-- ============================================================================
-- weapon_zs_eraser.lua - 橡皮擦（五七式半自动手枪）
-- 负责：弹匣越空伤害越高的特殊机制、强化分支（波次成长）与动态音调
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()
-- 定义基类（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_base")

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_eraser")
SWEP.Description = ""..translate.Get("weapon_zs_eraser_description")

-- 武器栏中的位置
SWEP.SlotPos = 0

if CLIENT then
-- 客户端专属：武器槽位（手枪槽）
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotPistols")
-- 武器类型（单行多语句，保持原样）
SWEP.WeaponType = "pistol"
	-- 槽位分组：手枪
	SWEP.SlotGroup = WEPSELECT_PISTOL
	-- 第一人称视野 / 模型翻转
	SWEP.ViewModelFOV = 60
	SWEP.ViewModelFlip = false

	-- 武器栏 3D 预览：骨骼 / 位置 / 角度
	SWEP.HUD3DBone = "v_weapon.FIVESEVEN_PARENT"
	SWEP.HUD3DPos = Vector(-1, -2.5, -1)
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

-- 继承基础武器
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（手枪姿势）
SWEP.HoldType = "pistol"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 开火音效 / 单发伤害 / 单次射击弹数 / 射击间隔
SWEP.Primary.Sound = Sound("weapons/ar2/npc_ar2_altfire.wav")
SWEP.Primary.Damage = 23.5
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15

-- 弹匣容量 / 半自动 / 弹药类型
SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
-- 按游戏模式规则设置初始弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 扩散：最大 2.5 / 最小 1.25
SWEP.ConeMax = 2.5
SWEP.ConeMin = 1.25

-- 换弹速度倍率 / 爆头伤害倍率
SWEP.ReloadSpeed = 1
SWEP.HeadshotMulti = 2

-- 武器等级（Tier 2）
SWEP.Tier = 2

-- 机瞄位置
SWEP.IronSightsPos = Vector(-5.95, 0, 2.5)

-- 强化词条：换弹速度 +0.1 / 爆头倍率 +0.07
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEADSHOT_MULTI, 0.07)
-- 强化分支（成长武器）：扩散增大、换弹变慢、爆头倍率降低，但伤害随波次增长（每 15 波翻倍）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_eraser_r1"), ""..translate.Get("weapon_zs_eraser_r1_description"), function(wept)
	wept.ConeMax = wept.ConeMax * 1.7
	wept.ConeMin = wept.ConeMin * 2.1
	wept.ReloadSpeed = wept.ReloadSpeed * 0.7
	wept.HeadshotMulti = wept.HeadshotMulti * 0.9

	-- 子弹命中回调：额外增加与当前波次成正比的伤害
	wept.BulletCallback = function(attacker, tr, dmginfo)
		dmginfo:SetDamage(dmginfo:GetDamage() + dmginfo:GetDamage() * GAMEMODE:GetWave()/15)
	end
end)

-- ==== EmitFireSound - 播放开火音效（音调随弹匣剩余量升高） ====
function SWEP:EmitFireSound()
	-- 弹匣越空，机械音与能量音的音调越高
	self:EmitSound("weapons/fiveseven/fiveseven-1.wav", 75, 80 + (1 - (self:Clip1() / self.Primary.ClipSize)) * 30, 0.8, 21)
	self:EmitSound(self.Primary.Sound, 75, 130 + (1 - (self:Clip1() / self.Primary.ClipSize)) * 70, 0.75, 22)
end

-- ==== ShootBullets - 发射子弹（伤害随弹匣减少而提升） ====
function SWEP:ShootBullets(dmg, numbul, cone)
	-- 弹匣越空伤害越高：满匣时无加成，空匣时伤害翻倍
	dmg = dmg + dmg * (1 - self:Clip1() / self.Primary.ClipSize)

	BaseClass.ShootBullets(self, dmg, numbul, cone)
end
