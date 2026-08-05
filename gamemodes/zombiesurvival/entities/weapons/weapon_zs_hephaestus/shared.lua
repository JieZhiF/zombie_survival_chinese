-- ============================================================================
-- shared.lua - 赫菲斯托斯（共享端）
-- 负责：蓄能脉冲武器属性、改装分支（散射弹跳）与蓄力/开火核心逻辑
-- ============================================================================
SWEP.PrintName = ""..translate.Get("weapon_zs_hephaestus") -- 武器显示名称
SWEP.Description = ""..translate.Get("weapon_zs_hephaestus_description") -- 武器描述

SWEP.Base = "weapon_zs_base" -- 继承武器基础类

SWEP.HoldType = "ar2" -- 持枪姿势（突击步枪）

SWEP.ViewModel = "models/weapons/c_shotgun.mdl" -- 第一人称模型
SWEP.WorldModel = "models/weapons/w_physics.mdl" -- 第三人称模型
SWEP.ShowViewModel = false -- 不显示默认第一人称模型
SWEP.ShowWorldModel = false -- 不显示默认第三人称模型
SWEP.UseHands = true -- 使用玩家手部模型

SWEP.Primary.Sound = Sound("weapons/gauss/fire1.wav") -- 开火音效（高斯炮）
SWEP.Primary.Damage = 26.5 -- 单发伤害
SWEP.Primary.NumShots = 1 -- 一次射击的子弹数
SWEP.Primary.Delay = 0.2 -- 射击间隔（秒）

SWEP.Primary.ClipSize = 30 -- 弹匣容量
SWEP.Primary.Automatic = true -- 全自动
SWEP.Primary.Ammo = "pulse" -- 消耗的弹药类型（脉冲电池）
SWEP.WeaponType = "pulse" -- 武器类型（脉冲类）
SWEP.Primary.DefaultClip = 30 -- 默认赠送的弹匣倍数

SWEP.ConeMax = 3 -- 最大扩散
SWEP.ConeMin = 1.5 -- 最小扩散

SWEP.HeadshotMulti = 1.5 -- 爆头伤害倍率

SWEP.ChargeDelay = 0.12 -- 每级蓄能的间隔时间（秒）

SWEP.Tier = 5 -- 武器等级（5 级）

-- 附加武器修饰符：开火间隔 -0.01 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.01)
-- 添加改装分支：三发散射、总伤害降低，命中墙壁时反弹跳弹
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_hephaestus_r1"), ""..translate.Get("weapon_zs_hephaestus_r1_description"), function(wept)
	wept.Primary.Delay = wept.Primary.Delay * 1.4
	wept.Primary.Damage = wept.Primary.Damage * 1.2/3
	wept.Primary.NumShots = 3

	wept.ChargeDelay = 0.08

	-- 跳弹逻辑：沿入射方向反弹一发子弹
	local function DoRicochet(attacker, hitpos, hitnormal, normal, damage)
		attacker.RicochetBullet = true
		if attacker:IsValid() then
			attacker:FireBulletsLua(hitpos, 2 * hitnormal * hitnormal:Dot(normal * -1) + normal, 0, 1, damage, nil, nil, "tracer_heph_alt", nil, nil, nil, nil, nil, attacker:GetActiveWeapon())
		end
		attacker.RicochetBullet = nil
	end
	-- 子弹命中回调：击中可反弹表面时延迟触发跳弹，并取消原命中特效
	wept.BulletCallback = function(attacker, tr, dmginfo)
		if SERVER and tr.HitWorld and not tr.HitSky and tr.HitNormal:Dot(tr.Normal) > -0.2 then
			local hitpos, hitnormal, normal, dmg = tr.HitPos, tr.HitNormal, tr.Normal, dmginfo:GetDamage() * 1.2
			timer.Simple(0, function() DoRicochet(attacker, hitpos, hitnormal, normal, dmg) end)
		end

		return {impact = false}
	end
end)

SWEP.WalkSpeed = SPEED_SLOW -- 持枪移动速度（慢速）
SWEP.FireAnimSpeed = 1 -- 开火动画播放速度

SWEP.TracerName = "tracer_heph" -- 子弹曳光特效名称

-- ==== TakeAmmo - 消耗弹药（客户端记录后坐偏移起始值） ====
function SWEP:TakeAmmo()
	self:TakeCombinedPrimaryAmmo(1)

	if CLIENT then
		self.LastVel = 7
	end
end

-- ==== Reload - 禁用换弹（蓄能武器无需换弹） ====
function SWEP:Reload()
end

-- ==== Initialize - 初始化并创建蓄能循环音效句柄 ====
function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	self.ChargeSound = CreateSound(self, "weapons/gauss/chargeloop.wav")
end

-- ==== CanPrimaryAttack - 判定能否开火（有弹药且未在蓄能/持有物/搭建预览状态） ====
function SWEP:CanPrimaryAttack()
	if self:GetPrimaryAmmoCount() <= 0 then
		return false
	end

	if self:GetCharging() or self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	return self:GetNextPrimaryFire() <= CurTime()
end

-- ==== SecondaryAttack - 右键开始蓄能（消耗弹药并标记蓄能状态） ====
function SWEP:SecondaryAttack()
	if not self:CanPrimaryAttack() or self:GetCharging() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())
	self:SetLastChargeTime(CurTime())
	self:TakeAmmo()
	self:SetCharging(true)
end

-- ==== BulletCallback - 默认子弹命中回调（取消命中特效，不产生常规冲击） ====
function SWEP.BulletCallback(attacker, tr, dmginfo)
	return {impact = false}
end

-- ==== CheckCharge - 蓄能状态逐帧处理：松开右键开炮 / 按住继续蓄能 ====
function SWEP:CheckCharge()
	if self:GetCharging() then
		local owner = self:GetOwner()
		if not owner:KeyDown(IN_ATTACK2) then
			-- 松开右键：播放音效并按当前蓄能等级发射高倍率子弹
			self:EmitFireSound()

			self.FireAnimSpeed = 0.3
			self:ShootBullets(self.Primary.Damage * self:GetGunCharge(), self.Primary.NumShots, self:GetCone())
			self.IdleAnimation = CurTime() + self:SequenceDuration()
			self.FireAnimSpeed = 1

			-- 后坐力：悬空并向瞄准方向反冲
			owner:SetGroundEntity(NULL)
			owner:SetVelocity(-34 * self:GetGunCharge() * owner:GetAimVector())

			-- 重置蓄能状态与冷却
			self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * 4)
			self:SetCharging(false)
			self:SetLastChargeTime(CurTime())
			self:SetGunCharge(0)
		elseif self:GetGunCharge() < 13 and self:GetPrimaryAmmoCount() ~= 0 and self:GetLastChargeTime() + self.ChargeDelay < CurTime() then
			-- 按住右键且未达上限：每级蓄能间隔提升一级并消耗弹药
			self:SetGunCharge(self:GetGunCharge() + 1)
			self:SetLastChargeTime(CurTime())
			self:TakeAmmo()
		end

		-- 蓄能音效随等级升高音调
		self.ChargeSound:PlayEx(1, math.min(255, 47 + self:GetGunCharge() * 16))
	else
		self.ChargeSound:Stop()
	end
end

-- ==== SetLastChargeTime - 记录上次蓄能升级时间（网络同步） ====
function SWEP:SetLastChargeTime(lct)
	self:SetDTFloat(8, lct)
end

-- ==== GetLastChargeTime - 读取上次蓄能升级时间 ====
function SWEP:GetLastChargeTime()
	return self:GetDTFloat(8)
end

-- ==== SetGunCharge - 设置当前蓄能等级（网络同步） ====
function SWEP:SetGunCharge(charge)
	self:SetDTInt(1, charge)
end

-- ==== GetGunCharge - 读取当前蓄能等级 ====
function SWEP:GetGunCharge(charge)
	return self:GetDTInt(1)
end

-- ==== SetCharging - 设置蓄能状态（网络同步） ====
function SWEP:SetCharging(charge)
	self:SetDTBool(1, charge)
end

-- ==== GetCharging - 读取蓄能状态 ====
function SWEP:GetCharging()
	return self:GetDTBool(1)
end

-- ==== EmitFireSound - 播放开火音效（音调随蓄能等级升高）与余音 ====
function SWEP:EmitFireSound()
	local deduct = self:GetCharging() and 100 - self:GetGunCharge() or 100
	local owner = self:GetOwner()

	self:EmitSound("weapons/gauss/fire1.wav", 75, deduct, 0.9)
	timer.Simple(0.2, function()
		if self:IsValid() and owner:IsValid() and not owner:KeyDown(IN_ATTACK) then
			self:EmitSound("weapons/zs_heph/electro"..math.random(4,6)..".wav", 75, deduct, 0.75, CHAN_WEAPON + 20)
		end
	end)
end
