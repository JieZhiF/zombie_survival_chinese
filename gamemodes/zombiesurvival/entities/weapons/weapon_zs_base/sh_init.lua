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
        -- 初始化所有后坐力相关的变量，防止 Think 报错
    self.last_shot_time = 0
    self.RecoilAmount = 0
    self.ShotCount = 0
    self.IsReloadingRecoil = false
    
    self:ResetRecoilState(false) -- false 表示完全重置
    if GAMEMODE then
        GAMEMODE:DoChangeDeploySpeed(self)
    end
end

-- 修改重置函数
function SWEP:ResetRecoilState(isReload)
    -- 1. 只有在【不是】换弹的时候，才暴力清空回正池和计时
    -- 这样换弹时，准星偏离的数值会被保留，从而让 CreateMove 把它拉回来
    if not isReload then
        self.Recoil_RecoverPool = Angle(0, 0, 0)
        self.last_shot_time = 0
        self.RecoilAmount = 0
        self.ShotCount = 0
    end

    -- 2. 无论何时都重置的视觉/镜头效果（防止镜头歪着或者FOV卡住）
    self.last_frame_total_offset = Angle(0, 0, 0)
    self.CamRecoilRollVal = 0
    self.CamFOV_Val = 0 
    self.CamFOV_Vel = 0 
    self.Recoil_Pending = Angle(0, 0, 0) 
    self.LastEyeAngles = nil 

    -- 枪模视觉位移
    self.VisRecoilPos = Vector(0, 0, 0)
    self.VisRecoilVel = Vector(0, 0, 0)
    self.VisRecoilAcc = Vector(0, 0, 0) 
    self.VisRecoilAng = Angle(0, 0, 0)
    self.VisRecoilAngVel = Angle(0, 0, 0)
    self.VisRecoilAngAcc = Angle(0, 0, 0)

    -- 摇晃/呼吸重置
    self.CurrentSwayAngle = Angle(0, 0, 0)
    self.CurrentBobVector = Vector(0, 0, 0)
    self.Breath = 0
end