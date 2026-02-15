-- cl_viewmodel.lua
local function RotateAroundPoint(pos, ang, center, offset, rot)
    local mat = Matrix()
    mat:Translate(pos)
    mat:Rotate(ang)
    mat:Translate(center)
    mat:Rotate(rot)
    mat:Translate(offset)
    mat:Translate(-center)
    return mat:GetTranslation(), mat:GetAngles()
end
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

    -- [物理计算] 确保物理逻辑在渲染前更新
    if self.ThinkVisualRecoil then self:ThinkVisualRecoil() end

    -- 1. 基础 VM 修正 (Offset)
    if self.VMAng and self.VMPos then
        ang:RotateAroundAxis(ang:Right(), self.VMAng.x)
        ang:RotateAroundAxis(ang:Up(), self.VMAng.y)
        ang:RotateAroundAxis(ang:Forward(), self.VMAng.z)
        pos = pos + (ang:Right() * self.VMPos.x) + (ang:Forward() * self.VMPos.y) + (ang:Up() * self.VMPos.z)
    end

    -- 2. 机械瞄准过渡 (Iron Sights)
    self.CurrentIronPos = self.CurrentIronPos or Vector(0, 0, 0)
    self.CurrentIronAng = self.CurrentIronAng or Angle(0, 0, 0)
    
    local bIron = self:GetIronsights() and not (GAMEMODE and GAMEMODE.NoIronsights)
    
    if bIron ~= self.bLastIron then
        self.bLastIron = bIron
        self.fIronTime = bIron and CurTime() or nil
    end

    local target_pos = bIron and self.IronSightsPos or Vector(0,0,0)
    local target_ang = bIron and self.IronSightsAng or Angle(0,0,0)
    
    -- 类型修正
    if isvector(target_ang) then target_ang = Angle(target_ang.x, target_ang.y, target_ang.z) end
    if isangle(target_pos) then target_pos = Vector(target_pos.p, target_pos.y, target_pos.r) end
    
    local ft = RealFrameTime()
    self.CurrentIronPos = LerpVector(ft * (self.IronSpeed or 10), self.CurrentIronPos, target_pos)
    self.CurrentIronAng = LerpAngle(ft * (self.IronSpeed or 10), self.CurrentIronAng, target_ang)

    -- 3. 动态晃动 (Sway & Bob)
    local vel = owner:GetVelocity()
    local vel_len = vel:Length2D()
    local vel_forward = vel:Dot(oldang:Forward())
    local vel_right = vel:Dot(oldang:Right())
    
    local sway_roll = -vel_right * (self.SwayAmount or 0.5) * (bIron and 0.3 or 1)
    local bob_forward = -vel_forward * (self.BobAmount or 0.5) * (bIron and 0.1 or 1)
    
    self.CurrentSwayAngle = LerpAngle(ft * (self.MovementLerpSpeed or 5), self.CurrentSwayAngle or Angle(0,0,0), Angle(0, 0, sway_roll))
    self.CurrentBobVector = LerpVector(ft * (self.MovementLerpSpeed or 5), self.CurrentBobVector or Vector(0,0,0), Vector(0, bob_forward, 0))

    -- 4. 呼吸效果
    self.Breath = math.sin(CurTime()) / ((self.Breathmult or 1) * (bIron and 80 or 4))

    -- 5. 应用基础变换
    ang = Angle(ang.p, ang.y, ang.r) -- 复制以防修改原引用
    
    -- 应用机瞄旋转
    ang:RotateAroundAxis(ang:Right(), self.CurrentIronAng.p)
    ang:RotateAroundAxis(ang:Up(),    self.CurrentIronAng.y)
    ang:RotateAroundAxis(ang:Forward(), self.CurrentIronAng.r)
    
    -- 应用机瞄位移
    pos = pos + (self.CurrentIronPos.x * ang:Right()) + (self.CurrentIronPos.y * ang:Forward()) + (self.CurrentIronPos.z * ang:Up())

    -- ===========================================================
    -- 6. [核心] 应用视觉后坐力 (Visual Recoil)
    -- ===========================================================
    if self.UseVisualRecoil and self.VisRecoilPos and self.VisRecoilAng then
        local center = self.VisualRecoilCenter or Vector(0, 0, 0)
        local vrPos = self.VisRecoilPos
        local vrAng = self.VisRecoilAng

        -- 机瞄时减弱视觉抖动，保证瞄准稳定性
        if bIron then
            vrPos = vrPos * 0.5 
            vrAng = vrAng * 0.5
        end

        -- 使用矩阵绕点旋转应用后坐力
        pos, ang = RotateAroundPoint(pos, ang, center, vrPos, vrAng)
    end
    -- ===========================================================

    -- 7. 叠加 Sway/Bob/呼吸/Offset
    ang:RotateAroundAxis(ang:Forward(), self.CurrentSwayAngle.r)
    pos = pos + (ang:Forward() * self.CurrentBobVector.y)
    pos = pos + (ang:Up() * self.Breath)
    pos = pos + (ang:Forward() * (self.offset or 0))

    -- 8. 幽灵模式 (靠近墙壁)
    if owner:GetBarricadeGhosting() then 
        ghostlerp = math.min(1, ghostlerp + ft * 4)
    else 
        ghostlerp = math.max(0, ghostlerp - ft * 5) 
    end
    
    if ghostlerp > 0 then
        pos = pos + 3.5 * ghostlerp * ang:Up()
        ang:RotateAroundAxis(ang:Right(), -30 * ghostlerp)
    end

    return pos, ang
end

function SWEP:ViewModelDrawn()
    if self.Anim_ViewModelDrawn then
        self:Anim_ViewModelDrawn()
    end
end