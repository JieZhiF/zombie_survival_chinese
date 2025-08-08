AddCSLuaFile()

SWEP.Base = "weapon_zs_t_doomorgan"

SWEP.PrintName = "光之契约"
SWEP.Description = "左键使用后，你变为英雄，持续150s，时间结束后，你立即死亡."

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:SetNextPrimaryFire(CurTime() + 99999) -- 使用后冷却锁定

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    if SERVER then
        -- 播放音效
        owner:EmitSound("weapons/bugbait/bugbait_squeeze3.wav", 70, 70)
        owner:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav", 65, 135, 1, CHAN_AUTO)

        -- 屏幕白光效果
        owner:SendLua("util.WhiteOut(0.25)")

        -- 清除负面状态
        local statuses = {"enfeeble", "slow", "dimvision", "frost"}
        for _, status in pairs(statuses) do
            if owner:GetStatus(status) then
                owner:RemoveStatus(status)
            end
        end

        -- 增加生命上限与补满血量
        local healthAdd = 300
        owner:SetMaxHealth(owner:GetMaxHealth() + healthAdd)
        owner:SetHealth(owner:GetMaxHealth())

        -- 给予两把武器
        owner:Give("weapon_zs_hero_awp")
        --owner:Give("weapon_zs_b")

        -- 公告提示：玩家变成了英雄
        for _, ply in ipairs(player.GetAll()) do
            ply:PrintMessage(HUD_PRINTTALK, owner:Name() .. " 使用了光之契约，变成了英雄！")
        end

        -- 私人提示：150秒后会死亡
        owner:PrintMessage(HUD_PRINTTALK, "你使用了光之契约，150秒后你将立即死亡。")

        -- 设置150秒后立即死亡
        timer.Simple(150, function()
            if IsValid(owner) then
                owner:Kill()
            end
        end)
    end
end