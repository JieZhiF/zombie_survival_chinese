-- cl_viewmodel.lua

function SWEP:ThinkVisualRecoil()
    local ft = FrameTime()
    if ft == 0 or ft > 0.1 then return end

    local stiffness = self.VisualRecoilStiffness or 80
    local damping = self.VisualRecoilDamping or 10

    -- 初始化变量
    self.VisRecoilPos = self.VisRecoilPos or Vector(0,0,0)
    self.VisRecoilVel = self.VisRecoilVel or Vector(0,0,0)
    self.VisRecoilAcc = self.VisRecoilAcc or Vector(0,0,0)
    self.VisRecoilAng = self.VisRecoilAng or Angle(0,0,0)
    self.VisRecoilAngVel = self.VisRecoilAngVel or Angle(0,0,0)
    self.VisRecoilAngAcc = self.VisRecoilAngAcc or Angle(0,0,0)

    -- Verlet 积分计算位移 (Pos)
    self.VisRecoilPos = self.VisRecoilPos + (self.VisRecoilVel * ft) + (self.VisRecoilAcc * ft * ft * 0.5)
    local n_acc = (-self.VisRecoilPos * stiffness) - (self.VisRecoilVel * damping)
    self.VisRecoilVel = self.VisRecoilVel + ((self.VisRecoilAcc + n_acc) * (ft * 0.5))
    self.VisRecoilAcc = n_acc

    -- Verlet 积分计算旋转 (Ang)
    local function SolveAng(cur, vel, acc)
        local n_cur = cur + (vel * ft) + (acc * ft * ft * 0.5)
        local n_acc = (-cur * stiffness) - (vel * damping)
        return n_cur, vel + ((acc + n_acc) * (ft * 0.5)), n_acc
    end
    
    local p, pv, pa = SolveAng(self.VisRecoilAng.p, self.VisRecoilAngVel.p, self.VisRecoilAngAcc.p)
    local y, yv, ya = SolveAng(self.VisRecoilAng.y, self.VisRecoilAngVel.y, self.VisRecoilAngAcc.y)
    local r, rv, ra = SolveAng(self.VisRecoilAng.r, self.VisRecoilAngVel.r, self.VisRecoilAngAcc.r)
    
    self.VisRecoilAng = Angle(p, y, r)
    self.VisRecoilAngVel = Angle(pv, yv, rv)
    self.VisRecoilAngAcc = Angle(pa, ya, ra)
end

local ghostlerp = 0
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
    local owner = self:GetOwner()
    if not IsValid(owner) then return pos, ang end

    -- 1. 弹簧后坐力计算
    self:ThinkVisualRecoil()

    -- 2. 瞄准过渡计算
    self.CurrentIronPos = self.CurrentIronPos or Vector(0, 0, 0)
    self.CurrentIronAng = self.CurrentIronAng or Angle(0, 0, 0)
    
    local bIron = self:GetIronsights() and not (GAMEMODE and GAMEMODE.NoIronsights)
    
    -- 追踪 fIronTime 用于原生瞄准镜支持
    if bIron ~= self.bLastIron then
        self.bLastIron = bIron
        self.fIronTime = bIron and CurTime() or nil
    end

    local target_pos = bIron and self.IronSightsPos or Vector(0,0,0)
    local target_ang = bIron and self.IronSightsAng or Angle(0,0,0)
    if isvector(target_ang) then
        target_ang = Angle(target_ang.x, target_ang.y, target_ang.z)
    end
    
    -- 同样确保 target_pos 是 Vector
    if isangle(target_pos) then
        target_pos = Vector(target_pos.p, target_pos.y, target_pos.r)
    end
    self.CurrentIronPos = LerpVector(RealFrameTime() * self.IronSpeed, self.CurrentIronPos, target_pos)
    self.CurrentIronAng = LerpAngle(RealFrameTime() * self.IronSpeed, self.CurrentIronAng, target_ang)

    -- 3. 动态运动 (Sway / Bob)
    local vel = owner:GetVelocity()
    local vel_forward = vel:Dot(oldang:Forward())
    local vel_right = vel:Dot(oldang:Right())
    
    local sway_roll = -vel_right * self.SwayAmount * (bIron and 0.3 or 1)
    local bob_forward = -vel_forward * self.BobAmount * (bIron and 0.1 or 1)
    
    self.CurrentSwayAngle = LerpAngle(RealFrameTime() * self.MovementLerpSpeed, self.CurrentSwayAngle or Angle(0,0,0), Angle(0, 0, sway_roll))
    self.CurrentBobVector = LerpVector(RealFrameTime() * self.MovementLerpSpeed, self.CurrentBobVector or Vector(0,0,0), Vector(0, bob_forward, 0))

    -- 4. 呼吸感
    self.Breath = math.sin(CurTime()) / (self.Breathmult * (bIron and 80 or 4))

    -- 5. 应用变换
    ang = Angle(ang.p, ang.y, ang.r)
    
    -- 应用机械瞄准旋转与位移
    ang:RotateAroundAxis(ang:Right(), self.CurrentIronAng.p)
    ang:RotateAroundAxis(ang:Up(),    self.CurrentIronAng.y)
    ang:RotateAroundAxis(ang:Forward(), self.CurrentIronAng.r)
    
    pos = pos + (self.CurrentIronPos.x * ang:Right()) + (self.CurrentIronPos.y * ang:Forward()) + (self.CurrentIronPos.z * ang:Up())

    -- 应用视觉后坐力 (ARC9 弹簧)
    if self.VisRecoilAng then
        ang:RotateAroundAxis(ang:Right(),   self.VisRecoilAng.p)
        ang:RotateAroundAxis(ang:Up(),      self.VisRecoilAng.y)
        ang:RotateAroundAxis(ang:Forward(), self.VisRecoilAng.r)
    end
    if self.VisRecoilPos then
        pos = pos + ang:Forward() * self.VisRecoilPos.x + ang:Right() * self.VisRecoilPos.y + ang:Up() * self.VisRecoilPos.z
    end

    -- 应用 Sway/Bob/呼吸/Offset
    ang:RotateAroundAxis(ang:Forward(), self.CurrentSwayAngle.r)
    pos = pos + (ang:Forward() * self.CurrentBobVector.y)
    pos = pos + (ang:Up() * self.Breath)
    pos = pos + (ang:Forward() * (self.offset or 0))

    -- 幽灵模式偏移 (NearWall)
    if owner:GetBarricadeGhosting() then ghostlerp = math.min(1, ghostlerp + FrameTime() * 4)
    else ghostlerp = math.max(0, ghostlerp - FrameTime() * 5) end
    if ghostlerp > 0 then
        pos = pos + 3.5 * ghostlerp * ang:Up()
        ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
    end

    -- 基础 VM 修正
    if self.VMAng and self.VMPos then
        ang:RotateAroundAxis(ang:Right(), self.VMAng.x)
        ang:RotateAroundAxis(ang:Up(), self.VMAng.y)
        ang:RotateAroundAxis(ang:Forward(), self.VMAng.z)
        pos = pos + (ang:Right() * self.VMPos.x) + (ang:Forward() * self.VMPos.y) + (ang:Up() * self.VMPos.z)
    end

    return pos, ang
end

function SWEP:ViewModelDrawn()
	self:Anim_ViewModelDrawn()
end

