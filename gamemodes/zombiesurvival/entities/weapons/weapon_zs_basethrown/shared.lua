-- ============================================================================
-- shared.lua - 投掷物武器基类共享定义（手雷类）
-- 负责：定义投掷武器基础属性；实现左键投掷（消耗弹药、播放音效动画）、
--       弹药耗尽自动移除武器，以及部署/收起动画逻辑
-- ============================================================================
-- 继承自武器总基类
SWEP.Base = "weapon_zs_base"

-- 第一人称/第三人称模型（借用碎片手雷模型）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
-- 使用玩家手部模型
SWEP.UseHands = true

-- 持有该武器时获得相应弹药
SWEP.AmmoIfHas = true

-- 主攻击：弹匣 1 发、半自动、消耗手雷弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "grenade"
-- 投掷间隔（秒）
SWEP.Primary.Delay = 1.25
SWEP.Primary.DefaultClip = 1
-- 投掷音效
SWEP.Primary.Sound = Sound("WeaponFrag.Throw")

-- 副攻击：占位配置（实际投掷逻辑走主攻击）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"

-- 持枪移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 一次性消耗品，不允许品质强化
SWEP.AllowQualityWeapons = false

-- ==== Initialize - 武器初始化 ====
-- 设置投掷姿势与部署速度；客户端额外初始化动画系统
function SWEP:Initialize()
	self:SetWeaponHoldType("grenade")
	GAMEMODE:DoChangeDeploySpeed(self)

	if CLIENT then
		self:Anim_Initialize()
	end
end

-- ==== Precache - 预缓存投掷音效 ====
function SWEP:Precache()
	util.PrecacheSound("WeaponFrag.Throw")
end

-- ==== CanPrimaryAttack - 检查投掷是否可用 ====
-- 手持道具或建造预览中禁止投掷；弹药耗尽时触发空投冷却
function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 弹药耗尽：进入冷却并拒绝本次投掷
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return self:GetNextPrimaryFire() <= CurTime()
end

-- ==== PrimaryAttack - 左键投掷 ====
-- 进入冷却、播放投掷音效、消耗 1 发弹药、生成投射物（secondary 为真时按副模式投掷）
function SWEP:PrimaryAttack(secondary)
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo(1)
	self:ShootBullets(secondary)
	-- 1 秒后执行投掷后动画/移除检查
	self.NextDeploy = CurTime() + 1
end

-- ==== SecondaryAttack - 右键以副模式投掷 ====
function SWEP:SecondaryAttack()
	self:PrimaryAttack(true)
end

-- ==== CanSecondaryAttack - 右键判定（框架占位，始终禁用） ====
function SWEP:CanSecondaryAttack()
	return false
end

-- ==== Reload - 禁止手动换弹（投掷物无需装填） ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 拔出武器 ====
-- 触发部署事件；弹药耗尽时播放投掷动画示意即将用尽
function SWEP:Deploy()
	GAMEMODE:WeaponDeployed(self:GetOwner(), self)

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	end

	return true
end

-- ==== Holster - 收起武器 ====
function SWEP:Holster()
	self.NextDeploy = nil
	return true
end

-- ==== Think - 每帧逻辑：处理投掷后动画与弹药耗尽移除 ====
function SWEP:Think()
	if self.NextDeploy and self.NextDeploy <= CurTime() then
		-- 到达投掷后时刻：有弹药播拔出动画，无弹药播投掷动画并移除武器
		self.NextDeploy = nil

		if 0 < self:GetPrimaryAmmoCount() then
			self:SendWeaponAnim(ACT_VM_DRAW)
		else
			self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

			if SERVER then
				self:GetOwner():StripWeapon(self:GetClass())
			end
		end
	elseif SERVER and self:GetPrimaryAmmoCount() <= 0 then
		-- 服务端：弹药耗尽立即移除武器
		self:GetOwner():StripWeapon(self:GetClass())
	end
end
