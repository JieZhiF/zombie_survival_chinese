-- ============================================================================
-- weapon_zs_gunturret/shared.lua - 机枪塔部署武器（共享端）
-- 负责：定义机枪塔武器属性（弹药/射速/部署）、弹药数量网络同步、开火限制与部署收起动画
-- ============================================================================

-- 第一人称持枪模型（仅占位，实际持枪时隐藏，见 Initialize 的 HideViewAndWorldModel）
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
-- 世界模型为地面机枪塔模型
SWEP.WorldModel = "models/Combine_turrets/Floor_turret.mdl"

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_gunturret")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_gunturret_description")

-- 弹药型道具武器：玩家已拥有时只补给弹药，不重复发放武器本体
SWEP.AmmoIfHas = true

-- 弹匣容量 1 发（弹药以 TurretAmmoType 弹药类型单独计算）
SWEP.Primary.ClipSize = 1
-- 初始弹匣 1 发
SWEP.Primary.DefaultClip = 1
-- 自动开火（占位，武器本身不射击，实际射击由部署的机枪塔完成）
SWEP.Primary.Automatic = true
-- 消耗 "thumper" 弹药类型（由机枪塔弹药箱补给）
SWEP.Primary.Ammo = "thumper"
-- 射击间隔 2 秒（占位值）
SWEP.Primary.Delay = 2
-- 伤害（占位值）
SWEP.Primary.Damage = 8.8

-- 禁用右键功能（-1 弹匣、无弹药、非自动）
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- 商店最大库存 5 个
SWEP.MaxStock = 5
-- 武器等级 2
SWEP.Tier = 2

-- 未持有弹药时的常规移动速度
SWEP.WalkSpeed = SPEED_NORMAL
-- 持有弹药时的移动速度（最慢，拖着机枪塔走，见 GetWalkSpeed）
SWEP.FullWalkSpeed = SPEED_SLOWEST

-- 放置时的幽灵预览状态实体
SWEP.GhostStatus = "ghost_gunturret"
-- 部署后生成的实体类（地面机枪塔）
SWEP.DeployClass = "prop_gunturret"
-- 频道标识：强化系统中将本武器关联到其部署实体类
SWEP.Channel = "turret"

-- 部署机枪塔使用的弹药类型
SWEP.TurretAmmoType = "smg1"
-- 机枪塔部署时的初始弹药量
SWEP.TurretAmmoStartAmount = 250
-- 机枪塔的弹道散布
SWEP.TurretSpread = 2

-- 部署时不需要游戏模式统一改变移动速度（由 GetWalkSpeed 自行控制）
SWEP.NoDeploySpeedChange = true
-- 允许武器强化
SWEP.AllowQualityWeapons = true

-- 附加武器强化修改器：机枪塔散布降低 0.4
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.4)

-- ==== Initialize - 武器初始化 ====
function SWEP:Initialize()
	-- 设置持枪姿势为"放置"姿势
	self:SetWeaponHoldType("slam")
	-- 按游戏模式规则更新部署类武器的移动速度
	GAMEMODE:DoChangeDeploySpeed(self)
	-- 隐藏第一人称与世界模型（实际显示为部署的机枪塔实体）
	self:HideViewAndWorldModel()

	-- 记录补给弹药类型（供弹药箱补给系统使用）
	self.ResupplyAmmoType = self.TurretAmmoType
end

-- ==== SetReplicatedAmmo - 将弹药数量写入网络数据表 ====
function SWEP:SetReplicatedAmmo(count)
	-- 同步到数据表索引 0，供客户端读取显示
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取网络同步的弹药数量 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 根据是否持有弹药返回移动速度 ====
function SWEP:GetWalkSpeed()
	-- 持有弹药时以最慢速度移动（拖着机枪塔），无弹药时不覆盖默认速度
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== SecondaryAttack - 禁用右键开火 ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 禁用换弹 ====
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 判定能否开火 ====
function SWEP:CanPrimaryAttack()
	-- 玩家手持其他物品或正在放置幽灵时禁止开火
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 无弹药时重置冷却并拒绝开火（防连续点击）
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Think - 每帧逻辑 ====
function SWEP:Think()
	-- 出枪动画结束后播放待机动画
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if SERVER then
		-- 服务器端：弹药数量变化时同步给客户端并重置移动速度
		local count = self:GetPrimaryAmmoCount()
		if count ~= self:GetReplicatedAmmo() then
			self:SetReplicatedAmmo(count)
			self:GetOwner():ResetSpeed()
		end
	end
end

-- ==== Deploy - 出枪 ====
function SWEP:Deploy()
	-- 通知游戏模式武器已部署
	gamemode.Call("WeaponDeployed", self:GetOwner(), self)

	-- 记录出枪动画时长，到时切换待机动画
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	return true
end

-- ==== Holster - 收枪 ====
function SWEP:Holster()
	return true
end

-- 预缓存机枪塔模型，避免首次部署时卡顿
util.PrecacheModel("models/Combine_turrets/Floor_turret.mdl")
