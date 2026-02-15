-- sh_recoil.lua

-- 获取后坐力倍率 (保持不变)
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
    
    -- 1. 计算倍率与种子
    local mod = self:GetRecoilModifier()
    --self.ShotCount = (self.ShotCount or 0) + 1
    local seed = "zs_" .. self:EntIndex() .. self.ShotCount

    -- 2. 热度累积 (Heat Buildup)
    self.RecoilAmount = self.RecoilAmount or 0
    self.RecoilAmount = math.min(self.RecoilAmount + (self.RecoilPerShot or 1), self.RecoilMax or 6)
    
    -- 根据热度计算额外的 "连射惩罚"
    local buildupMult = Lerp(self.RecoilAmount / (self.RecoilMax or 6), 1, self.RecoilModifierCap or 1.2)
    local finalMod = mod * buildupMult

    -- 3. 计算物理后坐力数值 (ViewAngles)
    local raw_up = (self.RecoilUp + util.SharedRandom(seed, 0, self.RecoilRandomUp)) * finalMod
    local side = util.SharedRandom(seed, -1, 1) * (self.RecoilSide + util.SharedRandom(seed.."s", 0, self.RecoilRandomSide)) * finalMod

    -- 4. 客户端处理：推入缓冲池 (Pending Pool)
    if CLIENT or game.SinglePlayer() then
        self.Recoil_Pending = self.Recoil_Pending or Angle(0, 0, 0)
        self.Recoil_RecoverPool = self.Recoil_RecoverPool or Angle(0, 0, 0)
        
        -- 垂直上限保护 (Source引擎中向上是负 Pitch)
        local max_up = self.RecoilMaxTotalUp or 45
        local current_total = self.Recoil_RecoverPool.p + self.Recoil_Pending.p
        
        -- 如果当前累积后坐力已经很高，限制新的输入
        if (current_total - raw_up) < -max_up then
            raw_up = math.max(0, current_total - (-max_up))
        end

        -- 将数值推入 "待处理" 池，CreateMove 会平滑地将其应用到视角
        self.Recoil_Pending.p = self.Recoil_Pending.p - raw_up
        self.Recoil_Pending.y = self.Recoil_Pending.y + side

        -- 5. 视觉效果触发 (Prediction Only)
        if IsFirstTimePredicted() then
            -- A. FOV 冲击
            self.CamFOV_Vel = (self.CamFOV_Vel or 0) + (self.CamRecoilFOV or 1.5) * finalMod
            
            -- B. 枪模物理冲击 (Visual Recoil Physics)
            self.VisRecoilAngVel = self.VisRecoilAngVel or Angle(0,0,0)
            self.VisRecoilVel = self.VisRecoilVel or Vector(0,0,0)

            local v_up = (self.VisualRecoilUp or -1.5) * finalMod
            local v_punch = (self.VisualRecoilPunch or 1.5) * finalMod
            local v_roll = (self.VisualRecoilRoll or 2.0) * finalMod
            local rand_roll = util.SharedRandom(seed.."vr_r", -1, 1)

            -- 施加角速度 (旋转)
            self.VisRecoilAngVel.p = self.VisRecoilAngVel.p + (v_up * 10) 
            self.VisRecoilAngVel.y = self.VisRecoilAngVel.y + (util.SharedRandom(seed.."vr_s", -1, 1) * 5 * finalMod)
            self.VisRecoilAngVel.r = self.VisRecoilAngVel.r + (v_roll * rand_roll * 10)

            -- 施加线速度 (位移/撞击)
            -- Y轴负方向通常是向后，Z轴正方向是向上
            self.VisRecoilVel = self.VisRecoilVel + Vector(0, -v_punch * 15, math.abs(v_up) * 2) 

            -- D. 镜头视角抖动 (Camera Punch/Shift)
            self.CamRecoilTarget = self.CamRecoilTarget or Angle(0, 0, 0)
            local c_up = (self.CamRecoilUp or 0) * finalMod
            local c_side = util.SharedRandom(seed.."cam_s", -1, 1) * (self.CamRecoilSide or 0) * finalMod

            -- 这里的逻辑是将视角“踢”到一个目标角度，ThinkRecoil 里的 Lerp 会负责平滑追赶
            self.CamRecoilTarget.p = self.CamRecoilTarget.p - c_up
            self.CamRecoilTarget.y = self.CamRecoilTarget.y + c_side

            -- E. 镜头滚转 (Roll) - 确保这里的变量名和配置一致
            self.CamRecoilRollVal = (self.CamRecoilRollVal or 0) + (util.SharedRandom(seed.."roll", -1, 1) * (self.CamRecoilRoll or 0) * finalMod)
        end
    end
    
    self.last_shot_time = CurTime()
end
