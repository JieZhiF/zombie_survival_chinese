-- sh_init.lua

function SWEP:Initialize()
    if not self:IsValid() then return end

    self:SetWeaponHoldType(self.HoldType)
    
    -- ZS 权重与阶级逻辑
    if self.Weight and self.Tier then
        self.Weight = self.Weight + self.Tier
    end

    -- 旧版数据兼容处理
    if self.Cone then
        self.ConeMin = self.ConeIronCrouching
        self.ConeMax = self.ConeMoving
        self.ConeRamp = 2
    end
    
    -- 客户端初始化动画和模型
    if CLIENT then
        self:CheckCustomIronSights()
        self:Anim_Initialize()
    end
    
    self:ResetRecoilState()
    
    if GAMEMODE then
        GAMEMODE:DoChangeDeploySpeed(self)
    end
end

function SWEP:ResetRecoilState()
    self.recoil_punch = Angle(0, 0, 0)
    self.current_recoil_offset = Angle(0, 0, 0)
    self.last_frame_total_offset = Angle(0, 0, 0)
    self.CamRecoilTarget = Angle(0, 0, 0)
    self.CamRecoilCurrent = Angle(0, 0, 0)
    self.CamRecoilRollVal = 0
    self.Recoil_PermanentPool = Angle(0,0,0)
    self.Recoil_RecoverPool = Angle(0,0,0)
    
    self.VisRecoilPos, self.VisRecoilVel, self.VisRecoilAcc = Vector(0,0,0), Vector(0,0,0), Vector(0,0,0)
    self.VisRecoilAng, self.VisRecoilAngVel, self.VisRecoilAngAcc = Angle(0,0,0), Angle(0,0,0), Angle(0,0,0)
    
    self.last_shot_time = 0
    self.ShotCount = 0
    self.offset = 0
    self.Breath = 0
end