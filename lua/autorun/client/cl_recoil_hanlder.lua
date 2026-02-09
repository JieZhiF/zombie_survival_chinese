-- cl_recoil_handle.lua

hook.Add("CreateMove", "ARC9_ZS_Camera_System", function(cmd)
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.Recoil_Enabled then
        local ft = FrameTime()
        if ft == 0 then return end
        local ct = CurTime()

        -- 初始化变量
        wep.Recoil_PermanentPool = wep.Recoil_PermanentPool or Angle(0,0,0)
        wep.Recoil_RecoverPool = wep.Recoil_RecoverPool or Angle(0,0,0)
        wep.CamRecoilCurrent = wep.CamRecoilCurrent or Angle(0,0,0)
        wep.CamRecoilTarget = wep.CamRecoilTarget or Angle(0,0,0)
        wep.CamRecoilRollVal = wep.CamRecoilRollVal or 0

        -- 1. 回正逻辑 (只针对 RecoverPool 和 Cam 效果)
        local is_recovering = ct > (wep.last_shot_time + (wep.RecoilResetTime or 0.15))
        local recovery_speed = is_recovering and (wep.RecoilDissipationRate or 8) or (wep.RecoilAutoControl or 3)
        
        local dissipate = recovery_speed * ft * 10
        -- 恢复池回正
        wep.Recoil_RecoverPool.p = math.Approach(wep.Recoil_RecoverPool.p, 0, math.abs(wep.Recoil_RecoverPool.p) * dissipate + 0.05 * ft)
        wep.Recoil_RecoverPool.y = math.Approach(wep.Recoil_RecoverPool.y, 0, math.abs(wep.Recoil_RecoverPool.y) * dissipate + 0.05 * ft)

        -- 镜头效果回正
        wep.CamRecoilTarget = LerpAngle(5 * ft, wep.CamRecoilTarget, Angle(0,0,0))
        wep.CamRecoilRollVal = Lerp(10 * ft, wep.CamRecoilRollVal, 0)
        wep.CamRecoilCurrent = LerpAngle(20 * ft, wep.CamRecoilCurrent, wep.CamRecoilTarget)

        -- 2. 【核心修复：ViewAngle 综合应用】
        local viewAng = cmd:GetViewAngles()
        
        -- 撤销上一帧的应用量 (Anti-Drift)
        if wep.last_frame_total_offset then
            viewAng = viewAng - wep.last_frame_total_offset
        end
        
        -- 计算当前帧的总后坐力：永久池 + 恢复池 + 视觉镜头偏移
        local current_offset = Angle(
            wep.Recoil_PermanentPool.p + wep.Recoil_RecoverPool.p + wep.CamRecoilCurrent.p,
            wep.Recoil_PermanentPool.y + wep.Recoil_RecoverPool.y + wep.CamRecoilCurrent.y,
            wep.CamRecoilRollVal -- Roll 推荐全额回复
        )

        -- 应用到最终视角
        cmd:SetViewAngles(viewAng + current_offset)
        
        -- 记录这一帧的量，供下一帧撤销
        wep.last_frame_total_offset = current_offset
    end
end)
hook.Add("CalcView", "ARC9_ZS_FOV_Control", function(ply, pos, ang, fov)
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) and wep.Recoil_Enabled and wep.RecoilFOV then
        wep.RecoilFOV = Lerp(FrameTime() * 10, wep.RecoilFOV, 0)
        return { origin = pos, angles = ang, fov = fov + wep.RecoilFOV }
    end
end)