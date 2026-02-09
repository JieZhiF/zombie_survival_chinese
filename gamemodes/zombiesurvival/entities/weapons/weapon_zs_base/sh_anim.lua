-- sh_anim.lua

local ActIndex = {
    [ "pistol" ]        = ACT_HL2MP_IDLE_PISTOL,
    [ "smg" ]           = ACT_HL2MP_IDLE_SMG1,
    [ "grenade" ]       = ACT_HL2MP_IDLE_GRENADE,
    [ "ar2" ]           = ACT_HL2MP_IDLE_AR2,
    [ "shotgun" ]       = ACT_HL2MP_IDLE_SHOTGUN,
    [ "rpg" ]           = ACT_HL2MP_IDLE_RPG,
    [ "physgun" ]       = ACT_HL2MP_IDLE_PHYSGUN,
    [ "crossbow" ]      = ACT_HL2MP_IDLE_CROSSBOW,
    [ "melee" ]         = ACT_HL2MP_IDLE_MELEE,
    [ "slam" ]          = ACT_HL2MP_IDLE_SLAM,
    [ "normal" ]        = ACT_HL2MP_IDLE,
    [ "fist" ]          = ACT_HL2MP_IDLE_FIST,
    [ "melee2" ]        = ACT_HL2MP_IDLE_MELEE2,
    [ "passive" ]       = ACT_HL2MP_IDLE_PASSIVE,
    [ "knife" ]         = ACT_HL2MP_IDLE_KNIFE,
    [ "duel" ]          = ACT_HL2MP_IDLE_DUEL,
    [ "revolver" ]      = ACT_HL2MP_IDLE_REVOLVER,
    [ "camera" ]        = ACT_HL2MP_IDLE_CAMERA
}

function SWEP:SetWeaponHoldType( t )
    t = string.lower( t )
    local index = ActIndex[ t ]

    if ( index == nil ) then
        Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal) (from "..self:GetClass()..")\n" )
        t = "normal"
        index = ActIndex[ t ]
    end

    self.ActivityTranslate = {}
    self.ActivityTranslate [ ACT_MP_STAND_IDLE ]                = index
    self.ActivityTranslate [ ACT_MP_WALK ]                      = index+1
    self.ActivityTranslate [ ACT_MP_RUN ]                       = index+2
    self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ]               = index+3
    self.ActivityTranslate [ ACT_MP_CROUCHWALK ]                = index+4
    self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]  = index+5
    self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
    self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]              = index+6
    self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]             = index+6
    self.ActivityTranslate [ ACT_MP_JUMP ]                      = index+7
    self.ActivityTranslate [ ACT_RANGE_ATTACK1 ]                = index+8
    self.ActivityTranslate [ ACT_MP_SWIM_IDLE ]                 = index+8
    self.ActivityTranslate [ ACT_MP_SWIM ]                      = index+9

    if t == "normal" then self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM end
    if t == "knife" or t == "melee2" then self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] = nil end
end
SWEP:SetWeaponHoldType("pistol")

function SWEP:TranslateActivity(act)
    if self:GetIronsights() and self.ActivityTranslateIronSights then
        return self.ActivityTranslateIronSights[act] or -1
    end
    return self.ActivityTranslate and self.ActivityTranslate[act] or -1
end

function SWEP:SendWeaponAnimation()
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    local vm = self:GetOwner():GetViewModel()
    if IsValid(vm) then vm:SetPlaybackRate(self.FireAnimSpeed) end
end

function SWEP:SendReloadAnimation()
    self:SendWeaponAnim(ACT_VM_RELOAD)
end