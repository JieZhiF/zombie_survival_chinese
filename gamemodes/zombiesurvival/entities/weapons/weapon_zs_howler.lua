AddCSLuaFile()

SWEP.PrintName = ""..translate.Get("weapon_zs_howler")

SWEP.Base = "weapon_zs_zombie"

if CLIENT then
	SWEP.ViewModelFOV = 48
end

SWEP.ViewModel = Model("models/weapons/v_pza.mdl")

SWEP.MeleeReach = 78
SWEP.MeleeForceScale = 1.45
SWEP.MeleeSize = 4.5
SWEP.Primary.Delay = 1.35
SWEP.MeleeDamage = 38
SWEP.AlertDelay = 3.2

SWEP.SwingAnimSpeed = 0.58

SWEP.HowlDelay = 12

SWEP.BattlecryInterval = 0

function SWEP:Reload()
	self.BaseClass.SecondaryAttack(self)
end

local function Battlecry(pos)
	if SERVER then
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0,0,1))
		util.Effect("zombie_battlecry", effectdata, true)
	end
end

function SWEP:Think()
	self.BaseClass.Think(self)

	if self:GetBattlecry() > CurTime() then
		if self.BattlecryInterval < CurTime() then
			self.BattlecryInterval = CurTime() + 0.25
			local owner = self:GetOwner()
			local center = owner:GetPos() + Vector(0, 0, 32)
			if SERVER then
				for _, ent in pairs(ents.FindInSphere(center, 80)) do
					if ent:IsValidLivingZombie() and WorldVisible(ent:WorldSpaceCenter(), center)then
						ent:GiveStatus("zombie_battlecry", 1)
					end
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
    if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or CurTime() < self:GetNextHowl() then return end

    local owner = self:GetOwner()
    local pos = owner:GetPos()

    owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)

    self:SetBattlecry(CurTime() + 5)

    if SERVER then
        owner:EmitSound("npc/stalker/go_alert2a.wav", 100, math.random(50, 54))
        util.ScreenShake(pos, 5, 5, 3, 560)

        local center = owner:WorldSpaceCenter()
        timer.Simple(0, function() Battlecry(center) end)

        for _, ent in pairs(ents.FindInSphere(center, 240)) do  -- 战吼范围提升至 240
            if ent:IsValidLivingHuman() and WorldVisible(ent:WorldSpaceCenter(), center) then
                ent:GiveStatus("frightened", 4)  -- 仍然保留原本的 "frightened" 效果（持续 10 秒）

                -- 施加 1.5 秒的额外控制效果
                ent:SetMoveType(MOVETYPE_NONE)  -- 禁止移动
                ent:SetNWBool("NoAttack", true)  -- 禁止攻击
                ent:SetNWBool("NoWeaponSwitch", true)  -- 禁止切换武器

                -- 1.5 秒后恢复正常
                timer.Simple(1.5, function() --对人类造成的负面效果持续时间
                    if IsValid(ent) then
                        ent:SetMoveType(MOVETYPE_WALK)  -- 恢复移动
                        ent:SetNWBool("NoAttack", false)  -- 允许攻击
                        ent:SetNWBool("NoWeaponSwitch", false)  -- 允许切换武器
                    end
                end)
            end
        end
    end
    self:SetNextHowl(CurTime() + self.HowlDelay)
    self:SetNextSecondaryFire(CurTime() + 0.5)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

if SERVER then
    hook.Add("StartCommand", "SWEP_NoAttackControl", function(ply, cmd)
        if ply:GetNWBool("NoAttack", false) then
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2)
        end
    end)

    hook.Add("PlayerSwitchWeapon", "SWEP_NoWeaponSwitchControl", function(ply)
        if ply:GetNWBool("NoWeaponSwitch", false) then
            return true
        end
    end)

    hook.Add("PlayerDeath", "SWEP_ClearControlFlags", function(ply)
        ply:SetNWBool("NoAttack", false)
        ply:SetNWBool("NoWeaponSwitch", false)
        ply:Freeze(false)
    end)
end

function SWEP:PlayIdleSound()
	self:GetOwner():EmitSound("npc/combine_gunship/gunship_moan.wav", 70, math.random(85, 95))
end

SWEP.PlayAlertSound = SWEP.PlayIdleSound

function SWEP:PlayAttackSound()
	self:GetOwner():EmitSound("npc/antlion_guard/angry"..math.random(3)..".wav", 75, math.random(80, 85))
end

function SWEP:SetBattlecry(time)
	self:SetDTFloat(1, time)
end

function SWEP:GetBattlecry()
	return self:GetDTFloat(1)
end

function SWEP:SetNextHowl(time)
	self:SetDTFloat(2, time)
end

function SWEP:GetNextHowl()
	return self:GetDTFloat(2)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(1, 0.9, 0.6)
end

--[[  代码备份，防止出现BUG
function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextPrimaryFire() or CurTime() < self:GetNextSecondaryFire() or CurTime() < self:GetNextHowl() then return end

	local owner = self:GetOwner()
	local pos = owner:GetPos()

	owner:DoAnimationEvent(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)

	self:SetBattlecry(CurTime() + 5)

	if SERVER then
		owner:EmitSound("npc/stalker/go_alert2a.wav", 100, math.random(50, 54))
		util.ScreenShake(pos, 5, 5, 3, 560)

		local center = owner:WorldSpaceCenter()
		timer.Simple(0, function() Battlecry(center) end)

		for _, ent in pairs(ents.FindInSphere(center, 150)) do
			if ent:IsValidLivingHuman() and WorldVisible(ent:WorldSpaceCenter(), center) then
				ent:GiveStatus("frightened", 10)
			end
		end
	end
	self:SetNextHowl(CurTime() + self.HowlDelay)
	self:SetNextSecondaryFire(CurTime() + 0.5)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end
--]]