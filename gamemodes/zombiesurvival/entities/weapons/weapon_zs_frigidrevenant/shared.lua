-- ============================================================================
-- shared.lua - 冰封亡魂（僵尸近战武器，右键投掷冻腐肉）共享逻辑
-- 负责：近战属性定义、右键远程投掷三块腐肉（DoFleshThrow）、换弹键触发
--       特殊攻击，以及各战斗音效（取代基类的嚎叫/挥击音）
-- ============================================================================

-- 继承僵尸武器基类
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_frigidrevenant")

-- 近战伤害
SWEP.MeleeDamage = 32

-- 投掷腐肉的横向/纵向散布角（度）
local Spread = {
	{0, 0},
	{-0.5, 0},
	{0.5, 0}
}
-- ==== DoFleshThrow - 向瞄准方向投掷三块冻腐肉（带散布角） ====
local function DoFleshThrow(pl, wep)
	-- 持枪者和武器均有效时才执行
	if pl:IsValid() and pl:Alive() and wep:IsValid() then
		-- 投掷视为远程攻击：重置移动速度并记录上次远程攻击时间
		pl:ResetSpeed()
		pl.LastRangedAttack = CurTime()

		-- 服务端负责生成弹射物
		if SERVER then
			local startpos = pl:GetShootPos()
			local aimang = pl:EyeAngles()
			local ang

			-- 按散布表生成三块腐肉，各自绕上下/左右轴旋转偏移角度
			for _, spr in pairs(Spread) do
				ang = Angle(aimang.p, aimang.y, aimang.r)
				ang:RotateAroundAxis(ang:Up(), spr[1] * 5)
				ang:RotateAroundAxis(ang:Right(), spr[2] * 5)

				-- 生成食尸鬼腐肉弹射物并以 750 单位/秒向前抛出
				local ent = ents.Create("projectile_ghoulfleshfr")
				if ent:IsValid() then
					ent:SetPos(startpos)
					ent:SetOwner(pl)
					ent:Spawn()

					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(ang:Forward() * 750)
					end
				end
			end

			-- 播放身体破裂音效（随机 2~4 号）
			pl:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.Rand(85, 95))
		end
	end
end

-- ==== SecondaryAttack - 右键：蓄力投掷冻腐肉（3 秒冷却） ====
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	-- 主/副攻击冷却中或处于假死状态时禁止投掷
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or IsValid(owner.FeignDeath) then return end

	-- 设置 3 秒副攻击冷却，主攻击冷却与近战节奏对齐
	self:SetNextSecondaryFire(CurTime() + 3)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 触发僵尸事件并播放嚎叫与破裂音效，播放命中动画
	self:GetOwner():DoZombieEvent()
	self:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
	self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.Rand(85, 95))
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	-- 0.7 秒后实际投掷腐肉（延迟对应蓄力动画）
	timer.Simple(0.7, function() DoFleshThrow(owner, self) end)
end

-- ==== Reload - 换弹键改为触发右键特殊攻击（投掷腐肉） ====
function SWEP:Reload()
	self:SecondaryAttack()
end

-- ==== StartMoaning - 覆盖基类：此武器不使用嚎叫 ====
function SWEP:StartMoaning()
end

-- ==== StopMoaning - 覆盖基类：此武器不使用嚎叫 ====
function SWEP:StopMoaning()
end

-- ==== IsMoaning - 此武器永远不处于嚎叫状态 ====
function SWEP:IsMoaning()
	return false
end

-- ==== PlayHitSound - 近战命中音效（快速僵尸爪击） ====
function SWEP:PlayHitSound()
	self:EmitSound("NPC_FastZombie.AttackHit", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 近战挥空音效 ====
function SWEP:PlayMissSound()
	self:EmitSound("NPC_FastZombie.AttackMiss", nil, nil, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 攻击音效（毒僵尸警告+痛苦嚎叫） ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/zombie_poison/pz_warn"..math.random(2)..".wav", 70, math.random(140, 145), 0.65, CHAN_AUTO)
	self:EmitSound("npc/metropolice/pain"..math.random(4)..".wav", 74, math.Rand(125, 135), 0.65, CHAN_WEAPON + 20)
end

-- ==== PlayIdleSound - 待机音效（蚁狮低鸣） ====
function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/antlion/idle"..math.random(5)..".wav", 70, math.random(60, 66))
end

-- ==== PlayAlertSound - 警戒音效（猎头蟹呼吸声） ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/stalker/breathing3.wav", 70, math.random(80, 90))
end
