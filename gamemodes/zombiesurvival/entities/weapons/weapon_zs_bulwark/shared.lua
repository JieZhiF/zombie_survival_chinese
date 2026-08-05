-- ============================================================================
-- weapon_zs_bulwark/shared.lua - 堡垒机炮（加特林式旋转多管重机枪）
-- 负责：定义机炮属性、预转（Spin-up）机制、改装分支"重型弹链"
--       以及蓄能（Spool）状态的读写与检查
-- ============================================================================

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_bulwark")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_bulwark_description")

-- 继承武器基础类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势：霰弹枪（重型武器）
SWEP.HoldType = "shotgun"

-- 第一人称视角模型（物理枪模型，实际显示由附加模型完成）
SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
-- 第三人称世界模型
SWEP.WorldModel = "models/weapons/w_physics.mdl"
-- 隐藏原始模型，只显示附加模型拼装出的机炮外观
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
-- 使用玩家手臂模型握持
SWEP.UseHands = true

-- 单发伤害
SWEP.Primary.Damage = 24
-- 每次射击的子弹数量
SWEP.Primary.NumShots = 1
-- 射击间隔（预转后由蓄能决定实际射速）
SWEP.Primary.Delay = 0.22

-- 弹匣容量（大弹链）
SWEP.Primary.ClipSize = 150
-- 全自动射击
SWEP.Primary.Automatic = true
-- 使用的弹药类型
SWEP.Primary.Ammo = "smg1"
-- 按游戏规则填充默认备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 右键：全自动（右键也能开火）
SWEP.Secondary.Automatic = true

-- 扩散范围：最大/最小准星（本身扩散很大，靠预转时间收束）
SWEP.ConeMax = 6.15
SWEP.ConeMin = 5.25

-- 后坐力
SWEP.Recoil = 0.5

-- 武器等级
SWEP.Tier = 5
-- 可同时持有的最大库存数量
SWEP.MaxStock = 2

-- 附加改装：最大/最小扩散降低
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.769)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.656)
-- 注册"重型弹链"改装分支：伤害大幅提升、扩散减半、射速降低，
-- 每次射击消耗 3 发弹药，且蓄能越高射速越快
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_bulwark_r1"), ""..translate.Get("weapon_zs_bulwark_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 2.5
	wept.ConeMin = wept.ConeMin * 0.5
	wept.ConeMax = wept.ConeMax * 0.5
	wept.Primary.Delay = wept.Primary.Delay * 2.65
	wept.Recoil = 4

	-- 每发重弹消耗 3 发弹药
	wept.TakeAmmo = function(self)
		self:TakeCombinedPrimaryAmmo(3)
	end

	-- 开火间隔随蓄能缩短（最高 -35%）
	wept.GetFireDelay = function(self)
		return self.BaseClass.GetFireDelay(self) - (self:GetSpool() * 0.35)
	end

	-- 重型弹链的专属开火音效（低沉机枪声）
	wept.EmitFireSound = function(self)
		self:EmitSound("weapons/m249/m249-1.wav", 75, math.random(47, 49), 0.7)
		self:EmitSound("weapons/m4a1/m4a1_unsil-1.wav", 75, math.random(85, 87), 0.65, CHAN_WEAPON + 20)
	end
end)

-- 手持移动速度（最慢的 75%）
SWEP.WalkSpeed = SPEED_SLOWEST * 0.75
-- 开火动画速度倍率（极慢，配合枪管旋转）
SWEP.FireAnimSpeed = 0.3

-- ==== Initialize - 初始化武器 ====
function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	-- 创建持续旋转声（预转循环音）
	self.ChargeSound = CreateSound(self, "ambient/machines/spin_loop.wav")
end

-- ==== PrimaryAttack - 左键开火（先预转再射击） ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	-- 未预转时先启动预转：0.75 秒后枪管转起才能射击
	if not self:GetSpooling() then
		self:SetSpooling(true)
		self:EmitSound("ambient/machines/spinup.wav", 75, 65)
		self:GetOwner():ResetSpeed()

		self:SetNextPrimaryFire(CurTime() + 0.75)
	else
		-- 已预转：按当前射速开火，消耗弹药并结算子弹
		self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

		self:EmitFireSound()
		self:TakeAmmo()
		self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end
end

-- ==== SecondaryAttack - 右键开火（同左键逻辑） ====
function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	-- 右键同样触发预转，预转后仅刷新待机动画（不额外射击）
	if not self:GetSpooling() then
		self:SetSpooling(true)
		self:EmitSound("ambient/machines/spinup.wav", 75, 65)
		self:GetOwner():ResetSpeed()

		self:SetNextPrimaryFire(CurTime() + 0.75)
	else
		self.IdleAnimation = CurTime() + self:SequenceDuration()
	end
end

-- ==== TakeAmmo - 消耗弹药 ====
function SWEP:TakeAmmo()
	self:TakeCombinedPrimaryAmmo(1)
end

-- ==== CanPrimaryAttack - 检查能否开火 ====
function SWEP:CanPrimaryAttack()
	-- 没有弹药不能开火
	if self:GetPrimaryAmmoCount() <= 0 then
		return false
	end

	-- 搬运物品或放置路障预览时禁止开火
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	return self:GetNextPrimaryFire() <= CurTime()
end

-- ==== CanSecondaryAttack - 检查能否右键开火 ====
function SWEP:CanSecondaryAttack()
	-- 搬运物品或放置路障预览时禁止开火
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	return self:GetNextPrimaryFire() <= CurTime()
end

-- ==== GetWalkSpeed - 计算移动速度（预转期间减速一半） ====
function SWEP:GetWalkSpeed()
	return self.BaseClass.GetWalkSpeed(self) * (self:GetSpooling() and 0.5 or 1)
end

-- ==== EmitFireSound - 播放开火音效 ====
function SWEP:EmitFireSound()
	-- 主射击声（机枪）+ 附加高频层叠声
	self:EmitSound("weapons/m249/m249-1.wav", 75, math.random(86, 89), 0.65)
	self:EmitSound("weapons/m4a1/m4a1_unsil-1.wav", 75, math.random(122, 125), 0.6, CHAN_WEAPON + 20)
end

-- ==== Reload - 禁止换弹（用大弹链） ====
function SWEP:Reload()
end

-- ==== Holster - 收起武器（停止旋转声） ====
function SWEP:Holster()
	self.ChargeSound:Stop()

	return self.BaseClass.Holster(self)
end

-- ==== OnRemove - 武器移除时停止旋转声 ====
function SWEP:OnRemove()
	self.ChargeSound:Stop()
end

-- ==== SetSpool - 设置蓄能等级（DT 浮点 9） ====
function SWEP:SetSpool(spool)
	self:SetDTFloat(9, spool)
end

-- ==== GetSpool - 读取蓄能等级 ====
function SWEP:GetSpool()
	return self:GetDTFloat(9)
end

-- ==== SetSpooling - 设置预转状态（DT 布尔 1） ====
function SWEP:SetSpooling(isspool)
	self:SetDTBool(1, isspool)
end

-- ==== GetSpooling - 读取预转状态 ====
function SWEP:GetSpooling()
	return self:GetDTBool(1)
end

-- ==== GetFireDelay - 计算开火间隔（蓄能越高射速越快，最高 -15%） ====
function SWEP:GetFireDelay()
	return self.BaseClass.GetFireDelay(self) - (self:GetSpool() * 0.15)
end

-- ==== CheckSpool - 每帧检查并更新预转/蓄能状态 ====
function SWEP:CheckSpool()
	-- 预转中：按住左/右键则维持预转并缓慢蓄能，松开则停止预转
	if self:GetSpooling() then
		if not self:GetOwner():KeyDown(IN_ATTACK) and not self:GetOwner():KeyDown(IN_ATTACK2) then
			self:SetSpooling(false)
			self:GetOwner():ResetSpeed()
			self:SetNextPrimaryFire(CurTime() + 0.75)
			self:EmitSound("ambient/machines/spindown.wav", 75, 150)
		else
			self:SetSpool(math.min(self:GetSpool() + FrameTime() * 0.12, 1))
		end

		-- 旋转声随蓄能等级升高音调
		self.ChargeSound:PlayEx(1, math.min(255, 65 + self:GetSpool() * 25))
	else
		-- 未预转：蓄能快速衰减，停止旋转声
		self:SetSpool(math.max(0, self:GetSpool() - FrameTime() * 0.36))
		self.ChargeSound:Stop()
	end
end
