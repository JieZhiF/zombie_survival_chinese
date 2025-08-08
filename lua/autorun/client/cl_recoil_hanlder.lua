-- =================================================================
-- == 全局通用后坐力系统 (Universal Recoil System)
-- == 只需一个钩子，即可处理所有启用该系统的武器。
-- =================================================================

hook.Add("CreateMove", "UniversalRecoilSystem", function(cmd)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()

    -- 检查当前武器是否有效，并且是否启用了我们的通用后坐力系统
    if IsValid(wep) and wep.Recoil_Enabled then
        -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        -- 如果当前武器启用了后坐力，则执行后坐力计算
        -- 这段代码与您之前的版本几乎完全相同
        -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        local curTime = CurTime()
        local frameTime = FrameTime()
        local currentAngles = cmd:GetViewAngles()

        -- 初始化变量 (如果武器脚本中没有，则使用默认值)
        wep.current_recoil_offset = wep.current_recoil_offset or Angle(0, 0, 0)
        wep.last_frame_recoil_offset = wep.last_frame_recoil_offset or Angle(0, 0, 0)
        wep.recoil_punch = wep.recoil_punch or Angle(0, 0, 0)
        wep.last_shot_time = wep.last_shot_time or 0
        wep.recoil_progressive_multiplier = wep.recoil_progressive_multiplier or 1.0

        -- 减去上一帧的后坐力
        currentAngles = currentAngles - wep.last_frame_recoil_offset

        -- 后坐力恢复与衰减
        local targetRecoil = Angle(0, 0, 0)
        local decayRate = wep.Recoil_Decay_Rate or 5

        if curTime > wep.last_shot_time + (wep.Recoil_Recovery_Time or 0.15) then
            decayRate = wep.Recoil_Recovery_Speed or 8

            if not wep.recovery_target_angle then
                local recoveryPct = wep.Recoil_Recovery_Percentage or 1.0
                wep.recovery_target_angle = wep.recoil_punch * (1 - recoveryPct)
            end
            targetRecoil = wep.recovery_target_angle
        else
            if curTime > wep.last_shot_time + (wep.Recoil_Progressive_Reset_Time or 0.2) then
                wep.recoil_progressive_multiplier = 1.0
            end
        end

        wep.recoil_punch = LerpAngle(frameTime * decayRate, wep.recoil_punch, targetRecoil)
        wep.current_recoil_offset = LerpAngle(frameTime * (wep.Recoil_Smoothing_Factor or 15), wep.current_recoil_offset, wep.recoil_punch)

        cmd:SetViewAngles(currentAngles + wep.current_recoil_offset)
        wep.last_frame_recoil_offset = wep.current_recoil_offset
        ply.LastActiveWeaponForRecoil = wep
    end
end)