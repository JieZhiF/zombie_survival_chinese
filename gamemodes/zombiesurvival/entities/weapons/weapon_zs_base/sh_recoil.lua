-- sh_recoil.lua

function SWEP:GetRecoilModifier()
    local owner = self:GetOwner()
    if not IsValid(owner) then return 1 end
    
    local mod = 1
    if self:GetIronsights() then mod = mod * (self.RecoilMultSights or 0.5) end
    if owner:Crouching() then mod = mod * (self.RecoilMultCrouch or 0.75) end
    if not owner:IsOnGround() then mod = mod * (self.RecoilMultMidAir or 2.0) end
    if owner:GetVelocity():Length2D() > 70 then mod = mod * (self.RecoilMultMove or 1.3) end
    
    return mod
end

function SWEP:ApplyRecoil()
    if not self.Recoil_Enabled then return end
    local mod = self:GetRecoilModifier()
    local seed = "zs_" .. self:EntIndex() .. self.ShotCount

    -- 1. 计算这一发子弹产生的总后座 (负为上)
    local up = (self.RecoilUp + util.SharedRandom(seed, 0, self.RecoilRandomUp)) * mod
    local side = util.SharedRandom(seed, -1, 1) * (self.RecoilSide + util.SharedRandom(seed.."s", 0, self.RecoilRandomSide)) * mod

    -- 2. 初始化角度池 (如果不存在)
    self.Recoil_PermanentPool = self.Recoil_PermanentPool or Angle(0, 0, 0)
    self.Recoil_RecoverPool = self.Recoil_RecoverPool or Angle(0, 0, 0)

    -- 3. 分配比例
    local pct = math.Clamp(self.RecoilRecoveryPercentage or 0.5, 0, 1)
    
    -- 永久部分：加进永久池
    self.Recoil_PermanentPool.p = self.Recoil_PermanentPool.p - (up * (1 - pct))
    self.Recoil_PermanentPool.y = self.Recoil_PermanentPool.y + (side * (1 - pct))

    -- 恢复部分：加进恢复池
    self.Recoil_RecoverPool.p = self.Recoil_RecoverPool.p - (up * pct)
    self.Recoil_RecoverPool.y = self.Recoil_RecoverPool.y + (side * pct)

    -- 4. 视觉表现 (保持不变)
    if CLIENT and IsFirstTimePredicted() then
        self:ApplyVisualRecoilImpulse(mod, seed)
    end
    
    self.last_shot_time = CurTime()
end
-- 视觉冲量辅助 (枪模和镜头晃动)
function SWEP:ApplyVisualRecoilImpulse(mod, seed)
    -- 镜头抖动 (CamRecoil) 通常建议保留，如果你希望它也随之关闭，可以将下段也放入 if 判断中
    self.CamRecoilTarget = self.CamRecoilTarget or Angle(0,0,0)
    self.CamRecoilTarget.p = self.CamRecoilTarget.p - (self.CamRecoilUp * mod)
    self.CamRecoilRollVal = (self.CamRecoilRollVal or 0) + (util.SharedRandom(seed.."cr", -1, 1) * self.CamRecoilRoll * mod)
    
    ---------------------------------------------------------
    -- 修改部分：检测 CustomSightsAttackAnim
    ---------------------------------------------------------
    if self.CustomSightsAttackAnim then
        self.VisRecoilVel = self.VisRecoilVel or Vector(0,0,0)
        self.VisRecoilAngVel = self.VisRecoilAngVel or Angle(0,0,0)
        
        -- 只有在开启时才累加冲量
        self.VisRecoilVel.x = self.VisRecoilVel.x - (self.VisualRecoilPunch * mod * 15)
        self.VisRecoilAngVel.p = self.VisRecoilAngVel.p - (self.VisualRecoilUp * mod * 20)
        self.VisRecoilAngVel.r = self.VisRecoilAngVel.r + (util.SharedRandom(seed.."vr", -1, 1) * self.VisualRecoilRoll * mod * 10)
    end
end