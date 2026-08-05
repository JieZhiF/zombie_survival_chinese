-- ============================================================================
-- shared.lua - 符印碎片武器共享定义
-- 负责：定义近战武器基础属性；实现左键"传送前奏"机制（1.5 秒后由符印状态
--       执行传送），并处理部署/收起/空闲动画切换与耗尽移除逻辑
-- ============================================================================
-- 武器显示名称（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_sigilfragment")
-- 武器描述（本地化文本）
SWEP.Description = ""..translate.Get("weapon_zs_sigilfragment_description")

-- 继承自近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称/第三人称模型（借用虫饵模型）
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"
-- 使用玩家手部模型
SWEP.UseHands = true

-- 持枪姿势（地面放置式）
SWEP.HoldType = "slam"

-- 持枪移动速度（快速）
SWEP.WalkSpeed = SPEED_FAST

-- 持有该武器时获得相应弹药
SWEP.AmmoIfHas = true

-- 主攻击：弹匣 1 发、半自动、消耗符印碎片弹药
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "sigilfragment"
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 1

-- 副攻击：弹匣 1 发、半自动、使用占位弹药（实际禁用）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "dummy"

-- 物理盒碰撞范围（小体积碎片）
SWEP.BoxPhysicsMin = Vector(-4, -4, -4)
SWEP.BoxPhysicsMax = Vector(4, 4, 4)

-- 传送状态与传送特效（由状态实体负责实际传送）
SWEP.TeleportStatus = "sigilteleport"
SWEP.TeleportEffect = "sigil_teleport"

-- ==== Initialize - 武器初始化 ====
-- 设置持枪姿势与部署速度；客户端额外初始化动画系统
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	GAMEMODE:DoChangeDeploySpeed(self)

	if CLIENT then
		self:Anim_Initialize()
	end
end

-- ==== CanPrimaryAttack - 检查左键攻击是否可用 ====
-- 手持道具、建造预览中或场上没有未被腐化的符印时禁止使用；弹药耗尽时触发空击冷却
function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or GAMEMODE:NumUncorruptedSigils() <= 0 then return false end

	-- 弹药耗尽：进入主攻击冷却并拒绝本次攻击
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== PrimaryAttack - 左键发动传送前奏 ====
-- 消耗弹药，播放挤压动画与蓄能音效，并在 1.5 秒后触发传送（服务端给玩家附加传送状态）
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	-- 传送后 3 秒冷却
	self:SetNextPrimaryFire(CurTime() + 3)

	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	if IsValid(vm) then
		-- 播放视图模型的挤压动画
		vm:SendViewModelMatchingSequence(vm:LookupSequence("squeeze") or 0)
	end
	owner:DoAttackEvent()

	-- 播放传送蓄能音效（高音调）
	self:EmitSound("ambient/levels/labs/teleport_preblast_suckin1.wav", 70, 140)

	-- 记录传送触发时间与清除闲置/部署动画状态
	self.Teleport = CurTime() + 1.5
	self.NextDeploy = nil
	self.NextIdle = nil

	if SERVER then
		-- 附加传送状态，由状态在 1.5 秒后执行实际传送（时长受玩家加成影响）
		local status = owner:GiveStatus(self.TeleportStatus)
		if status:IsValid() then
			status:SetFromSigil(self)
			status:SetEndTime(CurTime() + 1.5 * (owner.SigilTeleportTimeMul or 1))
		end
	end
end

-- ==== SecondaryAttack - 右键攻击（禁用占位） ====
function SWEP:SecondaryAttack()
end

-- ==== CanSecondaryAttack - 右键攻击始终不可用 ====
function SWEP:CanSecondaryAttack()
	return false
end

-- ==== Reload - 禁止手动换弹 ====
function SWEP:Reload()
	return false
end

-- ==== Deploy - 拔出武器 ====
-- 触发武器部署事件；弹药耗尽时播放投掷动画（示意将耗尽），否则播放部署动画
function SWEP:Deploy()
	GAMEMODE:WeaponDeployed(self:GetOwner(), self)

	if self:GetPrimaryAmmoCount() <= 0 then
		self:SendWeaponAnim(ACT_VM_THROW)
	else
		self:SendWeaponAnim(ACT_VM_DEPLOY)
	end

	self.NextIdle = CurTime() + 2

	return true
end

-- ==== Holster - 收起武器 ====
-- 清除传送/闲置/部署状态，客户端额外执行收起动画
function SWEP:Holster()
	self.NextDeploy = nil
	self.NextIdle = nil
	self.Teleport = nil

	if CLIENT then
		self:Anim_Holster()
	end

	return true
end

-- ==== Think - 每帧逻辑：处理传送/闲置/部署动画时机 ====
function SWEP:Think()
	-- 到达传送时刻：清除标记并安排后续闲置动画
	if self.Teleport and CurTime() >= self.Teleport then
		self.Teleport = nil
		self.NextIdle = CurTime() + 1
	elseif self.NextIdle and CurTime() >= self.NextIdle then
		-- 到达闲置时刻：播放闲置动画
		self.NextIdle = nil

		self:SendWeaponAnim(ACT_VM_IDLE)
	elseif self.NextDeploy and self.NextDeploy <= CurTime() then
		-- 到达部署时刻：有弹药播放拔枪动画，无弹药播放投掷动画并移除武器
		self.NextDeploy = nil

		if 0 < self:GetPrimaryAmmoCount() then
			self:SendWeaponAnim(ACT_VM_DRAW)
		else
			self:SendWeaponAnim(ACT_VM_THROW)
			if SERVER then
				-- 碎片耗尽后武器自动销毁
				self:Remove()
			end
		end
	end
end
