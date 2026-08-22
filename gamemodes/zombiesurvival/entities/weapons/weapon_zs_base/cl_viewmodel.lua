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

	-- 2. 机械瞄准过渡 (Iron Sights) —— ARC9 风格：双端共享的平滑进度 + 缓动曲线
	self.CurrentIronPos = self.CurrentIronPos or Vector(0, 0, 0)
	self.CurrentIronAng = self.CurrentIronAng or Angle(0, 0, 0)

	-- [过渡进度] 进入用 OutBack/InOutSine 混合，退出用 InOutQuad/InQuad 混合
	local delta = self.GetIronsightDelta and self:GetIronsightDelta() or 0
	local eased = 0
	if delta > 0 then
		if self:GetIronsights() then
			eased = Lerp(0.25, math.ease.OutBack(delta), math.ease.InOutSine(delta))
		else
			eased = Lerp(0.7, math.ease.InOutQuad(delta), math.ease.InQuad(delta))
		end
	end
	eased = math.Clamp(eased, 0, 1)

	local iron_pos = self.IronSightsPos or vector_origin
	local iron_ang = self.IronSightsAng or angle_zero

	-- 类型修正
	if isvector(iron_ang) then iron_ang = Angle(iron_ang.x, iron_ang.y, iron_ang.z) end
	if isangle(iron_pos) then iron_pos = Vector(iron_pos.p, iron_pos.y, iron_pos.r) end

	-- [姿势参数] 模型自带 sights 时由动画本身完成贴瞄（ARC9 双轨制同款），手动偏移让位避免双重移动
	-- 武器可设 DisableSightsPoseParam = true 强制走手动偏移路线
	if self.DisableSightsPoseParam ~= true then
		local mdl = vm:GetModel()
		if self.m_SightsPPModel ~= mdl then
			self.m_SightsPPModel = mdl
			self.m_SightsPPIdx = vm:LookupPoseParameter("sights") or -1
			if self.m_SightsPPIdx >= 0 then
				self.m_SightsPPRangeMin, self.m_SightsPPRangeMax = vm:GetPoseParameterRange(self.m_SightsPPIdx)
			end
		end
		if self.m_SightsPPIdx and self.m_SightsPPIdx >= 0 then
			vm:SetPoseParameter(self.m_SightsPPIdx, Lerp(eased, self.m_SightsPPRangeMin or 0, self.m_SightsPPRangeMax or 1))
			iron_pos, iron_ang = vector_origin, angle_zero
		end
	end

	local target_pos = iron_pos * eased
	local target_ang = iron_ang * eased

	local ft = RealFrameTime()
	self.CurrentIronPos = LerpVector(ft * (self.IronSpeed or 10), self.CurrentIronPos, target_pos)
	self.CurrentIronAng = LerpAngle(ft * (self.IronSpeed or 10), self.CurrentIronAng, target_ang)

    -- 3. 动态晃动 (Sway & Bob)
    local vel = owner:GetVelocity()
    local vel_len = vel:Length2D()
    local vel_forward = vel:Dot(oldang:Forward())
    local vel_right = vel:Dot(oldang:Right())
    
    local sway_roll = -vel_right * (self.SwayAmount or 0.5) * Lerp(eased, 1, 0.3)
    local bob_forward = -vel_forward * (self.BobAmount or 0.5) * Lerp(eased, 1, 0.1)
    
    self.CurrentSwayAngle = LerpAngle(ft * (self.MovementLerpSpeed or 5), self.CurrentSwayAngle or Angle(0,0,0), Angle(0, 0, sway_roll))
    self.CurrentBobVector = LerpVector(ft * (self.MovementLerpSpeed or 5), self.CurrentBobVector or Vector(0,0,0), Vector(0, bob_forward, 0))

    -- 4. 呼吸效果
    self.Breath = math.sin(CurTime()) / ((self.Breathmult or 1) * Lerp(eased, 4, 80))

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
    --    幅度即作者所写：开镜/腰射两套参数组在 sh_recoil 注入时已交叉插值，此处不再二次缩放
    -- ===========================================================
    if self.UseVisualRecoil and self.VisRecoilPos and self.VisRecoilAng then
        local center = self.VisualRecoilCenter or Vector(0, 0, 0)
        local vrPos = self.VisRecoilPos
        local vrAng = self.VisRecoilAng

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