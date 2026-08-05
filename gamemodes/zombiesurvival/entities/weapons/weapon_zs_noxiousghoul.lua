-- ============================================================================
-- weapon_zs_noxiousghoul.lua - 剧毒食尸鬼（Noxious Ghoul）
-- 负责：近战伤害转化为毒性伤害并附加"虚弱"状态；右键向准星周围扇形喷吐
--       一排毒肉弹体（普毒/剧毒交替）；客户端视模型呈紫红色僵尸皮肤
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_noxiousghoul")

-- 继承通用僵尸近战武器基底
SWEP.Base = "weapon_zs_zombie"

-- 近战单次伤害（以毒伤结算）
SWEP.MeleeDamage = 32
-- 近战对道具的伤害
SWEP.MeleeDamageVsProps = 24
-- 近战击退力度倍率
SWEP.MeleeForceScale = 0.5
-- 攻击时对持枪者的减速倍率
SWEP.SlowDownScale = 0.25
-- 虚弱状态时长换算：每点伤害对应 10/32 秒（约 0.3125 秒）
SWEP.EnfeebleDurationMul = 10 / SWEP.MeleeDamage

-- ==== ApplyMeleeDamage - 伤害结算：转换为毒性伤害，命中玩家附加虚弱状态 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	-- 所有近战伤害均以毒性伤害结算（无视护甲等减免）
	ent:PoisonDamage(damage, self:GetOwner(), self, trace.HitPos)
	if SERVER and ent:IsPlayer() then
		-- 附加虚弱状态，时长随伤害缩放
		local gt = ent:GiveStatus("enfeeble", damage * self.EnfeebleDurationMul)
		if gt and gt:IsValid() then
			-- 记录虚弱来源
			gt.Applier = self:GetOwner()
		end
	end
end

-- ==== MeleeHit - 近战命中：命中非玩家实体时改用对道具伤害 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== Reload - 换弹键触发：使用基底右键（扑击）技能 ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== PlayAlertSound - 警戒音效 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/fast_zombie/fz_alert_close1.wav", 75, math.Rand(70, 80))
end
-- 闲置吼叫复用警戒音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound

-- ==== PlayAttackSound - 攻击音效（快速僵尸扑击） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
end

-- 喷吐的扇形散布模式（水平偏移角 + 垂直偏移角，从中心向两侧展开）
local PoisonPattern = {
	{-0.66, 0},
	{-0.33, 0},
	{0, 0},
	{0, 1},
	{0, -1},
	{0.33, 0},
	{0.66, 0},
}

-- ==== DoFleshThrow - 执行扇面喷吐：沿每个散布方向投出毒肉弹体 ====
local function DoFleshThrow(owner, self)
	local startpos = owner:GetShootPos()
	local aimang = owner:EyeAngles()
	local ang

	for k, spr in pairs(PoisonPattern) do
		if k == "BaseClass" then continue end

		-- 在瞄准方向上叠加水平/垂直散布角度
		ang = Angle(aimang.p, aimang.y, aimang.r)
		ang:RotateAroundAxis(ang:Up(), spr[1] * 12.5)
		ang:RotateAroundAxis(ang:Right(), spr[2] * 5)
		local heading = ang:Forward()

		-- 第 1/4/7 号投掷"剧毒肉块"，其余投掷"普毒肉块"
		local ent = ents.Create(k % 3 == 1 and "projectile_ghoulfleshno" or "projectile_poisonflesh")
		if ent:IsValid() then
			-- 在枪口前方生成并绑定所有者
			ent:SetPos(startpos + heading * 8)
			ent:SetOwner(owner)
			ent:Spawn()

			-- 沿散布方向抛出
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(heading * 400)
			end
		end
	end

	-- 血肉迸裂声
	owner:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.Rand(105, 115))
end


-- ==== SecondaryAttack - 右键技能：扇形喷吐毒肉（冷却 3 秒，0.7 秒后服务器端投掷） ====
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	-- 冷却未到或处于假死状态：不可使用
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or IsValid(owner.FeignDeath) then return end

	-- 进入 3 秒喷吐冷却
	self:SetNextSecondaryFire(CurTime() + 3)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 触发僵尸事件、播放扑击与血肉声、播放命中动画并记录闲置动画时间
	self:GetOwner():DoZombieEvent()
	self:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
	self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.Rand(85, 95))
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	if SERVER then
		-- 延迟 0.7 秒执行实际投掷（配合动画前摇）
		timer.Simple(0.7, function() DoFleshThrow(owner, self) end)
	end
end

-- 以下仅为客户端内容，服务器端到此结束
if not CLIENT then return end

-- ==== ViewModelDrawn - 视模型绘制后恢复默认材质与颜色 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
	render.SetColorModulation(1, 1, 1)
end

-- 僵尸手臂皮肤材质
local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet")
-- ==== PreDrawViewModel - 绘制视模型前覆盖为僵尸皮肤并染成紫红色 ====
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
	render.SetColorModulation(0.9, 0.55, 0.9)
end
