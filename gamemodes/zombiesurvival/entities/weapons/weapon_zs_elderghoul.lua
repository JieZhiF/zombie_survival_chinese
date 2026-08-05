-- ============================================================================
-- weapon_zs_elderghoul.lua - 老尸鬼（僵尸近战武器）
-- 负责：定义尸鬼的爪击（附带毒素伤害）与右键投掷毒肉技能
-- ============================================================================
AddCSLuaFile()

-- 武器名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_elderghoul")

-- 基于通用僵尸武器母本
SWEP.Base = "weapon_zs_zombie"

-- 近战伤害（对人）与对道具伤害
SWEP.MeleeDamage = 22
SWEP.MeleeDamageVsProps = 22
-- 近战击退力度倍率
SWEP.MeleeForceScale = 0.5
-- 攻击时的减速比例
SWEP.SlowDownScale = 0.25

-- ==== ApplyMeleeDamage - 近战命中：改为施加毒素伤害 ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	ent:PoisonDamage(damage, self:GetOwner(), self, trace.HitPos)
end

-- ==== MeleeHit - 近战命中：非玩家目标改用道具伤害值 ====
function SWEP:MeleeHit(ent, trace, damage, forcescale)
	-- 非玩家目标（道具等）使用较低的对道具伤害
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

-- ==== Reload - 换弹键：复用母本副攻击（投掷毒肉） ====
function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

-- ==== PlayAlertSound - 警戒音效：快速僵尸的警报声 ====
function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/fast_zombie/fz_alert_close1.wav", 75, math.Rand(70, 80))
end
-- 空闲音效沿用警戒音效
SWEP.PlayIdleSound = SWEP.PlayAlertSound

-- ==== PlayAttackSound - 攻击音效：扑击声 ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
end

-- 毒肉投掷的散射角度模式（俯仰/偏航偏移）
local PoisonPatterns = {
	Angle(0, 0, 0),
	Angle(8, 0, 0),
	Angle(-8, 8, 0),
	Angle(-8, -8, 0)
}
-- ==== DoFleshThrow - 投掷毒肉：按散射模式生成 4 枚毒肉弹体 ====
local function DoFleshThrow(pl, wep)
	if pl:IsValid() and pl:Alive() and wep:IsValid() then
		-- 记录最近远程攻击时间
		pl.LastRangedAttack = CurTime()

		if SERVER then
			local startpos = pl:GetShootPos()
			local aimang = pl:EyeAngles()

			-- 按预设散射模式逐个生成毒肉弹体
			for i, pattern in pairs(PoisonPatterns) do
				-- 在瞄准角度上叠加散射偏移
				local ang = Angle(aimang.p, aimang.y, aimang.r)
				ang:RotateAroundAxis(ang:Up(), pattern.yaw)
				ang:RotateAroundAxis(ang:Right(), pattern.pitch)

				local ent = ents.Create("projectile_poisonflesh")
				if ent:IsValid() then
					ent:SetPos(startpos)
					ent:SetOwner(pl)
					ent:Spawn()

					-- 赋予弹体向前的初速度
					local phys = ent:GetPhysicsObject()
					if phys:IsValid() then
						phys:SetVelocityInstantaneous(ang:Forward() * 350)
					end
				end
			end

			-- 播放身体碎裂音效
			pl:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 72, math.Rand(85, 95))
		end
	end
end

-- ==== SecondaryAttack - 副攻击：投掷毒肉（3 秒冷却） ====
function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	-- 主/副攻击冷却中或装死状态下无法投掷
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or IsValid(owner.FeignDeath) then return end

	-- 设置 3 秒副攻击冷却与主攻击冷却
	self:SetNextSecondaryFire(CurTime() + 3)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	-- 播放僵尸事件动画与音效
	self:GetOwner():DoZombieEvent()
	self:EmitSound("npc/fast_zombie/leap1.wav", 74, math.Rand(110, 130))
	self:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 72, math.Rand(85, 95))
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self.IdleAnimation = CurTime() + self:SequenceDuration()

	-- 0.7 秒后延迟投掷毒肉
	timer.Simple(0.7, function() DoFleshThrow(owner, self) end)
end

-- 以下为客户端专属内容
if not CLIENT then return end

-- ==== ViewModelDrawn - 视图模型绘制后：清除材质覆盖与颜色调制 ====
function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
	render.SetColorModulation(1, 1, 1)
end

-- 尸鬼皮肤的材质覆盖
local matSheet = Material("models/weapons/v_zombiearms/ghoulsheet")
-- ==== PreDrawViewModel - 视图模型绘制前：覆盖为尸鬼皮肤材质并调色 ====
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
	render.SetColorModulation(0.66, 0.86, 0)
end
