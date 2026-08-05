-- ============================================================================
-- weapon_zs_juggernaut.lua - 重型机枪「主宰者」（Juggernaut）
-- 负责：定义重型机枪的武器属性、开火音效、后坐力与特殊抛壳弹幕机制
-- ============================================================================

AddCSLuaFile()

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_juggernaut")
SWEP.Description = ""..translate.Get("weapon_zs_juggernaut_description")


-- 武器在武器选择栏中的槽位序号
SWEP.SlotPos = 0

if CLIENT then
	-- 武器栏槽位（归类为突击步枪分类）
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
SWEP.WeaponType = "rifle"
	SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE

	-- 第一人称视角设置：不翻转、视野 FOV 60
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- 3D HUD 中展示武器模型的绑定骨骼与位置/角度/缩放
	SWEP.HUD3DBone = "v_weapon.m249"
	SWEP.HUD3DPos = Vector(1.4, -1.3, 5)
	SWEP.HUD3DAng = Angle(180, 0, 0)
	SWEP.HUD3DScale = 0.015
end

-- 继承基础武器模板
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（AR2 步枪姿势）
SWEP.HoldType = "ar2"

-- 第一人称与第三人称模型，使用玩家的手部模型
SWEP.ViewModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"
SWEP.UseHands = true

-- 左键开火：单发伤害 21、单次 1 发、射速 0.08 秒一发
SWEP.Primary.Sound = Sound("weapons/m249/m249-1.wav")
SWEP.Primary.Damage = 21
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.08

-- 弹匣 90 发、全自动、消耗 ar2 弹药
SWEP.Primary.ClipSize = 90
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 开火与换弹动作手势
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_AR2

-- 开火后坐力强度
SWEP.Recoil = 4

-- 扩散范围（最大/最小准星扩散）
SWEP.ConeMax = 6
SWEP.ConeMin = 2.4

-- 持枪移动速度（最慢档）
SWEP.WalkSpeed = SPEED_SLOWEST

-- 武器等级 5，商店最大库存 2
SWEP.Tier = 5
SWEP.MaxStock = 2

-- 机瞄时视角偏移位置与角度
SWEP.IronSightsAng = Vector(-1, -1, 0)
SWEP.IronSightsPos = Vector(-3, 4, 3)

-- 附加武器改造：换弹速度 +10%、开火间隔 -0.01 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.01)

-- ==== PrimaryAttack - 左键开火，弹匣剩 2 发时触发 5 倍惩罚延迟 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	-- 设定下次开火时间：剩余 2 发时开火间隔变为 5 倍（弹药告急惩罚）
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay() * (self:Clip1() == 2 and 5 or 1))

	-- 播放开火音效、消耗弹药并射出子弹
	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	self.IdleAnimation = CurTime() + self:SequenceDuration()
end

-- ==== EmitFireSound - 播放开火音效，最后一发时叠加特殊音效 ====
function SWEP:EmitFireSound()
	-- 常规开火音效
	self:EmitSound(self.Primary.Sound)

	-- 弹匣剩余 1 发时额外播放警示音（提示弹药即将耗尽）
	if self:Clip1() == 1 then
		self:EmitSound("weapons/sg552/sg552-1.wav", 70, 45, 0.95, CHAN_AUTO)
	end
end

-- ==== ShootBullets - 射出子弹，空仓时爆发弹壳弹幕 ====
function SWEP:ShootBullets(dmg, numbul, cone)
	local owner = self:GetOwner()
	local zeroclip = self:Clip1() == 0

	self:SendWeaponAnimation()
	owner:DoAttackEvent()
	-- 后坐力视角震动：空仓时震动更强（r2 为 1），否则仅轻微随机晃动
	if self.Recoil > 0 then
		local r2 = zeroclip and 1 or 0
		local r = math.Rand(0.8, 1) * r2
		owner:ViewPunch(Angle(r * -self.Recoil, r * (math.random(2) == 1 and -1 or 1) * self.Recoil, (r2 - r) * (math.random(2) == 1 and -1 or 1) * self.Recoil))
	end

	-- 服务器端：每第 10 发或空仓时生成弹壳投射物（projectile_juggernaut）
	if SERVER and (self:Clip1() % 10 == 1 or zeroclip) then
		-- 空仓时一次性抛射 8 枚弹壳，否则抛射 1 枚
		for i = 1, zeroclip and 8 or 1 do
			local ent = ents.Create("projectile_juggernaut")
			if ent:IsValid() then
				ent:SetPos(owner:GetShootPos())

				-- 初始朝向：以瞄准方向为基准绕上轴旋转 90 度
				local angle = owner:GetAimVector():Angle()
				angle:RotateAroundAxis(angle:Up(), 90)
				ent:SetAngles(angle)

				-- 记录伤害、来源武器与所属队伍
				ent:SetOwner(owner)
				ent.ProjDamage = self.Primary.Damage * 0.75 * (owner.ProjectileDamageMul or 1)
				ent.ProjSource = self
				ent.Team = owner:Team()

				ent:Spawn()

				-- 给弹壳一个随机方向的初始速度（受扩散与投射物速度加成影响）
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()

					angle = owner:GetAimVector():Angle()
					angle:RotateAroundAxis(angle:Forward(), math.Rand(0, 360))
					angle:RotateAroundAxis(angle:Up(), math.Rand(-cone/1.5, cone/1.5))
					phys:SetVelocityInstantaneous(angle:Forward() * 700 * (owner.ProjectileSpeedMul or 1))
				end
			end
		end
	end

	-- 延迟补偿后发射主子弹：空仓时子弹数 12 倍、伤害降为 2/3
	owner:LagCompensation(true)
	owner:FireBulletsLua(owner:GetShootPos(), owner:GetAimVector(), cone, numbul * (zeroclip and 12 or 1), dmg / (zeroclip and 1.5 or 1), nil, self.Primary.KnockbackScale, self.TracerName, self.BulletCallback, self.Primary.HullSize, nil, self.Primary.MaxDistance, nil, self)
	owner:LagCompensation(false)
end
