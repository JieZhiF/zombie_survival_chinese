-- ============================================================================
-- shared.lua - 鬣狗（黏性炸弹发射器）
-- 负责：发射黏性炸弹的投射物武器，限制同时存在的炸弹数量
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_zs_hyena") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_hyena_description") -- 武器描述

SWEP.Base = "weapon_zs_baseproj" -- 继承投射物武器基类

SWEP.HoldType = "ar2" -- 持枪姿势（突击步枪）

SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl" -- 第一人称模型（P90）
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl" -- 第三人称模型
SWEP.UseHands = true -- 使用玩家手部模型

SWEP.CSMuzzleFlashes = false -- 不使用 CS 风格枪口闪光

SWEP.Primary.Delay = 0.2 -- 射击间隔（秒）
SWEP.Primary.ClipSize = 3 -- 弹匣容量
SWEP.Primary.Automatic = true -- 全自动
SWEP.Primary.Ammo = "impactmine" -- 消耗的弹药类型（感应地雷）
SWEP.Primary.DefaultClip = 3 -- 默认赠送的弹匣倍数
SWEP.Primary.Damage = 80 -- 单发伤害

SWEP.ConeMin = 0.0001 -- 最小扩散（近似精确）
SWEP.ConeMax = 0.0001 -- 最大扩散

SWEP.WalkSpeed = SPEED_SLOW -- 持枪移动速度（慢速）

SWEP.Tier = 3 -- 武器等级（3 级）

SWEP.MaxBombs = 3 -- 场上同时存在的黏性炸弹上限

-- 附加武器修饰符：换弹速度 +10%
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)
-- 添加改装分支：伤害降至 80%，黏弹标记为可遥控引爆并改变外观颜色
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_hyena_r1"), ""..translate.Get("weapon_zs_hyena_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 0.8
	if SERVER then
		-- 服务器端：命中时设置炸弹可遥控引爆
		wept.EntModify = function(self, ent)
			self:SetNextSecondaryFire(CurTime() + 0.2)
			ent:SetDTBool(0, true)
		end
	end
	if CLIENT then
		-- 客户端：改变弹匣部件外观颜色以示改装
		wept.VElements.clipbase.color = Color(30, 95, 150)
	end
end)

-- ==== CanPrimaryAttack - 判定能否发射（不超过场上炸弹数量上限） ====
function SWEP:CanPrimaryAttack()
	if self.BaseClass.CanPrimaryAttack(self) then
		-- 统计场上属于持有者的黏性炸弹数量
		local c = 0
		for _, ent in pairs(ents.FindByClass("projectile_bomb_sticky")) do
			if ent:GetOwner() == self:GetOwner() then
				c = c + 1
			end
		end

		if c >= self.MaxBombs then return false end

		return true
	end

	return false
end

-- ==== EmitFireSound - 播放发射音效（双音效叠加） ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/ar2/ar2_altfire.wav", 70, math.random(112, 120), 0.50)
	self:EmitSound("weapons/physcannon/superphys_launch1.wav", 70, math.random(145, 155), 0.5, CHAN_AUTO + 20)
end
