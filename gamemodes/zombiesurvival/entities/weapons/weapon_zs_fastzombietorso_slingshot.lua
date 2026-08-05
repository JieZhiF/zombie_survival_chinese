-- ============================================================================
-- weapon_zs_fastzombietorso_slingshot.lua - 快速僵尸躯干弹弓武器
-- 负责：僵尸专用武器，左键挥击攻击，飞行扑击（Pounce）时碰撞造成伤害并减速玩家；
--       扑击命中后停止扑击，对玩家施加减速和腿部伤害
-- ============================================================================
AddCSLuaFile()

-- 继承僵尸武器基类
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_fastzombietorso_slingshot")

-- 第一人称视角模型（快速僵尸手臂）
SWEP.ViewModel = Model("models/weapons/v_fza.mdl")

-- 近战攻击参数：延迟、伤害、范围、挥动动画速度
SWEP.MeleeDelay = 0.25
SWEP.MeleeDamage = 20
SWEP.MeleeReach = 40
SWEP.SwingAnimSpeed = 2.4

-- 扑击攻击参数：伤害、对玩家伤害倍率、范围、判定大小
SWEP.PounceDamage = 20
SWEP.PounceDamageVsPlayerMul = 0.75
SWEP.PounceReach = 26
SWEP.PounceSize = 12

-- ==== Think - 每帧逻辑（扑击状态处理） ====
function SWEP:Think()
	-- 调用基类 Think 逻辑
	self.BaseClass.Think(self)

	local curtime = CurTime()
	local owner = self:GetOwner()

	-- 跳跃恢复计时：扑击结束后延迟恢复跳跃能力
	if self.NextAllowJump and self.NextAllowJump <= curtime then
		self.NextAllowJump = nil

		-- 恢复持有者跳跃能力
		owner:ResetJumpPower()
	end

	-- 扑击状态处理
	if self:GetPouncing() then
		-- 落地或入水时停止扑击
		if owner:IsOnGround() or owner:WaterLevel() >= 2 then
			self:StopPounce()
		else
			-- 飞行中：沿瞄准方向进行碰撞检测
			local dir = owner:GetAimVector()
			-- 限制上下方向角度
			dir.z = math.Clamp(dir.z, -0.5, 0.9)
			dir:Normalize()

			-- 执行补偿近战射线检测（检测扑击命中目标）
			local traces = owner:CompensatedZombieMeleeTrace(self.PounceReach, self.PounceSize, owner:WorldSpaceCenter(), dir)
			-- 根据命中玩家数量计算伤害
			local damage = self:GetDamage(self:GetTracesNumPlayers(traces), self.PounceDamage)

			local hit = false
			for _, trace in ipairs(traces) do
				-- 跳过未命中的射线
				if not trace.Hit then continue end

				if trace.HitWorld then
					-- 命中世界：仅当法线朝上不够陡峭时算命中（撞墙不算）
					if trace.HitNormal.z < 0.8 then
						hit = true
						self:MeleeHitWorld(trace)
					end
				else
					-- 命中实体：造成扑击伤害
					local ent = trace.Entity
					if ent and ent:IsValid() then
						hit = true
						-- 对玩家使用0.75倍率，对其他实体使用扑击弱点倍率或1
						self:MeleeHit(ent, trace, damage * (ent:IsPlayer() and self.PounceDamageVsPlayerMul or ent.PounceWeakness or 1), ent:IsPlayer() and 1 or 10)
						-- 命中玩家时施加减速和腿部伤害
						if ent:IsPlayer() then
							ent:GiveStatus("slow", 5)
							ent:AddLegDamage(24)
						end
					end
				end
			end

			-- 服务器端播放扑击命中音效
			if SERVER and hit then
				owner:EmitSound("physics/flesh/flesh_strider_impact_bullet1.wav")
				owner:EmitSound("npc/fast_zombie/wake1.wav")
			end

			-- 命中后停止扑击并设置冷却
			if hit then
				self:StopPounce()
				self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
			end
		end
	end

	-- 设置下一帧 Think
	self:NextThink(curtime)
	return true
end

-- ==== PrimaryAttack - 左键攻击（开始挥击） ====
function SWEP:PrimaryAttack()
	-- 冷却中或正在扑击时禁止攻击
	if CurTime() < self:GetNextPrimaryFire() or self:IsPouncing() then return end

	local owner = self:GetOwner()
	-- 获取持有者近战速度倍率
	local armdelay = owner:GetMeleeSpeedMul()

	-- 设置主攻击和副攻击冷却
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
	self:SetNextSecondaryFire(self:GetNextPrimaryFire() + 0.5)

	-- 开始挥击动画
	self:StartSwinging()
end

-- ==== Move - 移动回调（扑击时锁定移动速度为0） ====
function SWEP:Move(mv)
	if self:IsPouncing() then
		-- 扑击飞行中禁止移动
		mv:SetMaxSpeed(0)
		mv:SetMaxClientSpeed(0)
	end
end

-- ==== StopPounce - 停止扑击状态 ====
function SWEP:StopPounce()
	-- 未在扑击状态则跳过
	if not self:IsPouncing() then return end

	-- 关闭扑击状态
	self:SetPouncing(false)
	-- 清除视角角度锁定
	self.m_ViewAngles = nil
	-- 设置跳跃恢复延迟（0.25秒后恢复跳跃）
	self.NextAllowJump = CurTime() + 0.25
	-- 设置短冷却
	self:SetNextPrimaryFire(CurTime() + 0.1)
	-- 立即恢复跳跃能力
	self:GetOwner():ResetJumpPower()
end


-- ==== PlayHitSound - 播放命中音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("NPC_FastZombie.AttackHit", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 播放挥空音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("NPC_FastZombie.AttackMiss", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 播放攻击音效（扑击嘶吼） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/leap1.wav", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayIdleSound - 播放待机音效 ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("NPC_FastZombie.AlertFar")
end

-- ==== PlayAlertSound - 播放警觉音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("NPC_FastZombie.Frenzy")
end

-- ==== Reload - 换弹键映射为副攻击 ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 开始呻吟（空实现，快速僵尸不呻吟） ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 停止呻吟（空实现） ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 是否正在呻吟（始终返回false） ====
function SWEP:IsMoaning()
	return false
end

-- ==== SetPouncing - 设置扑击状态（网络同步） ====
function SWEP:SetPouncing(leaping)
	self:SetDTBool(3, leaping)
end

-- ==== GetPouncing - 获取扑击状态 ====
function SWEP:GetPouncing()
	return self:GetDTBool(3)
end
-- 别名：IsPouncing 等同于 GetPouncing
SWEP.IsPouncing = SWEP.GetPouncing

if SERVER then

-- ==== Deploy - 武器部署（创建环境音效） ====
function SWEP:Deploy()
	-- 为持有者创建快速僵尸环境音效
	self:GetOwner():CreateAmbience("fastzombieambience")

	-- 调用基类部署逻辑
	return self.BaseClass.Deploy(self)
end

end

-- 以下为客户端渲染代码
if not CLIENT then return end

-- 僵尸皮肤材质
local matSkin = Material("models/barnacle/barnacle_sheet")

-- ==== PreDrawViewModel - 绘制视角模型前设置材质覆盖 ====
function SWEP:PreDrawViewModel(vm)
	-- 使用藤壶皮肤材质覆盖原始模型
	render.ModelMaterialOverride(matSkin)
	-- 设置颜色调制（偏红暗色调）
	render.SetColorModulation(0.64, 0.37, 0.39)
end

-- ==== ViewModelDrawn - 视角模型绘制后恢复材质 ====
function SWEP:ViewModelDrawn()
	-- 清除材质覆盖
	render.ModelMaterialOverride()
	-- 恢复正常颜色调制
	render.SetColorModulation(1, 1, 1)
end
