-- ============================================================================
-- weapon_zs_sawhack.lua - 锯斧（斧头+电锯组合近战武器）
-- 负责：SCK 拼装外观（斧/锯片/轨道球）、近战数值与格挡、锯斧改造分支
--       （对流血目标伤害翻倍）、火花特效与各攻击音效
-- ============================================================================

-- 共享文件：客户端也需要下载本文件
AddCSLuaFile()

-- 武器显示名（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_sawhack")

-- 客户端专属属性（SCK 视图/世界模型元素）
if CLIENT then
	-- 视图模型视场角
	SWEP.ViewModelFOV = 60

	-- 隐藏原始视图/世界模型（外观由 SCK 元素拼装）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- SCK 视图模型元素：斧柄 + 旋转锯片 + 轨道球轴心
	SWEP.VElements = {
		["axe"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.184, 1.501, -7.421), angle = Angle(2.427, -10, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["saw"] = { type = "Model", model = "models/props_junk/sawblade001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "axe", pos = Vector(0, 14, -0.021), angle = Angle(0, 0, 0), size = Vector(0.449, 0.449, 0.805), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["saw2"] = { type = "Model", model = "models/XQM/Rails/trackball_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "axe", pos = Vector(0, 14, 0), angle = Angle(0, 90, 0), size = Vector(0.234, 0.234, 0.133), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} }
	}

	-- SCK 世界模型元素：第三人称下的锯斧外观
	SWEP.WElements = {
		["axe"] = { type = "Model", model = "models/props/cs_militia/axe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.023, 2.147, -8.32), angle = Angle(-6.166, 20.881, 86.675), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["saw2"] = { type = "Model", model = "models/XQM/Rails/trackball_1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "axe", pos = Vector(0, 14, 0), angle = Angle(0, 90, 0), size = Vector(0.234, 0.234, 0.133), color = Color(255, 255, 255, 255), surpresslightning = false, material = "models/props_lab/door_klab01", skin = 0, bodygroup = {} },
		["saw"] = { type = "Model", model = "models/props_junk/sawblade001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "axe", pos = Vector(0, 14, -0.021), angle = Angle(0, 0, 0), size = Vector(0.449, 0.449, 0.805), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 使用撬棍模型作为持握骨架
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

-- 持枪姿势（双手近战姿势）
SWEP.HoldType = "melee2"

-- 主攻击间隔 0.45 秒
SWEP.Primary.Delay = 0.45

-- 近战数值：32 伤害、55 距离、1.9 判定尺寸、100 击退、轻量视角震动
SWEP.MeleeDamage = 32
SWEP.MeleeRange = 55
SWEP.MeleeSize = 1.9
SWEP.MeleeKnockBack = 100
SWEP.MeleeViewPunchScale = 0.25

-- 持枪移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 挥砍动画参数：0.15 秒挥击时间、旋转与偏移
SWEP.SwingTime = 0.15
SWEP.SwingRotation = Angle(0, -35, -50)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.HoldType = "melee2"
SWEP.SwingHoldType = "melee2"

-- 命中地面留下"砍痕"贴花；挥空动画
SWEP.HitDecal = "Manhackcut"
SWEP.HitAnim = ACT_VM_MISSCENTER

-- 格挡（防守）姿态下的斧头位置与角度
SWEP.BlockPos = Vector(-22.19, -5.29, 9.319)
SWEP.BlockAng = Angle(0.732, -14.687, -66.086)

-- 格挡时的伤害减免倍率
SWEP.DefendingDamageBlockedDefault = 2.1
SWEP.DefendingDamageBlocked = 2.1
-- 允许武器强化
SWEP.AllowQualityWeapons = true

-- 武器强化修饰器：开火延迟 -0.04 秒（第一级），近战击退 +10（第一级）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_KNOCK, 10, 1)
-- 锯斧改造分支（1 级）：挥击更慢，但对正在流血的敌人造成 1.5 倍伤害
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_sawhack_r1"), ""..translate.Get("weapon_zs_sawhack_r1_description"), function(wept)
	-- 主攻击间隔变为原来的 1.25 倍
	wept.Primary.Delay = wept.Primary.Delay * 1.25
	-- ==== OnMeleeHit（分支内）- 命中流血目标时临时提升伤害至 1.5 倍 ====
	wept.OnMeleeHit = function(self, hitent, hitflesh, tr)
		if self:GetOwner():GetBleedDamage() > 1 then
			self.MeleeDamage = wept.MeleeDamage * 1.5
		end
	end

	-- ==== PostOnMeleeHit（分支内）- 挥击结算后恢复基础伤害 ====
	wept.PostOnMeleeHit = function(self, hitent, hitflesh, tr)
		self.MeleeDamage = wept.MeleeDamage
	end
end)

-- 命中肉体时不播放通用肉体命中音（改用自定义音效）
SWEP.NoHitSoundFlesh = true

-- 武器等级 2；拆除效率（道具拆解速度倍率）
SWEP.Tier = 2
SWEP.DismantleDiv = 2

-- ==== PlaySwingSound - 挥击音效（冰镐挥击） ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(75, 80))
end

-- ==== PlayHitSound - 命中非肉体音效（锯片研磨声） ====
function SWEP:PlayHitSound()
	self:EmitSound("npc/manhack/grind"..math.random(5)..".wav")
end

-- ==== PlayHitFleshSound - 命中肉体音效（切肉机声） ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav")
end

-- ==== OnMeleeHit - 命中非肉体表面时在命中点产生火花特效 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if not hitflesh then
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetNormal(tr.HitNormal)
			effectdata:SetMagnitude(2)
			effectdata:SetScale(1)
		util.Effect("sparks", effectdata)
	end
end
