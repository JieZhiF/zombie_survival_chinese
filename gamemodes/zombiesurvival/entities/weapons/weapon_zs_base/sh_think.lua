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

if CLIENT then
    function SWEP:ThinkRecoil()
        -- 处理镜头后坐力回正 (CamRecoil)
        self.CamRecoilCurrent = self.CamRecoilCurrent or Angle(0,0,0)
        self.CamRecoilTarget = self.CamRecoilTarget or Angle(0,0,0)
        
        local lerp_speed = 15
        self.CamRecoilCurrent = LerpAngle(RealFrameTime() * lerp_speed, self.CamRecoilCurrent, self.CamRecoilTarget)
        self.CamRecoilTarget = LerpAngle(RealFrameTime() * 10, self.CamRecoilTarget, Angle(0,0,0))
    end
end