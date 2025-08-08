AddCSLuaFile()

SWEP.PrintName = "传送匕首"
SWEP.Description = "刀刃上刻印着看不懂的符文，按R记录当前位置，再次按R传送至记录地."

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 55
end

SWEP.Base = "weapon_zs_basemelee"
SWEP.HoldType = "knife"

SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.UseHands = true

SWEP.MeleeDamage = 19
SWEP.MeleeRange = 52
SWEP.MeleeSize = 0.875

SWEP.WalkSpeed = SPEED_FASTEST
SWEP.Primary.Delay = 0.85

SWEP.HitDecal = "Manhackcut"
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
SWEP.MissGesture = SWEP.HitGesture
SWEP.HitAnim = ACT_VM_MISSCENTER
SWEP.MissAnim = ACT_VM_PRIMARYATTACK
SWEP.NoHitSoundFlesh = true

SWEP.Tier = 5
SWEP.AllowQualityWeapons = true

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.085)

function SWEP:PlaySwingSound()
    self:EmitSound("weapons/knife/knife_slash"..math.random(2)..".wav")
end

function SWEP:PlayHitSound()
    self:EmitSound("weapons/knife/knife_hitwall1.wav")
end

function SWEP:PlayHitFleshSound()
    self:EmitSound("weapons/knife/knife_hit"..math.random(4)..".wav")
end

function SWEP:OnMeleeHit(hitent, hitflesh, tr)
    if hitent:IsValid() and hitent:IsPlayer() and not self.m_BackStabbing and math.abs(hitent:GetForward():Angle().yaw - self:GetOwner():GetForward():Angle().yaw) <= 90 then
        self.m_BackStabbing = true
        self.MeleeDamage = self.MeleeDamage * 2
    end
end

function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
    if self.m_BackStabbing then
        self.m_BackStabbing = false
        self.MeleeDamage = self.MeleeDamage / 2
    end
end

if SERVER then
    util.AddNetworkString("TeleportDaggerCooldown")

    function SWEP:InitializeHoldType()
        self.ActivityTranslate = {}
        self.ActivityTranslate[ACT_HL2MP_IDLE] = ACT_HL2MP_IDLE_KNIFE
        self.ActivityTranslate[ACT_HL2MP_WALK] = ACT_HL2MP_WALK_KNIFE
        self.ActivityTranslate[ACT_HL2MP_RUN] = ACT_HL2MP_RUN_KNIFE
        self.ActivityTranslate[ACT_HL2MP_IDLE_CROUCH] = ACT_HL2MP_IDLE_CROUCH_PHYSGUN
        self.ActivityTranslate[ACT_HL2MP_WALK_CROUCH] = ACT_HL2MP_WALK_CROUCH_KNIFE
        self.ActivityTranslate[ACT_HL2MP_GESTURE_RANGE_ATTACK] = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
        self.ActivityTranslate[ACT_HL2MP_GESTURE_RELOAD] = ACT_HL2MP_GESTURE_RELOAD_KNIFE
        self.ActivityTranslate[ACT_HL2MP_JUMP] = ACT_HL2MP_JUMP_KNIFE
        self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_RANGE_ATTACK_KNIFE
    end

    function SWEP:Reload()
        if not self.NextReload or CurTime() >= self.NextReload then
            self.NextReload = CurTime() + 1 -- 防止频繁按R

            local owner = self:GetOwner()
            if not IsValid(owner) then return end

            self.StoredPosition = self.StoredPosition or {}
            self.StoredPosition.cooldown = self.StoredPosition.cooldown or 0

            if self.StoredPosition.pos then
                -- 检查冷却
                if CurTime() < self.StoredPosition.cooldown then
                    local remaining = math.ceil(self.StoredPosition.cooldown - CurTime())
                    owner:ChatPrint("传送冷却中，剩余时间：" .. remaining .. " 秒")
                    return
                end

                -- 执行传送
                owner:SetPos(self.StoredPosition.pos)
                owner:SetEyeAngles(self.StoredPosition.ang)
                owner:EmitSound("npc/roller/mine/rmine_blip3.wav")
                self.StoredPosition.cooldown = CurTime() + 300 -- 设置冷却300秒
                self.StoredPosition.pos = nil -- 清除标记
                self.StoredPosition.ang = nil
                owner:ChatPrint("已传送至记录位置。传送已进入冷却。")
            else
                -- 记录当前位置（无冷却限制）
                self.StoredPosition.pos = owner:GetPos()
                self.StoredPosition.ang = owner:EyeAngles()
                owner:EmitSound("npc/roller/blade_out.wav")
                owner:ChatPrint("已记录当前位置，再次按R可返回。")
            end
        end
    end
end