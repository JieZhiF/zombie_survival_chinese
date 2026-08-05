-- ============================================================================
-- weapon_zs_extinctioncrab/shared.lua - 灭绝螃蟹（僵尸近战武器）
-- 负责：定义灭绝螃蟹的扑击/爪击攻击机制与跨端共享状态
-- ============================================================================
-- 仅僵尸可以使用
SWEP.ZombieOnly = true
-- 属于近战武器
SWEP.IsMelee = true

-- 视图模型与第三人称模型（借用撬棍模型）
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

-- 主攻击（扑击）：无限弹药、全自动
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
-- 扑击技能冷却时间
SWEP.Primary.Delay = 0.4

-- 副攻击（爪击）：无限弹药、全自动
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0.22
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo	= "none"

-- 无命中时的恢复时间与命中后的恢复时间
SWEP.NoHitRecovery = 0.75
SWEP.HitRecovery = 1

-- 攻击动画总时长与攻击生效的时间点
SWEP.AttackTime = 1.875
SWEP.AttackProcessTime = 1.35

-- 通过 DT 变量将攻击开始/生效时间同步到客户端
AccessorFuncDT(SWEP, "AttackStartTime", "Float", 0)
AccessorFuncDT(SWEP, "AttackProcessTime", "Float", 1)

-- 扑击开始时间（本地记录，用于扑击初段的上升）
SWEP.PoundAttackStart = 0

-- ==== Initialize - 初始化：隐藏视图模型与第三人称模型 ====
function SWEP:Initialize()
	self:HideViewAndWorldModel()
end

-- ==== Think - 每帧逻辑：处理攻击生效计时与扑击落地判定 ====
function SWEP:Think()
	local time = CurTime()
	local owner = self:GetOwner()

	-- 到达攻击生效时间点：服务器端抛出碎块（对目标造成伤害）
	if self:GetAttackProcessTime() > 0 and time >= self:GetAttackProcessTime() then
		self:SetAttackProcessTime(0)

		if SERVER then
			self:ThrowGibs()
		end
	end

	-- 攻击动画结束后清除攻击状态
	if self:IsAttacking() and time > self:GetAttackEndTime() then
		self:SetAttackStartTime(0)
		self:SetAttackProcessTime(0)
	end

	-- 扑击状态：检测入水或落地以结束扑击
	if self:IsPouncing() then
		local delay = owner:GetMeleeSpeedMul()
		-- 进入水中：取消扑击并附加额外冷却
		if owner:WaterLevel() >= 2 then
			self:SetPouncing(false)
			self:SetNextPrimaryFire(time + 0.5 * delay)
		-- 落回地面：结束扑击并执行落地践踏攻击
		elseif owner:OnGround() and owner:IsOnGround() then
			self:SetPouncing(false)
			self:SetNextPrimaryFire(time + 0.4 * delay)

			if SERVER then
				self:PoundAttackProcess()
			end
		end
	end

	-- 注册下一帧继续调用 Think
	self:NextThink(time)
	return true
end

-- ==== PrimaryAttack - 主攻击：向前腾空扑击 ====
function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	-- 扑击中/冷却中/不在地面/攻击中时均不允许扑击
	if self:IsPouncing() or CurTime() < self:GetNextPrimaryFire() or not owner:IsOnGround() or self:IsAttacking() then return end

	-- 记录扑击开始时间
	self.PoundAttackStart = CurTime()

	-- 扑击方向取瞄准方向，并保证足够的上扬分量避免贴地飞行
	local vel = owner:GetAimVector()
	vel.z = math.max(0.45, vel.z)
	vel:Normalize()

	-- 脱离地面并施加扑击初速度
	owner:SetGroundEntity(NULL)
	owner:SetVelocity(vel * 250)
	owner:DoAnimationEvent(ACT_RANGE_ATTACK1)

	-- 服务器端播放扑击音效
	if SERVER then
		self:EmitAttackSound()
	end

	-- 记录扑击开始时的视角角度
	self.m_ViewAngles = owner:EyeAngles()

	self:SetPouncing(true)
end

-- ==== SecondaryAttack - 副攻击：原地爪击 ====
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	-- 攻击中/扑击中/不在地面时无法发动爪击
	if self:IsAttacking() or self:IsPouncing() or not owner:IsOnGround() then return end

	-- 记录攻击开始时间与生效时间
	self:SetAttackStartTime(CurTime())
	self:SetAttackProcessTime(CurTime() + self.AttackProcessTime)

	-- 服务器端播放攻击音效
	if SERVER then
		self:EmitAttackSound()
	end
end

-- ==== Reload - 换弹键：发出空闲叫声（探测目标用） ====
function SWEP:Reload()
	-- 受副攻击冷却限制
	if CurTime() < self:GetNextSecondaryFire() then return end
	self:SetNextSecondaryFire(CurTime() + 2)

	if SERVER then
		self:EmitIdleSound()
	end
end

-- ==== Move - 移动修正：扑击时加速，爪击时减速 ====
function SWEP:Move(mv)
	-- 扑击期间：前 0.1 秒强制向上加速，之后提升至 5 倍移速
	if self:IsPouncing() then
		if CurTime() < self.PoundAttackStart + 0.1 then
			local vel = mv:GetVelocity()
			vel.z = 350
			self:GetOwner():SetGroundEntity(NULL)
			mv:SetVelocity(vel)
		end

		mv:SetMaxSpeed(mv:GetMaxSpeed() * 5)
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 5)
		return true
	end

	-- 爪击动画期间几乎定身
	if self:IsAttacking() then
		mv:SetMaxSpeed(16)
		mv:SetMaxClientSpeed(16)
		return true
	end
end

-- ==== EmitIdleSound - 根据前方是否探测到玩家播放不同的叫声 ====
function SWEP:EmitIdleSound()
	-- 补偿近战追踪：检测前方 4096 单位内是否有玩家
	local ent = self:GetOwner():CompensatedMeleeTrace(4096, 24).Entity
	if ent:IsValidPlayer() then
		self:GetOwner():EmitSound("npc/headcrab/idle"..math.random(3)..".wav", 75, 60)
	else
		self:GetOwner():EmitSound("npc/headcrab/alert1.wav", 75, 60)
	end
end

-- ==== EmitAttackSound - 播放攻击吼叫声（随机音调） ====
function SWEP:EmitAttackSound()
	self:GetOwner():EmitSound("npc/ichthyosaur/attack_growl"..math.random(3)..".wav", 70, math.random(130, 160))
end

-- ==== IsAttacking - 查询是否处于攻击动画中 ====
function SWEP:IsAttacking()
	return self:GetAttackStartTime() > 0
end

-- ==== GetAttackEndTime - 计算攻击动画的结束时间 ====
function SWEP:GetAttackEndTime()
	return self:GetAttackStartTime() + self.AttackTime
end

-- ==== SetPouncing - 设置扑击状态（结束时清除视角记录） ====
function SWEP:SetPouncing(pouncing)
	if not pouncing then
		self.m_ViewAngles = nil
	end

	self:SetDTBool(1, pouncing)
end

-- ==== IsPouncing - 查询是否处于扑击状态 ====
function SWEP:IsPouncing()
	return self:GetDTBool(1)
end
-- 兼容别名：GetPouncing 等价于 IsPouncing
SWEP.GetPouncing = SWEP.IsPouncing
