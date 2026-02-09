-- sh_sights.lua
function SWEP:GetIronsightsDeltaMultiplier()
	local bIron = self:GetIronsights()
	local fIronTime = self.fIronTime or 0

	if not bIron and fIronTime < CurTime() - 0.25 then
		return 0 -- 如果不在瞄准且过渡期已过，则为 0
	end

	local Mul = 1

	-- 根据进入/退出瞄准的时间计算过渡进度
	if fIronTime > CurTime() - 0.25 then
		Mul = math.Clamp((CurTime() - fIronTime) * 4, 0, 1)
		if not bIron then Mul = 1 - Mul end -- 退出瞄准时反转进度
	end

	return Mul
end

function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		self:SetIronsights(true)
	end
end


function SWEP:SetIronsights(b)
    self:SetDTBool(0, b)
    local hold = b and self.IronSightsHoldType or self.HoldType
    if hold then self:SetWeaponHoldType(hold) end
    
    if GAMEMODE then
        gamemode.Call("WeaponDeployed", self:GetOwner(), self)
    end
end

function SWEP:GetIronsights()
    return self:GetDTBool(0)
end

function SWEP:GetWalkSpeed()
    if self:GetIronsights() then
        return math.min(self.WalkSpeed, math.max(90, self.WalkSpeed * (self:GetOwner().Wooism and 0.75 or 0.5)))
    end
    return self.WalkSpeed
end

if CLIENT then
    local OverrideIronSights = {}
    function SWEP:CheckCustomIronSights()
        local class = self:GetClass()
        if OverrideIronSights[class] then
            if type(OverrideIronSights[class]) == "table" then
                self.IronSightsPos = OverrideIronSights[class].Pos
                self.IronSightsAng = OverrideIronSights[class].Ang
            end
            return
        end

        local filename = "ironsights/" .. class .. ".txt"
        if file.Exists(filename, "MOD") then
            local content = file.Read(filename, "MOD")
            local tab = string.Explode(" ", content)
            local pos = Vector(tonumber(tab[1]) or 0, tonumber(tab[2]) or 0, tonumber(tab[3]) or 0)
            local ang = Angle(tonumber(tab[4]) or 0, tonumber(tab[5]) or 0, tonumber(tab[6]) or 0)
            OverrideIronSights[class] = {Pos = pos, Ang = ang}
            self.IronSightsPos, self.IronSightsAng = pos, ang
        else
            OverrideIronSights[class] = true
        end
    end
        function SWEP:TranslateFOV(fov)
        -- 此处逻辑与特定游戏模式（如 ZS）紧密相关，用于在瞄准时缩放FOV。
        return (GAMEMODE.FOVLerp + (self.IsScoped and not GAMEMODE.DisableScopes and 0 or (1 - GAMEMODE.FOVLerp) * (1 - GAMEMODE.IronsightZoomScale))) * fov
    end

    function SWEP:AdjustMouseSensitivity()
        -- 当进入机械瞄准状态时，返回一个灵敏度乘数。
        if self:GetIronsights() then
            return GAMEMODE.FOVLerp + (self.IsScoped and not GAMEMODE.DisableScopes and 0 or (1 - GAMEMODE.FOVLerp) * (1 - GAMEMODE.IronsightZoomScale))
        end
    end

end

function SWEP:OnRestore()
	self:SetIronsights(false)
end
