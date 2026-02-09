-- cl_inspect.lua

local key = 1
local keytime = 0

function SWEP:DoInspect()
    if not self.Inspect[key] then key = 1 end
    
    local info = self.Inspect[key]

    if keytime == 0 then
        keytime = CurTime() + info.time
    end

    if CurTime() > keytime and info.time > 0 then
        key = key + 1
        if not self.Inspect[key] then key = 1 end
        keytime = CurTime() + self.Inspect[key].time
    end
    
    self.keyframe = key
    self.IronPos = self:LerpCurveVec(1, self.IronPos, info.pos)
    self.IronAng = self:LerpCurveAng(1, self.IronAng, info.ang)
end

function SWEP:LerpCurveVec(a, b, c)
    local frame_time = self.Inspect[key].time
    local progress = self:inv_lerp(1, -1, math.cos(((CurTime() - (keytime - frame_time)) / frame_time) / self.InspectSpeed))
    return LerpVector(progress, b, c)
end

function SWEP:LerpCurveAng(a, b, c)
    local frame_time = self.Inspect[key].time
    local progress = self:inv_lerp(1, -1, math.cos(((CurTime() - (keytime - frame_time)) / frame_time) / self.InspectSpeed))
    return LerpAngle(progress, b, c)
end

function SWEP:inv_lerp(a, b, c)
    return (c - a) / (b - a)
end