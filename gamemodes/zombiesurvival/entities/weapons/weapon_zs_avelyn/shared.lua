-- ============================================================================
-- weapon_zs_avelyn/shared.lua - 阿弗琳连弩（共享定义与三连射逻辑）
-- 负责：定义连弩属性；实现"一次扣扳机连射 3 支弩箭"的爆发机制
--       （分次发射、独立计时），以及换弹/开火音效
-- ============================================================================
-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_avelyn")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_avelyn_description")

-- 继承投射物武器母本
SWEP.Base = "weapon_zs_baseproj"
DEFINE_BASECLASS("weapon_zs_baseproj") -- 定义 BaseClass 引用

-- 手持姿势：霰弹枪姿势
SWEP.HoldType = "shotgun"

-- 第一人称模型（格洛克骨架，隐藏后由自定义元素拼装）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_glock18.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = false -- 不显示第一人称模型（用自定义元素）
SWEP.ShowWorldModel = false -- 不显示世界模型
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.CSMuzzleFlashes = false -- 不使用 CS 样式枪口闪光

SWEP.Primary.Sound = Sound("weapons/crossbow/fire1.wav") -- 开火音效
SWEP.Primary.ClipSize = 3 -- 弹匣容量（3 支弩箭）
SWEP.Primary.Automatic = true -- 按住可连续射击
SWEP.Primary.Ammo = "XBowBolt" -- 弹药类型：弩箭
SWEP.Primary.Delay = 0.75 -- 单次扣扳机之间的间隔
SWEP.Primary.DefaultClip = 15 -- 默认备弹数
SWEP.Primary.Damage = 74 -- 单支弩箭伤害
SWEP.Primary.BurstShots = 3 -- 每次扣扳机连射 3 支

SWEP.ConeMax = 2.25 -- 最大扩散
SWEP.ConeMin = 2 -- 最小扩散

SWEP.Recoil = 1 -- 后坐力

SWEP.ReloadSpeed = 0.4 -- 换弹速度倍率

SWEP.WalkSpeed = SPEED_SLOW -- 手持时移动速度（较慢）

SWEP.Tier = 4 -- 武器等级（4 级武器）

-- 附加武器修正：换弹速度 +0.04
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.04)

-- ==== PrimaryAttack - 左键：开始一轮三连射 ====
-- 记录剩余连射次数与下一发射击时间，由 Think 逐发执行
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self:GetFireDelay()) -- 设置整轮连射的冷却
	self:EmitFireSound() -- 播放第一发开火音效

	self:SetNextShot(CurTime()) -- 第一发立即发射
	self:SetShotsLeft(self.Primary.BurstShots) -- 设置剩余连射次数

	self.IdleAnimation = CurTime() + self:SequenceDuration() -- 延迟待机动画
end

-- ==== Think - 思考帧：逐发发射剩余弩箭 ====
function SWEP:Think()
	BaseClass.Think(self)

	local shotsleft = self:GetShotsLeft()
	-- 还有剩余箭且到达下一次发射时间时，发射一发
	if shotsleft > 0 and CurTime() >= self:GetNextShot() then
		self:SetShotsLeft(shotsleft - 1) -- 剩余次数减一
		self:SetNextShot(CurTime() + self:GetFireDelay()/6) -- 下一发间隔更短（连射节奏）

		-- 弹匣有箭且不在换弹中才发射
		if self:Clip1() > 0 and self:GetReloadFinish() == 0 then
			self:EmitFireSound() -- 开火音效
			self:TakeAmmo() -- 消耗弩箭
			self:ShootBullets(self.Primary.Damage, self.Primary.NumShots, self:GetCone()) -- 发射弩箭投射物

			self.IdleAnimation = CurTime() + self:SequenceDuration() -- 延迟待机动画
		else
			self:SetShotsLeft(0) -- 无法发射则中断连射
		end
	end
end

-- ==== SetNextShot - 设置下一次发射时间 ====
-- 写入数据表（DTFloat 5）同步到客户端
function SWEP:SetNextShot(nextshot)
	self:SetDTFloat(5, nextshot)
end

-- ==== GetNextShot - 读取下一次发射时间 ====
function SWEP:GetNextShot()
	return self:GetDTFloat(5)
end

-- ==== SetShotsLeft - 设置剩余连射次数 ====
-- 写入数据表（DTInt 1）同步到客户端
function SWEP:SetShotsLeft(shotsleft)
	self:SetDTInt(1, shotsleft)
end

-- ==== GetShotsLeft - 读取剩余连射次数 ====
function SWEP:GetShotsLeft()
	return self:GetDTInt(1)
end

-- ==== SendReloadAnimation - 播放换弹动画 ====
-- 换弹时播放拔出动画（表现重新装箭）
function SWEP:SendReloadAnimation()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== EmitReloadSound - 播放换弹音效 ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then -- 仅首次预测时播放，避免重复
		self:EmitSound("weapons/crossbow/reload1.wav", 70, 110)
	end
end

-- ==== EmitReloadFinishSound - 播放换弹完成音效 ====
function SWEP:EmitReloadFinishSound()
	if IsFirstTimePredicted() then -- 仅首次预测时播放，避免重复
		self:EmitSound("weapons/galil/galil_boltpull.wav", 70, 110)
	end
end

-- ==== EmitFireSound - 播放开火音效 ====
-- 发射声 + 弩箭穿透声两个音效叠加
function SWEP:EmitFireSound()
	self:EmitSound("weapons/crossbow/fire1.wav", 70, 120, 0.7)
	self:EmitSound("weapons/crossbow/bolt_skewer1.wav", 70, 193, 0.7, CHAN_AUTO)
end
