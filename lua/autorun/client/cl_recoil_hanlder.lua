-- ==========================================
-- ARC9 风格丝滑视角控制系统
-- ==========================================

local function Dampen(val, target, speed, dt)
    return Lerp(1 - math.exp(-speed * dt), val, target)
end
-- ==========================================
-- ARC9 核心逻辑移植 (适配版)
-- ==========================================

local function approxEqualsZero(a)
    return math.abs(a) < 0.001
end
hook.Add("CreateMove", "ARC9_ZS_Recoil_System", function(cmd)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.Recoil_Enabled then return end

    -- 仅在客户端或单人模式有效
    if not (CLIENT or game.SinglePlayer()) then return end

    local ft = FrameTime()
    if ft == 0 then return end
    
    -- 初始化变量
    wep.Recoil_RecoverPool = wep.Recoil_RecoverPool or Angle(0, 0, 0)
    wep.Recoil_Pending = wep.Recoil_Pending or Angle(0, 0, 0)
    if not wep.LastEyeAngles then wep.LastEyeAngles = cmd:GetViewAngles() end

    local currentAngles = cmd:GetViewAngles()
    
    -- [阶段1] 鼠标输入补偿 (Mouse Input Compensation)
    -- 计算玩家这帧手动移动了多少鼠标
    local diff = wep.LastEyeAngles - currentAngles
    diff.p = math.NormalizeAngle(diff.p)
    diff.y = math.NormalizeAngle(diff.y)

    -- 如果玩家手动压枪，从"待恢复池"(RecoverPool)中扣除相应的量
    if not wep.RecoilAutoControl_DontTryToReturnBack then
        -- Pitch (垂直)
        if not approxEqualsZero(wep.Recoil_RecoverPool.p) then
            if wep.Recoil_RecoverPool.p < 0 then -- 枪口上扬中 (Source Pitch 为负)
                -- 玩家向下拉鼠标(diff.p < 0)，RecoilPool 变小(绝对值变小)，即更接近0
                wep.Recoil_RecoverPool.p = math.Clamp(wep.Recoil_RecoverPool.p - diff.p, wep.Recoil_RecoverPool.p, 0)
            elseif wep.Recoil_RecoverPool.p > 0 then
                wep.Recoil_RecoverPool.p = math.Clamp(wep.Recoil_RecoverPool.p - diff.p, 0, wep.Recoil_RecoverPool.p)
            end
        end
        -- Yaw (水平)
        if not approxEqualsZero(wep.Recoil_RecoverPool.y) then
             if wep.Recoil_RecoverPool.y > 0 then
                wep.Recoil_RecoverPool.y = math.Clamp(wep.Recoil_RecoverPool.y, 0, wep.Recoil_RecoverPool.y - diff.y)
            elseif wep.Recoil_RecoverPool.y < 0 then
                wep.Recoil_RecoverPool.y = math.Clamp(wep.Recoil_RecoverPool.y, wep.Recoil_RecoverPool.y - diff.y, 0)
            end
        end
    end
    wep.Recoil_RecoverPool:Normalize()

    -- [阶段2] 新后坐力注入 (Injection)
    -- 将 Pending 池中的后坐力平滑地加到 ViewAngles 和 RecoverPool
    local kick_speed = ft * 60 
    local progress = math.min(1, kick_speed)

    local apply_p = wep.Recoil_Pending.p * progress
    local apply_y = wep.Recoil_Pending.y * progress
    
    -- 从 Pending 转移到实际视角
    wep.Recoil_Pending.p = wep.Recoil_Pending.p - apply_p
    wep.Recoil_Pending.y = wep.Recoil_Pending.y - apply_y
    
    currentAngles.p = currentAngles.p + apply_p
    currentAngles.y = currentAngles.y + apply_y
    
    -- 记录到 RecoverPool (以便后续自动回正)
    wep.Recoil_RecoverPool.p = wep.Recoil_RecoverPool.p + apply_p
    wep.Recoil_RecoverPool.y = wep.Recoil_RecoverPool.y + apply_y


    -- [阶段3] 自动回正
    local timeSinceLastShot = CurTime() - (wep.last_shot_time or 0)
    -- 判定是否在回正状态：(换弹中) 或 (停止射击已达延迟时间)
    local isReloading = wep.IsReloadingRecoil or (wep.GetReloading and wep:GetReloading())

    if not wep.RecoilAutoControl_DontTryToReturnBack and (isReloading or timeSinceLastShot > (wep.RecoilAutoControlTime or 0.1)) then
        local speed_mult = isReloading and 1.0 or 1.0
        local auto_control = (wep.RecoilAutoControl + (wep.ShotCount or 0) * (wep.RecoilAutoControl_PerShot or 0)) / 10 * speed_mult
        
        local recreset = wep.Recoil_RecoverPool * auto_control * ft
        
        -- 只要池子里还有角度，就继续拉回视角
        if math.abs(wep.Recoil_RecoverPool.p) > 0.001 or math.abs(wep.Recoil_RecoverPool.y) > 0.001 then
            currentAngles.p = currentAngles.p - recreset.p
            currentAngles.y = currentAngles.y - recreset.y
            
            wep.Recoil_RecoverPool.p = wep.Recoil_RecoverPool.p - recreset.p
            wep.Recoil_RecoverPool.y = wep.Recoil_RecoverPool.y - recreset.y
        else
            -- 回正完毕，彻底清理
            wep.Recoil_RecoverPool = Angle(0, 0, 0)
            wep.IsReloadingRecoil = false -- 停止换弹回正逻辑
        end
    end
    wep.Recoil_RecoverPool:Normalize()

    -- [阶段4] 应用最终视角
    cmd:SetViewAngles(currentAngles)
    wep.LastEyeAngles = currentAngles -- 记录本帧最终视角，供下一帧计算鼠标移动
end)

-- ====================================================================================
--  客户端逻辑：FOV 物理震动 (CalcView Hook)
-- ====================================================================================

hook.Add("CalcView", "ARC9_ZS_Camera_Physics", function(ply, pos, ang, fov)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.Recoil_Enabled then return end

    -- ==========================================
    -- 1. FOV 弹簧物理 (保持你原有的逻辑)
    -- ==========================================
    wep.CamFOV_Val = wep.CamFOV_Val or 0
    wep.CamFOV_Vel = wep.CamFOV_Vel or 0

    local ft = RealFrameTime()
    if ft > 0.1 then ft = 0.1 end 

    local stiffness = wep.CamRecoilFOVStiffness or 300
    local damping = wep.CamRecoilDamping or 10
    
    local force = -(wep.CamFOV_Val * stiffness) - (wep.CamFOV_Vel * damping)
    wep.CamFOV_Vel = wep.CamFOV_Vel + (force * ft)
    wep.CamFOV_Val = wep.CamFOV_Val + (wep.CamFOV_Vel * ft)

    -- ==========================================
    -- 2. 应用镜头偏移 (修复 Up, Side, Roll)
    -- ==========================================
    
    -- 应用 Up (Pitch) 和 Side (Yaw) 的平滑抖动
    -- 这些值是在 ThinkRecoil 函数里通过 LerpAngle 算出来的
    if wep.CamRecoilCurrent then
        ang.p = ang.p + wep.CamRecoilCurrent.p
        ang.y = ang.y + wep.CamRecoilCurrent.y
    end

    -- 应用 Roll (镜头滚转)
    -- 这个值是在 ApplyRecoil 里增加，在 ThinkRecoil 里回正的
    if wep.CamRecoilRollVal then
        ang.r = ang.r + wep.CamRecoilRollVal
    end

    -- ==========================================
    -- 3. 返回最终视图
    -- ==========================================
    return {
        origin = pos, 
        angles = ang, -- 现在这里的 ang 包含了 Pitch, Yaw 和 Roll 的偏移
        fov = fov + wep.CamFOV_Val,
        drawviewer = false
    }
end)