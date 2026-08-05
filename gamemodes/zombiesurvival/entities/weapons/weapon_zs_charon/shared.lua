-- ============================================================================
-- weapon_zs_charon/shared.lua - 共享端：卡戎（Charon）重型连弩基础属性与开火逻辑
-- 负责：武器基础数值、改装分支（Remantle）、主攻击/换弹/动画流程
-- ============================================================================
-- 武器显示名（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_charon")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_charon_description")

-- 基础母本：抛射物武器基类
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势：弩
SWEP.HoldType = "crossbow"

-- 第一人称模型：CS 十字弩
SWEP.ViewModel = "models/weapons/c_crossbow.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"
-- 使用玩家手臂模型持弩
SWEP.UseHands = true

-- 不使用 CS 风格枪口闪光（弩无枪口火光）
SWEP.CSMuzzleFlashes = false

-- 开火音效：弩箭发射
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
-- 射击间隔（秒）
SWEP.Primary.Delay = 0.4
-- 按住左键可连发
SWEP.Primary.Automatic = true
-- 单发伤害
SWEP.Primary.Damage = 68

-- 弹匣容量
SWEP.Primary.ClipSize = 8
-- 弹药类型：弩箭
SWEP.Primary.Ammo = "XBowBolt"
-- 默认备弹量
SWEP.Primary.DefaultClip = 40

-- 持枪移动速度：慢速
SWEP.WalkSpeed = SPEED_SLOW
-- 武器等级
SWEP.Tier = 3

-- 换弹基础耗时（秒）
SWEP.ReloadDelay = 2.8
-- 基础后坐力
SWEP.Recoil = 2

-- 最大扩散（移动/跳跃时）
SWEP.ConeMax = 3.5
-- 最小扩散（静止时）
SWEP.ConeMin = 3.25

-- 下一次允许开镜的时间戳
SWEP.NextZoom = 0

-- 武器母本级加成：全武器射击间隔缩短 0.03 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.03)
-- 新增改装分支：速射型（弹匣翻倍、射速加倍、伤害略降，改用速射箭矢）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_charon_r1"), ""..translate.Get("weapon_zs_charon_r1_description"), function(wept)
	-- 弹匣容量翻倍
	wept.Primary.ClipSize = math.floor(wept.Primary.ClipSize * 2)
	-- 射击间隔减半
	wept.Primary.Delay = wept.Primary.Delay * 0.5
	-- 伤害降为原来的 78%
	wept.Primary.Damage = wept.Primary.Damage * 0.78
	-- 改用速射箭矢抛射物（弹道与特效不同）
	wept.Primary.Projectile = "projectile_arrow_sli"

	-- 扩散加大 40%（以射速换精度）
	wept.ConeMax = wept.ConeMax * 1.4
	wept.ConeMin = wept.ConeMin * 1.4
	-- 换弹速度提升 30%
	wept.ReloadSpeed = wept.ReloadSpeed * 0.7
end)

-- ==== PrimaryAttack - 左键主攻击：发射箭矢并推进动画状态 ====
function SWEP:PrimaryAttack()
	-- 弹药不足或射速冷却中则中止
	if not self:CanPrimaryAttack() then return end
	-- 按基础射速与改装加成设定下次开火时间
	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay())

	-- 播放开火音效、消耗一发弹药并按当前扩散发射箭矢
	self:EmitFireSound()
	self:TakeAmmo()
	self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone())
	-- 记录闲置动画切换点：开火动画播完一整轮后再回到闲置动作
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	-- 记录本次开火时间（客户端据此驱动弩弦收回动画）
	self:SetShootTime(CurTime())
end

-- ==== EmitReloadSound - 播放弩的装填音效（仅首次预测时执行一次） ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		-- 随机播放两种搭箭音之一，再补拉弦音
		self:EmitSound("weapons/crossbow/bolt_load"..math.random(2)..".wav", 50, 100, 1, CHAN_AUTO)
		self:EmitSound("weapons/crossbow/reload1.wav")
	end
end

-- ==== SendWeaponAnimation - 播放开火动作并控制模型播放速率 ====
function SWEP:SendWeaponAnimation()
	-- 播放 FIDGET 动作作为开火反馈
	self:SendWeaponAnim(ACT_VM_FIDGET)
	-- 模型播放速率跟随开火动画速率（射速越快动作越快）
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed)
	-- 开火间隔约三分之一后切回闲置动画并恢复快速播放速率
	timer.Simple(self.Primary.Delay/3.5, function()
		if IsValid(self) then
			self:SendWeaponAnim(ACT_VM_IDLE)
			self:GetOwner():GetViewModel():SetPlaybackRate(6)
		end
	end)
end

-- ==== SendReloadAnimation - 换弹动画（该武器无专用换弹动作，留空） ====
function SWEP:SendReloadAnimation()
end

-- ==== ProcessReloadEndTime - 计算换弹完成时间点 ====
function SWEP:ProcessReloadEndTime()
	-- 实际换弹速度 = 基础换弹速度 × 玩家身上的换弹倍率
	local reloadspeed = self.ReloadSpeed * self:GetReloadSpeedMultiplier()
	-- 完成时间 = 当前时间 + 基础换弹耗时 / 实际速度
	self:SetReloadFinish(CurTime() + self.ReloadDelay / reloadspeed)
end

-- ==== SetShootTime - 记录开火时间戳（网络同步给客户端驱动弓弦动画） ====
function SWEP:SetShootTime(time)
	-- 写入数据表浮点槽位 8
	self:SetDTFloat(8, time)
end

-- ==== GetShootTime - 读取最近一次开火时间戳 ====
function SWEP:GetShootTime()
	return self:GetDTFloat(8)
end

-- 预缓存换弹与开镜音效，避免首次播放时卡顿
util.PrecacheSound("weapons/crossbow/bolt_load1.wav")
util.PrecacheSound("weapons/crossbow/bolt_load2.wav")
util.PrecacheSound("weapons/sniper/sniper_zoomin.wav")
util.PrecacheSound("weapons/sniper/sniper_zoomout.wav")
