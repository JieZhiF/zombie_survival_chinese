-- sh_think.lua

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    -- 1. 瞄准逻辑：如果不按住右键则退出瞄准 (非切换模式)
    if self:GetIronsights() and not owner:KeyDown(IN_ATTACK2) then
        self:SetIronsights(false)
    end

    -- 2. 装填结束检测
    if self:GetReloadFinish() > 0 then
        if CurTime() >= self:GetReloadFinish() then
            self:FinishReload()
        end
    -- 3. 闲置动画恢复
    elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
        self.IdleAnimation = nil
        self:SendWeaponAnim(self.IdleActivity)
    end

    -- 4. 客户端视觉偏移回归 (针对 ShootBullets 产生的 offset)
    if CLIENT then
        self.offset = Lerp(RealFrameTime() * 10, self.offset or 0, 0)
    end
    
    -- 5. 后坐力平滑处理 (仅限客户端镜头)
    if CLIENT then
        self:ThinkRecoil()
    end
end
function SWEP:ThinkRecoil()
    local ct = CurTime()
    local ft = FrameTime()
    local rft = RealFrameTime()
    if ft == 0 then return end

    -- 安全获取变量，如果为 nil 则默认为 0
    local last_shot = self.last_shot_time or 0
    local recoil_amount = self.RecoilAmount or 0
    
    -- 1. 后坐力热度消散
    if ct > (last_shot + (self.RecoilResetTime or 0.1)) then
        if recoil_amount > 0 then
            local decay = ft * (self.RecoilDissipationRate or 10)
            self.RecoilAmount = math.max(recoil_amount - decay, 0)
        end
    end

    -- 如果正在换弹，且准星已经回正了，就关闭标记
    if self.IsReloadingRecoil and self.Recoil_RecoverPool then
        if math.abs(self.Recoil_RecoverPool.p) < 0.001 then
            self.IsReloadingRecoil = false
        end
    end
    if (ct - self.last_shot_time)  > (self.RecoilAutoControlTime or 0.1) then -- 已经停火超过自动回正时间，重置连射计数
        self.ShotCount = 0  -- 连射计数重置
    end
    -- ==========================================
    -- 2. [仅客户端] 视觉平滑处理 (ARC9 镜头感)
    -- ==========================================
    if CLIENT then
        -- A. 镜头角度平滑回正 (你提供的逻辑)
        self.CamRecoilCurrent = self.CamRecoilCurrent or Angle(0,0,0)
        self.CamRecoilTarget = self.CamRecoilTarget or Angle(0,0,0)
        
        -- lerp_speed 决定了镜头回位的响应速度 (15-25 比较丝滑)
        local lerp_speed = self.CamRecoilLerpSpeed or 20
        -- 第一步：当前值追赶目标值
        self.CamRecoilCurrent = LerpAngle(rft * lerp_speed, self.CamRecoilCurrent, self.CamRecoilTarget)
        -- 第二步：目标值缓慢归零
        self.CamRecoilTarget = LerpAngle(rft * 10, self.CamRecoilTarget, Angle(0,0,0))
        
        -- B. 镜头 Roll (滚转) 回正
        self.CamRecoilRollVal = math.Approach(self.CamRecoilRollVal or 0, 0, rft * (self.RecoilDissipationRate or 10) * 5)

        -- C. FOV 弹簧物理处理 (之前添加的逻辑)
        -- 如果你有 FOV 弹簧系统，也应在此处调用或处理
        if self.CamFOV_Val then
            local stiffness = self.CamRecoilFOVStiffness or 300
            local damping = self.CamRecoilFOVDamping or 10
            local force = -(self.CamFOV_Val * stiffness) - (self.CamFOV_Vel * damping)
            self.CamFOV_Vel = self.CamFOV_Vel + (force * rft)
            self.CamFOV_Val = self.CamFOV_Val + (self.CamFOV_Vel * rft)
        end

    end
end