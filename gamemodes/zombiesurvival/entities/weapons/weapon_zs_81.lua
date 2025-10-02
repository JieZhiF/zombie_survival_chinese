AddCSLuaFile()

SWEP.PrintName = "'81式' 试用形"
SWEP.Description = "按 Shift 切换形态，右键进行紧急射击（消耗手枪弹药）。"

SWEP.SlotPos = 0

if CLIENT then
    SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotAssaultRifles")
    SWEP.WeaponType = "rifle"
    SWEP.SlotGroup = WEPSELECT_ASSAULT_RIFLE
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 50

    SWEP.HUD3DBone = "v_weapon.AK47_Parent"
    SWEP.HUD3DPos = Vector(-1, -4.5, -4)
    SWEP.HUD3DAng = Angle(0, 0, 0)
    SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"
SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true

SWEP.Tier = 5
SWEP.MaxStock = 2

-- 默认形态
SWEP.CurrentMode = "assault"

-- 突击模式数据
SWEP.Assault = {
    HoldType = "ar2",
    ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl",
    WorldModel = "models/weapons/w_rif_ak47.mdl",
    Primary = {
        Sound = Sound("Weapon_AK47.Single"),
        Damage = 35,
        Delay = 0.085,
        ClipSize = 45,
        Automatic = true,
        Ammo = "ar2"
    },
    Secondary = {
        Sound = Sound("Weapon_Pistol.NPC_Single"),
        Damage = 30,
        Delay = 0.01,
        ClipSize = 10,
        Automatic = false,
        Ammo = "pistol"
    },
    ConeMax = 2.275,
    ConeMin = 1.242,
    WalkSpeed = SPEED_ZOMBIEESCAPE_SLOW,
    IronSightsPos = Vector(-6.6, 20, 3.1)
}

-- 冲锋模式数据
SWEP.SMG = {
    HoldType = "shotgun",
    ViewModel = "models/weapons/cstrike/c_smg_mp5.mdl",
    WorldModel = "models/weapons/w_smg_mp5.mdl",
    Primary = {
        Sound = Sound("Weapon_MP5Navy.Single"),
        Damage = 22,
        Delay = 0.04,
        ClipSize = 70,
        Automatic = true,
        Ammo = "smg1"
    },
    Secondary = nil,  -- SMG 形态无副射击
    ConeMax = 3.75,
    ConeMin = 2.2,
    WalkSpeed = SPEED_SLOW,
    IronSightsPos = Vector(-5.33, 7, 1.8)
}

-- 适用于突击模式的属性调整
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAX_SPREAD, -0.344)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -0.172)

-- 适用于冲锋模式的属性调整
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.1)

-- 初始化武器模式
function SWEP:Initialize()
    self:SetWeaponMode("assault")

    -- 只在初始化时设置默认子弹
    GAMEMODE:SetupDefaultClip(self.Primary)
end

-- **初始化冷却变量**
SWEP.NextModeSwitch = 0

-- **切换形态**
function SWEP:Think()
    local owner = self:GetOwner()
    
    -- **判断冷却是否结束**
    if owner:KeyPressed(IN_SPEED) and CurTime() >= self.NextModeSwitch then  
        if self.CurrentMode == "assault" then
            self:SetWeaponMode("smg")
        else
            self:SetWeaponMode("assault")
        end
        self.NextModeSwitch = CurTime() + 1  -- **添加 1 秒冷却**
    end
end

-- **更换武器模式**
function SWEP:SetWeaponMode(mode)
    if mode ~= "assault" and mode ~= "smg" then return end

    self.CurrentMode = mode
    local data = (mode == "assault") and self.Assault or self.SMG

    -- **设置武器参数**
    self:SetHoldType(data.HoldType)
    self.ViewModel = data.ViewModel
    self.WorldModel = data.WorldModel
    self.Primary.Sound = data.Primary.Sound
    self.Primary.Damage = data.Primary.Damage
    self.Primary.Delay = data.Primary.Delay
    self.Primary.ClipSize = data.Primary.ClipSize
    self.Primary.Automatic = data.Primary.Automatic
    self.Primary.Ammo = data.Primary.Ammo  -- **修改 Ammo 类型**
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    -- **强制换弹**
    local reserveAmmo = owner:GetAmmoCount(self.Primary.Ammo)  -- 获取当前背包中的子弹
    self:SetClip1(0)  -- 直接清空弹匣，确保换弹逻辑能触发
    self:Reload()  -- 触发换弹

    -- **副射击（仅突击模式）**
    if data.Secondary then
        self.Secondary = {
            Sound = data.Secondary.Sound,
            Damage = data.Secondary.Damage,
            Delay = data.Secondary.Delay,
            ClipSize = data.Secondary.ClipSize,
            Automatic = data.Secondary.Automatic,
            Ammo = data.Secondary.Ammo
        }
    else
        self.Secondary = nil  -- **冲锋模式没有副射击**
    end

    self.ConeMax = data.ConeMax
    self.ConeMin = data.ConeMin
    self.WalkSpeed = data.WalkSpeed
    self.IronSightsPos = data.IronSightsPos

    -- **HUD 提示当前模式**
    if mode == "assault" then
        owner:ChatPrint("当前形态: 突击形态")
    else
        owner:ChatPrint("当前形态: 冲锋形态")
    end
end

-- **修复换弹逻辑**
function SWEP:Reload()
    -- **如果当前弹夹满了，不能换弹**
    if self:Clip1() >= self.Primary.ClipSize then return end

    -- **获取玩家和当前武器的子弹类型**
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local ammoType = self.Primary.Ammo
    local reserveAmmo = owner:GetAmmoCount(ammoType)  -- 获取背包弹药数

    -- **如果背包没有子弹，则无法换弹**
    if reserveAmmo <= 0 then return end

    -- **执行换弹动画**
    self:DefaultReload(ACT_VM_RELOAD)

    -- **确保换弹成功**
    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) and IsValid(owner) then
            local clipSize = self.Primary.ClipSize
            local loadAmount = math.min(clipSize - self:Clip1(), reserveAmmo)  -- 计算需要装填的子弹数量

            self:SetClip1(self:Clip1() + loadAmount)  -- 填充弹匣
            owner:RemoveAmmo(loadAmount, ammoType)   -- **正确减少背包中的子弹**
        end
    end)
end

-- **副射击（仅限突击模式）**
function SWEP:SecondaryAttack()
    if self.CurrentMode ~= "assault" or not self.Secondary then return end  

    -- 副射击弹匣没子弹时，播放空弹音效
    if self:Clip2() <= 0 then
        self:EmitSound("Weapon_Pistol.Empty")  -- 播放空弹音效
        self:SetNextSecondaryFire(CurTime() + 0.5)  -- 增加延迟，防止疯狂点击
        return
    end

    self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
    self:EmitSound(self.Secondary.Sound)

    self:ShootBullets(self.Secondary.Damage, 1, self:GetCone())  
    self:SetClip2(self:Clip2() - 1)  -- 只减少副射击弹匣中的子弹

    self.IdleAnimation = CurTime() + self:SequenceDuration()
end