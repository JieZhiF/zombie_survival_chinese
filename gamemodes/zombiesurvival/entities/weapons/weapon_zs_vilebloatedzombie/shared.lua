-- ============================================================================
-- shared.lua - 污秽肿胀僵尸武器共享定义
-- 负责：定义僵尸近战属性（部分伤害转化为毒伤）；实现右键呕吐技能（蓄力后
--       连续喷射毒液）、以及攻击/闲置/警报音效播放
-- ============================================================================
-- 武器显示名称（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_vilebloatedzombie")

-- 继承自僵尸基础武器
SWEP.Base = "weapon_zs_zombie"

-- 近战伤害
SWEP.MeleeDamage = 32
-- 毒伤转化倍率（近战伤害的一半转化为毒伤）
SWEP.PoisonDmgMul = 0.5
-- 近战击退力度倍率
SWEP.MeleeForceScale = 1.25

-- 主攻击间隔（秒）
SWEP.Primary.Delay = 1.4

-- 呕吐喷射计时（下次喷射时间）与剩余喷射次数
SWEP.NextPuke = 0
SWEP.PukeLeft = 0

-- ==== ApplyMeleeDamage - 应用近战伤害 ====
-- 命中玩家时把一半伤害转化为毒伤，其余走父类常规近战伤害流程；非玩家目标全额近战伤害
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	if ent:IsPlayer() then
		ent:PoisonDamage(damage / 2, self:GetOwner(), self, trace.HitPos)
		self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage / 2)
	else
		self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
	end
end

-- ==== Reload - 换弹键触发呕吐技能 ====
-- 复用父类的右键攻击逻辑作为呕吐蓄力技能
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== PlayAlertSound - 警报音效（复用攻击音效） ====
function SWEP:PlayAlertSound()
	self:PlayAttackSound()
end

-- ==== PlayIdleSound - 闲置音效 ====
-- 播放随机藤壶舌头伸缩声，营造污秽感
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end

-- ==== PlayAttackSound - 攻击音效 ====
-- 服务端定时播放 4 连发鱼龙咆哮，音调逐次升高形成嘶吼感
function SWEP:PlayAttackSound()
	if SERVER then
		local owner = self:GetOwner()
		local sndname = "npc/ichthyosaur/attack_growl"..math.random(3)..".wav"
		for i = 1, 4 do
			timer.Simple(0.04 * i,
				function() if owner:IsValid() then owner:EmitSound(sndname, 75, 170 + i*8, 0.4, CHAN_AUTO) end
			end)
		end
	end
end

-- ==== SecondaryAttack - 右键呕吐蓄力技能 ====
-- 冷却 3.5 秒；播放吐息动画与身体破裂音效，0.8 秒后进入连续喷射毒液状态（PukeLeft）
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	-- 主/副攻击冷却中或正在装死时禁止使用
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or IsValid(owner.FeignDeath) then return end

	-- 设置副攻击冷却 3.5 秒并同步主攻击冷却
	self:SetNextSecondaryFire(CurTime() + 3.5)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 播放吐息动作事件与攻击/破裂音效
	owner:DoReloadEvent()
	self:PlayAttackSound()
	self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.random(70, 83))

	if SERVER then
		-- 0.8 秒后开启 4 连喷毒液状态，并播放藤壶消化音效
		timer.Simple(0.8, function()
			if self:IsValid() then
				self.PukeLeft = 4

				if owner:IsValidLivingZombie() then
					owner:EmitSound("npc/barnacle/barnacle_die2.wav")
					owner:EmitSound("npc/barnacle/barnacle_digesting1.wav")
					owner:EmitSound("npc/barnacle/barnacle_digesting2.wav")
				end
			end
		end)
	end
end
