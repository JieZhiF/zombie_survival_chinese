-- sh_deploy.lua

function SWEP:Deploy()
    self:SetNextReload(0)
    self:SetReloadFinish(0)
    self:ResetRecoilState(false)

    if GAMEMODE then
        gamemode.Call("WeaponDeployed", self:GetOwner(), self)
    end

    self:SetIronsights(false)
    self.IdleAnimation = CurTime() + self:SequenceDuration()
    
    if CLIENT then
        self:CheckCustomIronSights()
        -- 处理自动检视逻辑
        if self.InspectOnDeploy then
            self.deploytime = CurTime() + self.DeployInspectTime
        else
            self.deploytime = 0
        end
    end

    --self:CreateModels(self.VElements)
    return true
end

function SWEP:Holster()
    if CLIENT then
        self:Anim_Holster()
    end
    self:ResetRecoilState(false)

    return true
end

function SWEP:OnRemove()
    if CLIENT then
        self:Anim_OnRemove()
    end
end