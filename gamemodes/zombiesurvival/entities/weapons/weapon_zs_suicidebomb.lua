AddCSLuaFile()

SWEP.Base                = "weapon_zs_base"

SWEP.PrintName           = "死亡袭击"
SWEP.Description         = "发动自爆时，会进入短暂的无敌时间，发生自爆后你和范围内的僵尸都会死"

SWEP.Slot                = 3
SWEP.SlotPos             = 4

SWEP.DrawAmmo            = false
SWEP.DrawCrosshair       = false
SWEP.ViewModelFOV        = 65
SWEP.ViewModelFlip       = false

SWEP.HoldType            = "slam"

SWEP.Spawnable           = true
SWEP.AdminOnly           = false

SWEP.ViewModel           = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel          = "models/weapons/w_c4.mdl"

SWEP.UseHands            = true

SWEP.Weight              = 5
SWEP.AutoSwitchTo        = false
SWEP.AutoSwitchFrom      = false

SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo      = "none"

SWEP.Exploded = false

SWEP.MaxStock = 10

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true
SWEP.AllowQualityWeapons = false

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
    self.NextLeeroy = nil
    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
end

function SWEP:Holster()
    self.NextLeeroy = nil
    return true
end

function SWEP:Think()
    if self.NextLeeroy and self.NextLeeroy < CurTime() and not self.Exploded and self.Owner:Alive() then
        self.Exploded = true

        -- 播放爆炸音效
        sound.Play("ambient/explosions/explode_"..math.random(1,7)..".wav", self.Owner:GetPos(), 200, math.random(50, 100))

        -- 创建爆炸特效
        local fx = EffectData()
        fx:SetOrigin(self.Owner:GetPos())
        util.Effect("Explosion", fx)

        if SERVER then
            -- 造成9999伤害，范围1000
            util.BlastDamage(self.Weapon, self.Owner, self.Owner:GetPos(), 1000, 9999)
        end
    end
end

function SWEP:PrimaryAttack()
    if not self.NextLeeroy then
        self.NextLeeroy = CurTime() + 1.8  -- 设置1.8秒后爆炸
        self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self.Weapon:SetNextPrimaryFire(CurTime() + 1.8)

        if SERVER then
            -- 立即进入无敌状态
            self.Owner:SetInvulnerable(true)

            -- 1.81秒后解除无敌，并强制玩家死亡
            timer.Simple(1.81, function()
                if IsValid(self.Owner) then
                    self.Owner:SetInvulnerable(false)
                    self.Owner:Kill()  -- 确保玩家立即死亡
                end
            end)
        end
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Reload()
    return false
end