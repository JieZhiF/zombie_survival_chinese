-- ============================================================================
-- weapon_zs_energysword_dasher.lua - 能量剑·冲刺者（近战武器）
-- 负责：右键冲刺突进连击（SwiftStriking）、能量溶解伤害、二次能量爆发、冷却 HUD
-- ============================================================================
AddCSLuaFile()

if CLIENT then

	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 70 -- 第一人称视野

	SWEP.ShowViewModel = false -- 隐藏第一人称模型（用自定义元素替代）
	SWEP.ShowWorldModel = false -- 隐藏第三人称模型（用自定义元素替代）

-- 第一人称自定义元素：剑刃与握柄（SCK 风格配置）
SWEP.VElements = {
	["Blade"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-2.967, 1.404, -9.174), angle = Angle(-180, -90, 8.237), size = Vector(0.103, 0.305, 0.156), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Handle"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(-0.983, 1.299, -0.692), angle = Angle(0, -11.07, 0), size = Vector(0.913, 0.913, 0.913), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
-- 第三人称自定义元素：握柄与剑刃
SWEP.WElements = {
	["Handle"] = { type = "Model", model = "models/items/combine_rifle_cartridge01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.285, 0.587, -0.67), angle = Angle(25.451, -7.106, -12.844), size = Vector(0.47, 0.828, 0.671), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["Blade"] = { type = "Model", model = "models/props_combine/combine_fence01b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.098, 1.679, -7.317), angle = Angle(-6.257, 90.987, 168.966), size = Vector(0.127, 0.127, 0.237), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}
end
SWEP.PrintName = translate.Get("wep_energysword_d") -- 显示名称
SWEP.Description = translate.Get("wep_d_energysword_d") -- 描述文本


SWEP.Base = "weapon_zs_basemelee" -- 基于基础近战武器

SWEP.HoldType = "melee2" -- 持枪姿势：近战二型
SWEP.DamageType = DMG_DISSOLVE -- 伤害类型：溶解
SWEP.ViewModel = "models/weapons/c_crowbar.mdl" -- 第一人称模型
SWEP.ShowWorldModel = false -- 隐藏默认第三人称模型
SWEP.WorldModel = "models/weapons/w_knife_t.mdl" -- 第三人称模型
SWEP.UseHands = true -- 使用玩家手臂
SWEP.HitDecal = "Manhackcut" -- 命中贴花

SWEP.MeleeDamage = 119 -- 近战伤害
SWEP.MeleeRange = 99 -- 近战范围
SWEP.MeleeSize = 2 -- 近战判定大小
SWEP.Tier = 3 -- 武器等级

SWEP.AllowQualityWeapons = true -- 允许强化

SWEP.WalkSpeed = SPEED_NORMAL -- 移动速度

SWEP.Primary.Delay = 0.7 -- 左键攻击间隔
SWEP.Secondary.Delay = 10 -- 右键冲刺技能冷却
SWEP.SwiftStriking = false -- 是否处于冲刺突进状态
SWEP.CapFallDamage = true -- 减免坠落伤害
SWEP.HitAnim = ACT_VM_MISSCENTER -- 命中动画

-- ==== PlayHitSound - 命中非生物目标音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("ambient/energy/weld"..math.random(2)..".wav", 75, math.random(120,150))
end
-- ==== PlaySwingSound - 挥击音效 ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/physcannon/energy_bounce"..math.random(2)..".wav", 75, math.random(80,110))
end
-- ==== PlayHitFleshSound - 命中血肉音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/flesh/flesh_bloody_break.wav", 80, math.Rand(90, 100))
end

-- ==== OnMeleeHit - 命中时播放特斯拉电击特效与切痕贴花 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	local ent = tr.Entity
	local edata = EffectData()
		edata:SetEntity(hitent)
		edata:SetMagnitude(2)
		edata:SetScale(1)
		util.Effect("TeslaHitBoxes", edata) 
		edata:SetOrigin(tr.HitPos)
		edata:SetNormal(tr.HitNormal)
		edata:SetMagnitude(1)
		edata:SetScale(1)
		util.Effect("AR2Impact", edata)
		util.Decal("Manhackcut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
end
-- ==== PrimaryAttack - 左键攻击：执行基础近战挥击 ====
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self.SwingTime == 0 then
		self:MeleeSwing() -- 无挥击动画则直接结算
	else
		self:StartSwinging() -- 有挥击动画则先播放
	end
end
-- ==== Think - 冲刺突进期间每帧追踪目标并施加穿刺伤害 ====
function SWEP:Think()

	local curtime = CurTime()
	local owner = self:GetOwner()

	if self.SwiftStriking then
			local dir = owner:GetAimVector() -- 冲刺方向（限制垂直角度）
			dir.z = math.Clamp(dir.z, -0.5, 0.9)
			dir:Normalize()

			owner:LagCompensation(true) -- 开启延迟补偿保证命中判定准确

			-- 穿透式近战追踪：沿途每 12 单位采样一次，半径 12
			local traces = owner:PenetratingMeleeTrace(24, 12, owner:LocalToWorld(owner:OBBCenter()), dir)
			local ownerspeed = owner:GetVelocity():Length() -- 冲刺速度决定伤害倍率
			local hit = false
			for _, trace in ipairs(traces) do
				if trace.Hit then
					if trace.HitWorld then
						-- 撞到墙壁（非地面）时停止冲刺
						if trace.HitNormal.z < 0.8 then
							hit = true
							self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
						end
					else
						local ent = trace.Entity
						if ent and ent:IsValid() then
							-- 命中目标：抛飞并按其相对速度结算伤害
							hit = true
							self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
							local nearest = ent:NearestPoint(trace.StartPos)
							ent:ThrowFromPositionSetZ(self:GetOwner():GetPos(), ownerspeed * 0.3)
							self:ApplyMeleeDamage(ent, trace, math.Clamp(ownerspeed/1400,0,2)*self.MeleeDamage)
						end
					end
				end
			end

			-- 冲刺结束时播放音效（仅服务器）
			if SERVER and hit then
				owner:EmitSound("npc/strider/strider_skewer1.wav")
			end

			owner:LagCompensation(false)

			-- 命中后退出冲刺状态并恢复重力/摩擦
			if hit then
				self.SwiftStriking = false
				self:GetOwner():SetGravity(1)
				self:GetOwner():SetFriction(1)
			end
	end
	self.BaseClass.Think(self)
	self:NextThink(curtime)
	return true

end

-- ==== ApplyMeleeDamage - 对目标结算特殊伤害（玩家直结、实体延迟避免预测错误） ====
function SWEP:ApplyMeleeDamage(ent, trace, damage)
	ent:EmitSound("npc/manhack/grind_flesh1.wav")
	if ent:IsPlayer() then
		ent:TakeSpecialDamage(damage, self.DamageType, self:GetOwner(), self, trace.HitPos)
	else
		local dmgtype, owner, hitpos = self.DamageType, self:GetOwner(), trace.HitPos
		timer.Simple(0, function() -- Avoid prediction errors.
			if ent:IsValid() then
				ent:TakeSpecialDamage(damage, dmgtype, owner, self, hitpos)
			end
		end)
	end
end

-- ==== SecondaryAttack - 右键冲刺：向前突进并进入 SwiftStriking 状态 ====
function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() then
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay) -- 冷却 10 秒
	self:EmitSound("npc/env_headcrabcanister/incoming.wav", 80, math.Rand(90, 100))
	if SERVER then
		local fwd = 1200 -- 冲刺推力
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
		-- 向视线方向加速并悬浮（低重力低摩擦）
		local pushvel = self:GetOwner():GetEyeTrace().Normal * fwd + (self:GetOwner():GetAngles():Up()*100)
        self:GetOwner():SetGroundEntity(nil)
        self:GetOwner():SetLocalVelocity( self:GetOwner():GetVelocity() + pushvel)
		self.SwiftStriking = true
		self:GetOwner():SetGravity(0.2)
		self:GetOwner():SetFriction(0.01)
		local ownerplayer = self:GetOwner()
		-- 冲刺途中死亡则恢复重力/摩擦
		hook.Add( "DoPlayerDeath", "remove_energy_sword_float", function(ply, a, dmg)
			if ply == ownerplayer  then 
			ownerplayer:SetGravity(1)
			ownerplayer:SetFriction(1)
			hook.Remove( "DoPlayerDeath", "remove_energy_sword_float" )
			end
		end )
		-- 0.75 秒后强制结束冲刺状态并恢复物理属性
		timer.Simple( 0.75, function() 
			if self and self:IsValid() and self:GetOwner() and self:GetOwner():IsValid() and self:GetOwner():IsPlayer() and self:GetOwner():Alive() then 
				self:GetOwner():SetGravity(1)
				self:GetOwner():SetFriction(1)
				self.SwiftStriking = false
				--self:GetOwner():SetMoveType(MOVETYPE_NONE)
				--self:GetOwner():SetLocalVelocity(Vector(0,0,0))
			end 
		end)
		
    end
	end
end

if not CLIENT then return end
local texGradDown = surface.GetTextureID("VGUI/gradient_down") -- 渐变纹理用于冷却条
-- ==== DrawHUD - 绘制右键冲刺冷却条 ====
function SWEP:DrawHUD()
	local scrW = ScrW()
	local scrH = ScrH()
	local width = 386
	local height = 16
	local x, y = ScrW() - width - 32, ScrH() - height - 72
	local ratio = math.max(self:GetNextSecondaryFire()-CurTime(),0) / self.Secondary.Delay -- 冷却剩余比例
	if ratio > 0 then
		-- 冷却条背景
		surface.SetDrawColor(5, 5, 5, 180)
		surface.DrawRect(x, y, width, height)

		-- 红色冷却进度条（渐变填充）
		surface.SetDrawColor(255, 0, 0, 180)
		surface.SetTexture(texGradDown)
		surface.DrawTexturedRect(x, y, width*ratio, height)

		-- 橙色描边
		surface.SetDrawColor(255, 166, 0, 180)
		surface.DrawOutlinedRect(x - 1, y - 1, width + 2, height + 2)
	end
	if self.BaseClass.DrawHUD then
		self.BaseClass.DrawHUD(self)
	end
end