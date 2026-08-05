-- ============================================================================
-- weapon_zs_lacerator_charging.lua - 撕裂者（Lacerator）僵尸 · 冲锋形态
-- 负责：定义"蓄力冲锋"技能——右键蓄力后高速冲锋，沿途造成范围伤害、
--       击飞/击倒目标；普通近战附带流血状态；客户端视模型呈红色狂暴色调
-- ============================================================================
AddCSLuaFile()

-- 记录基底类（weapon_zs_zombie），供 BaseClass 调用
DEFINE_BASECLASS("weapon_zs_zombie")

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_lacerator_charging")

-- 视模型为僵尸手臂
SWEP.ViewModel = Model("models/weapons/v_pza.mdl")

-- 普通近战间隔（秒）
SWEP.MeleeDelay = 0.8
-- 普通近战单次伤害
SWEP.MeleeDamage = 23
-- 近战命中的流血总伤害
SWEP.BleedDamage = 10
-- 近战对道具的伤害（普通状态下）
SWEP.MeleeDamageVsProps = 23
-- 主攻击间隔（秒）
SWEP.Primary.Delay = 1.5

-- 挥击动画速度倍率
SWEP.SwingAnimSpeed = 0.6

-- 冲锋碰撞伤害（满速时为基准）
SWEP.ChargeDamage = 30
-- 冲锋对人玩家的伤害倍率
SWEP.ChargeDamageVsPlayerMul = 0.8333
-- 冲锋碰撞判定的前伸距离
SWEP.ChargeReach = 26
-- 冲锋碰撞判定盒大小
SWEP.ChargeSize = 12
-- 右键后到正式启动冲锋的蓄力前摇（秒）
SWEP.ChargeStartDelay = 0.35
-- 两次冲锋之间的冷却（秒）
SWEP.ChargeDelay = 2
-- 冲锋结束后的硬直恢复时间（秒）
SWEP.ChargeRecovery = 0.75
-- 冲锋最长持续时间（秒）
SWEP.ChargeTime = 2.5
-- 冲锋加速到全速所需时间（秒）
SWEP.ChargeAccel = 0.5
-- 临界冲锋命中时的击倒状态时长（秒）
SWEP.ChargeKnockdown = 1.75

-- 右键为单次触发（非按住连发）
SWEP.Secondary.Automatic = false

-- 下次允许发起冲锋的时间戳
SWEP.NextAllowCharge = 0
-- ==== Think - 每帧逻辑：冲锋中的碰撞结算、蓄力到点启动、状态清理 ====
function SWEP:Think()
	BaseClass.Think(self)

	local curtime = CurTime()
	local owner = self:GetOwner()

	-- 冲锋结束的缓冲期过后恢复跳跃能力
	if self.NextAllowJump and self.NextAllowJump <= curtime then
		self.NextAllowJump = nil

		owner:ResetJumpPower()
	end

	if self:IsCharging() then
		-- 入水过深（WaterLevel>=2）或冲锋超时：强制停止
		if owner:WaterLevel() >= 2 or CurTime() > self:GetChargeStart() + self.ChargeTime  then
			self:StopCharge()
		elseif IsFirstTimePredicted() then
			-- 沿当前移动方向做冲锋碰撞判定
			local dir = owner:GetVelocity()
			dir:Normalize()

			-- 冲锋伤害随速度与蓄力进度缩放（速度上限约 440/s，取与蓄力的较小值）
			local chargemul = math.min(self:GetCharge(), owner:GetVelocity():LengthSqr() / 193600)
			local traces = owner:CompensatedZombieMeleeTrace(self.ChargeReach, self.ChargeSize, owner:WorldSpaceCenter(), dir)
			local damage = self:GetDamage(self:GetTracesNumPlayers(traces), self.ChargeDamage * chargemul)

			local hit = false
			for _, trace in ipairs(traces) do
				if not trace.Hit then continue end

				if trace.HitWorld then
					-- 撞墙（法线较平的墙面）：命中并停止冲锋
					if trace.HitNormal.z < 0.8 then
						hit = true
						self:MeleeHitWorld(trace)
					end
				else
					local ent = trace.Entity
					-- 撞到有效实体（非弹体）：结算冲锋伤害
					if ent and ent:IsValid() and not ent:IsProjectile() then
						hit = true
						-- 玩家按冲锋玩家倍率、道具按扑击弱点；临界冲锋对非玩家翻倍
						self:MeleeHit(ent, trace, damage * (ent:IsPlayer() and self.ChargeDamageVsPlayerMul or ent.PounceWeakness or 1) * (self:IsChargeCritical() and not ent:IsPlayer() and 2 or 1), 1)
						if ent:IsPlayer() then
							-- 被撞玩家沿冲锋方向击飞
							ent:ThrowFromPositionSetZ(trace.StartPos, 120 * chargemul + owner:GetVelocity():Length() * 0.5)
							-- 临界冲锋且有击倒冷却空档：附加击倒状态
							if CurTime() >= (ent.NextKnockdown or 0) and self:IsChargeCritical() then
								ent:GiveStatus("knockdown", self.ChargeKnockdown * chargemul)
								ent.NextKnockdown = CurTime() + 4 * chargemul
							end
						end
					end
				end
			end

			-- 首次进入临界冲锋：播放临界警示音
			if not self.CriticalCharge and self:IsChargeCritical() then
				self:PlayCriticalChargeStartSound()
				self.CriticalCharge = true
			end

			-- 撞到东西：播放命中音并停止冲锋
			if hit then
				self:PlayChargeHitSound()
				self:StopCharge()
			end
		end
	elseif self:GetChargeStart() > 0 and CurTime() > self:GetChargeStart() then
		-- 蓄力前摇结束且还在地面：正式启动冲锋
		self:StartCharge()
	elseif self.m_ViewAngles then
		-- 未进入冲锋则清除视野角度记录
		self.m_ViewAngles = nil
	end

	-- 每帧持续调度 Think
	self:NextThink(curtime)
	return true
end

-- ==== PlayChargeHitSound - 冲锋命中音效 ====
function SWEP:PlayChargeHitSound()
	self:EmitSound("npc/antlion_guard/shove1.wav")
	self:EmitSound("npc/fast_zombie/wake1.wav", 75, math.random(75, 80), nil, CHAN_AUTO)
end

-- ==== PlayCriticalChargeStartSound - 进入临界冲锋的警示音 ====
function SWEP:PlayCriticalChargeStartSound()
	self:EmitSound("npc/zombie_poison/pz_throw3.wav", 75, math.random(85, 90), nil, CHAN_AUTO)
end

-- ==== Move - 每帧移动修正：蓄力中定身，冲锋中高速突进 ====
function SWEP:Move(mv)
	local charge = self:GetCharge()

	-- 蓄力前摇阶段（已预约冲锋但未启动）：原地定身
	if self:GetChargeStart() > 0 and charge <= 0 then
		mv:SetMaxSpeed(0)
		mv:SetMaxClientSpeed(0)
	elseif charge > 0 then
		-- 冲锋中：近乎全速前进，侧向移动大幅削弱
		mv:SetForwardSpeed(10000)
		mv:SetSideSpeed(mv:GetSideSpeed() * 0.1)

		-- 速度倍率随蓄力进度上升，临界冲锋再 +50%
		local mul = 1 + charge * 1 + (self:IsChargeCritical() and 0.5 or 0)
		mv:SetMaxSpeed(mv:GetMaxSpeed() * mul)
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * mul)
	end
end

-- ==== PrimaryAttack - 主攻击：冲锋/蓄力期间禁止普攻 ====
function SWEP:PrimaryAttack()
	-- 冲锋中或蓄力中不允许普攻
	if self:IsCharging() or self:GetChargeStart() > 0 then return end

	BaseClass.PrimaryAttack(self)
end

-- ==== MeleeHit - 近战命中：普通状态下对道具使用独立伤害值 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	-- 非冲锋状态命中非玩家实体：改用对道具伤害
	if not ent:IsPlayer() and not (self:IsCharging() or self:GetChargeStart() > 0) then
		damage = self.MeleeDamageVsProps
	end

	BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== ApplyMeleeDamage - 伤害结算：普通近战命中玩家附加流血状态 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 仅服务端、仅玩家、仅普通近战（冲锋有独立结算）时附加流血
	if SERVER and ent:IsPlayer() and not (self:IsCharging() or self:GetChargeStart() > 0) then
		local bleed = ent:GiveStatus("bleed")
		if bleed and bleed:IsValid() then
			bleed:AddDamage(self.BleedDamage)
			bleed.Damager = self:GetOwner()
		end
	end

	BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end

-- ==== SecondaryAttack - 右键：在地面上预约蓄力冲锋 ====
function SWEP:SecondaryAttack()
	-- 冲锋/蓄力中不可再次触发
	if self:IsCharging() or self:GetChargeStart() > 0 then return end

	-- 仅限地面，且主/副攻击与冲锋冷却均就绪
	if self:GetOwner():IsOnGround() then
		if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or CurTime() < self.NextAllowCharge then return end

		-- 锁定主攻击，预约 ChargeStartDelay 后启动冲锋
		self:SetNextPrimaryFire(math.huge)
		self:SetChargeStart(CurTime() + self.ChargeStartDelay)

		-- 蓄力期间禁用跳跃，首次预测时播放蓄力音
		self:GetOwner():ResetJumpPower()
		if IsFirstTimePredicted() then
			self:PlayChargeStartSound()
		end
	end
end

-- ==== StartCharge - 正式启动冲锋（仅限地面；空中则取消并进入冷却） ====
function SWEP:StartCharge()
	if self:IsCharging() then return end

	local owner = self:GetOwner()
	if owner:IsOnGround() then
		-- 进入冲锋状态，锁定视野角度，播放冲锋音，播放跳跃动画
		self:SetCharging(true)

		self.m_ViewAngles = owner:EyeAngles()

		if IsFirstTimePredicted() then
			self:PlayChargeSound()
		end
		owner:SetAnimation(PLAYER_JUMP)
	else
		-- 不在地面：取消冲锋预约，进入完整冷却并恢复跳跃
		self:SetNextSecondaryFire(CurTime())
		self.m_ViewAngles = nil
		self.NextAllowJump = CurTime()
		self.NextAllowCharge = CurTime() + self.ChargeDelay
		self:SetNextPrimaryFire(CurTime() + self.ChargeRecovery)
		self:GetOwner():ResetJumpPower()
	end
end

-- ==== PlayChargeSound - 冲锋进行中的吼叫音 ====
function SWEP:PlayChargeSound()
	self:EmitSound("npc/ichthyosaur/attack_growl1.wav", 75, math.random(100,116), nil, CHAN_AUTO)
end

-- ==== PlayChargeStartSound - 蓄力开始音 ====
function SWEP:PlayChargeStartSound()
	self:EmitSound("npc/fast_zombie/leap1.wav", 75, math.random(75,80), nil, CHAN_AUTO)
end

-- ==== StopCharge - 停止冲锋：清理状态、进入冷却与恢复期 ====
function SWEP:StopCharge()
	if not self:IsCharging() then return end

	-- 清除冲锋状态
	self:SetChargeStart(0)
	self:SetCharging(false)
	self:SetNextSecondaryFire(CurTime())
	self.m_ViewAngles = nil
	-- 短暂缓冲后恢复跳跃，随后进入冲锋冷却与主攻击恢复期
	self.NextAllowJump = CurTime() + 0.25
	self.NextAllowCharge = CurTime() + self.ChargeDelay
	self:SetNextPrimaryFire(CurTime() + self.ChargeRecovery)
	self:GetOwner():ResetJumpPower()
	-- 清除临界标记
	self.CriticalCharge = nil
end

-- ==== Reload - 换弹键触发：使用基底右键（扑击）技能 ====
function SWEP:Reload()
	BaseClass.SecondaryAttack(self)
end

-- ==== OnRemove - 武器移除时恢复所有者跳跃能力 ====
function SWEP:OnRemove()
	self.Removing = true

	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:ResetJumpPower()
	end

	BaseClass.OnRemove(self)
end

-- ==== Holster - 收枪时恢复所有者跳跃能力 ====
function SWEP:Holster()
	local owner = self:GetOwner()
	if owner and owner:IsValid() then
		owner:ResetJumpPower()
	end

	BaseClass.Holster(self)
end

-- ==== ResetJumpPower - 跳跃限制：蓄力/冲锋期间禁止跳跃 ====
function SWEP:ResetJumpPower(power)
	if self.Removing then return end

	-- 跳跃缓冲期内或冲锋/蓄力中：拒绝恢复跳跃
	if self.NextAllowJump and CurTime() < self.NextAllowJump or self:IsCharging() or self:GetChargeStart() > 0 then
		return 1
	end
end

-- ==== PlayAttackSound - 普攻音效（蚂蚁狮守卫怒吼） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav")
end

-- ==== PlayAlertSound - 警戒音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/zombie/zombie_alert"..math.random(1,3)..".wav", 75, math.random(80,85))
end
-- 闲置吼叫复用警戒音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound

-- ==== SetChargeStart - 写入蓄力开始时间（DT 槽 1） ====
function SWEP:SetChargeStart(time)
	self:SetDTFloat(1, time)
end

-- ==== GetChargeStart - 读取蓄力开始时间（DT 槽 1） ====
function SWEP:GetChargeStart()
	return self:GetDTFloat(1)
end

-- ==== GetCharge - 计算冲锋蓄力进度（0~1，按 ChargeAccel 加速曲线） ====
function SWEP:GetCharge()
	if self:GetChargeStart() == 0 then return 0 end

	return math.Clamp((CurTime() - self:GetChargeStart()) / self.ChargeAccel, 0, 1)
end

-- ==== IsChargeCritical - 是否处于临界冲锋（冲锋时间超过 60% 后） ====
function SWEP:IsChargeCritical()
	if not self:IsCharging() then return false end

	return CurTime() >= self:GetChargeStart() + self.ChargeTime * 0.6
end

-- ==== SetCharging - 写入冲锋状态（DT 槽 2） ====
function SWEP:SetCharging(charging)
	self:SetDTBool(2, charging)
end

-- ==== GetCharging - 读取冲锋状态（DT 槽 2） ====
function SWEP:GetCharging()
	return self:GetDTBool(2)
end
-- IsCharging 为 GetCharging 的别名
SWEP.IsCharging = SWEP.GetCharging

-- 以下仅为客户端内容，服务器端到此结束
if not CLIENT then return end

-- 第一人称镜头 FOV
SWEP.ViewModelFOV = 48

-- ==== ViewModelDrawn - 视模型绘制后恢复正常颜色 ====
function SWEP:ViewModelDrawn()
	render.SetColorModulation(1, 1, 1)
end

-- ==== PreDrawViewModel - 绘制视模型前染成暗红色（狂暴外观） ====
function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(0.7, 0.17, 0)
end
