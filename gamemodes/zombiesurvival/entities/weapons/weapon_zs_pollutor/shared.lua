-- ============================================================================
-- weapon_zs_pollutor/shared.lua - 生化喷射枪「污染者」（Pollutor）共享端
-- 负责：定义生化枪属性、两种改造分支（毒/冰系）与开火音效
-- ============================================================================

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_pollutor")
SWEP.Description = ""..translate.Get("weapon_zs_pollutor_description")

-- 继承投射物武器基础模板（weapon_zs_baseproj）
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势（冲锋枪姿势）
SWEP.HoldType = "smg"

-- 第一人称与第三人称模型（UMP45），使用玩家的手部模型
SWEP.ViewModel = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光
SWEP.CSMuzzleFlashes = false

-- 弹匣 20 发、全自动、消耗化学弹药（备弹 20 发）
SWEP.Primary.ClipSize = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "chemical"
SWEP.Primary.Delay = 0.45
SWEP.Primary.DefaultClip = 20
-- 单发伤害 34、每次 1 发
SWEP.Primary.Damage = 34
SWEP.Primary.NumShots = 1

-- 扩散范围（最大/最小准星扩散）
SWEP.ConeMax = 3
SWEP.ConeMin = 2.5

-- 持枪移动速度（慢速）
SWEP.WalkSpeed = SPEED_SLOW

-- 武器等级 3，商店最大库存 3
SWEP.Tier = 3
SWEP.MaxStock = 3

-- 开火动画播放速度倍率 0.4（动画放慢）
SWEP.FireAnimSpeed = 0.4

-- 附加武器改造：开火间隔 -0.05 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.05)

-- 改造分支 1「腐蚀毒液」：伤害降为 86%，投射物标记为毒系（DTInt 5 = 1）
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_pollutor_r1"), ""..translate.Get("weapon_zs_pollutor_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.86

	if SERVER then
		wept.EntModify = function(self, ent)
			ent:SetDTInt(5, 1)
		end
	else
		-- 客户端：枪体生化液管改为毒系橙黄色
		wept.VElements["bio++++++++++"].color = Color(230, 150, 100)
		wept.VElements["bio++++++"].color = Color(230, 150, 100)
		wept.WElements["bio++++++++++"].color = Color(230, 150, 100)
		wept.WElements["bio++++++"].color = Color(230, 150, 100)
	end
end)
-- 毒系分支的等级外观颜色与名称（1-3 级）
branch.Colors = {Color(255, 160, 50), Color(215, 120, 50), Color(175, 100, 40)}
branch.NewNames = {""..translate.Get("weapon_zs_pollutor_r1_l1"), ""..translate.Get("weapon_zs_pollutor_r1_l2"), ""..translate.Get("weapon_zs_pollutor_r1_l3")}

-- 改造分支 2「冰冻吐息」：伤害降为 77%，投射物标记为冰系（DTInt 5 = 2）
branch = GAMEMODE:AddNewRemantleBranch(SWEP, 2, ""..translate.Get("weapon_zs_pollutor_r2"), ""..translate.Get("weapon_zs_pollutor_r2_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.77

	if SERVER then
		wept.EntModify = function(self, ent)
			ent:SetDTInt(5, 2)
		end
	else
		-- 客户端：枪体生化液管改为冰系淡蓝色
		wept.VElements["bio++++++++++"].color = Color(100, 190, 230)
		wept.VElements["bio++++++"].color = Color(100, 190, 230)
		wept.WElements["bio++++++++++"].color = Color(100, 190, 230)
		wept.WElements["bio++++++"].color = Color(100, 190, 230)
	end
end)
-- 冰系分支的等级外观颜色与名称（1-3 级）
branch.Colors = {Color(50, 160, 255), Color(50, 130, 215), Color(40, 115, 175)}
branch.NewNames = {""..translate.Get("weapon_zs_pollutor_r2_l1"), ""..translate.Get("weapon_zs_pollutor_r2_l2"), ""..translate.Get("weapon_zs_pollutor_r2_l3")}

-- ==== EmitFireSound - 播放开火音效（发射声 + 生物吞噬声） ====
function SWEP:EmitFireSound()
	self:EmitSound("^weapons/mortar/mortar_fire1.wav", 70, math.random(88, 92), 0.65)
	self:EmitSound("npc/barnacle/barnacle_gulp2.wav", 70, 70, 0.85, CHAN_AUTO + 20)
end
