-- ============================================================================
-- weapon_zs_healingray/shared.lua - 治疗射线武器（共享定义与逻辑）
-- 负责：定义治疗射线的属性；实现"锁定并持续治疗队友"的核心机制
--       （追踪目标、消耗能量、播放光束特效）
-- ============================================================================
-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_healingray")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_healingray_description")

-- 继承武器母本
SWEP.Base = "weapon_zs_base"

-- 手持姿势：物理枪姿势
SWEP.HoldType = "physgun"

-- 第一人称模型（物理枪骨架）
SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.ShowViewModel = false -- 不显示第一人称模型（用自定义元素）
SWEP.ShowWorldModel = false -- 不显示世界模型
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.Primary.Delay = 0.1 -- 攻击间隔

SWEP.Primary.ClipSize = 30 -- 能量容量
SWEP.Primary.Automatic = true -- 按住左键持续治疗
SWEP.Primary.Ammo = "Battery" -- 弹药类型：能量电池
GAMEMODE:SetupDefaultClip(SWEP.Primary) -- 按游戏模式规则设置默认能量

SWEP.ConeMax = 0 -- 无扩散（射线精准命中）
SWEP.ConeMin = 0

SWEP.Tier = 4 -- 武器等级（4 级高级武器）
SWEP.MaxStock = 3 -- 商店最大库存量

SWEP.HealRange = 300 -- 治疗射程
SWEP.Heal = 3 -- 每次治疗脉冲恢复的生命值

SWEP.WalkSpeed = SPEED_SLOWER -- 手持时移动速度（较慢）
SWEP.FireAnimSpeed = 0.24 -- 开火动画播放速度

-- 附加武器修正：治疗射程 +100（每级强化 1 单位）
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_HEALRANGE, 100, 1)
-- 附加武器修正：治疗量 +0.3
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_HEALING, 0.3)

-- ==== Initialize - 武器初始化 ====
-- 调用母本初始化并创建持续充电音效
function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	self.ChargeSound = CreateSound(self, "items/medcharge4.wav") -- 治疗持续音效
end

-- ==== Holster - 武器收起时 ====
-- 停止充电音效后再收起
function SWEP:Holster()
	self.ChargeSound:Stop()

	return self.BaseClass.Holster(self)
end

-- ==== OnRemove - 武器被移除时 ====
-- 确保停止充电音效
function SWEP:OnRemove()
	self.ChargeSound:Stop()
end

-- ==== PrimaryAttack - 左键：锁定治疗目标 ====
-- 在治疗射程内沿视线追踪，找到第一个可治疗的活人并锁定他
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	local owner = self:GetOwner()

	-- 沿视线做可穿透的扫描，获取命中实体列表
	local trtbl = owner:CompensatedPenetratingMeleeTrace(self.HealRange, 2, nil, nil, true)
	local ent
	for _, tr in pairs(trtbl) do
		local test = tr.Entity
		-- 只接受"存活的人类"且"允许被治疗"的目标
		if test and test:IsValidLivingHuman() and gamemode.Call("PlayerCanBeHealed", test) then
			ent = test

			break
		end
	end

	-- 没有找到目标，或已经锁定了一个目标，则不做处理
	if not ent or self:GetDTEntity(10):IsValid() then return end

	self:SetDTEntity(10, ent) -- 锁定治疗目标
	self:SetNextPrimaryFire(CurTime() + 1) -- 锁定后 1 秒才能重新尝试
	self:EmitSound("items/medshot4.wav", 75, 80) -- 播放锁定音效
end

-- ==== CanPrimaryAttack - 判断是否可以开始治疗 ====
function SWEP:CanPrimaryAttack()
	-- 能量耗尽则不能治疗
	if self:GetPrimaryAmmoCount() <= 0 then
		return false
	end

	-- 持握物品、预览路障、或已在治疗中时禁止
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or self:GetDTEntity(10):IsValid() then return false end

	return self:GetNextPrimaryFire() <= CurTime() -- 冷却结束才允许
end

-- ==== Reload - 换弹（空实现） ====
-- 治疗射线不需要换弹
function SWEP:Reload()
end

-- ==== Think - 思考帧 ====
-- 每帧检查治疗射线状态
function SWEP:Think()
	self.BaseClass.Think(self)

	self:CheckHealRay()
end

-- ==== StopHealing - 停止治疗 ====
-- 清除锁定目标并进入短暂冷却，播放停止音效
function SWEP:StopHealing()
	self:SetDTEntity(10, NULL) -- 解除目标锁定
	self:SetNextPrimaryFire(CurTime() + 0.75) -- 冷却 0.75 秒
	self:EmitSound("items/medshotno1.wav", 75, 60) -- 播放治疗中断音效
	self.ChargeSound:Stop() -- 停止充电音效
end

-- ==== TakeAmmo - 消耗能量 ====
-- 每次治疗脉冲消耗 2 点能量
function SWEP:TakeAmmo()
	self:TakeCombinedPrimaryAmmo(2)
end

-- ==== CheckHealRay - 每帧检查并执行治疗 ====
function SWEP:CheckHealRay()
	local ent = self:GetDTEntity(10) -- 当前锁定的治疗目标
	local owner = self:GetOwner()

	-- 目标仍存活、允许治疗、玩家仍按住左键、距离在射程内、且有能量时持续治疗
	if ent:IsValidLivingHuman() and gamemode.Call("PlayerCanBeHealed", ent) and owner:KeyDown(IN_ATTACK) and
		ent:WorldSpaceCenter():DistToSqr(owner:WorldSpaceCenter()) <= self.HealRange * self.HealRange and self:GetCombinedPrimaryAmmo() > 0 then

		-- 按治疗脉冲间隔（0.36 秒）周期性地施加治疗
		if CurTime() > self:GetDTFloat(10) then
			owner:HealPlayer(ent, math.min(self:GetCombinedPrimaryAmmo(), self.Heal)) -- 治疗（不超过剩余能量）
			self:TakeAmmo() -- 消耗能量
			self:SetDTFloat(10, CurTime() + 0.36) -- 设置下一次脉冲时间
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- 播放开火动画

			-- 生成治疗光束特效数据
			local effectdata = EffectData()
				effectdata:SetOrigin(ent:WorldSpaceCenter()) -- 光束终点：目标中心
				effectdata:SetFlags(3)
				effectdata:SetEntity(self) -- 光束起点：武器
				effectdata:SetAttachment(1)
			util.Effect("tracer_healray", effectdata) -- 播放治疗光束特效
		end

		self.ChargeSound:PlayEx(1, 70) -- 持续播放充电音效
	elseif ent:IsValid() then -- 条件不再满足且还有目标时停止治疗
		self:StopHealing()
	end
end
