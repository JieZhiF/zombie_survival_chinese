AddCSLuaFile()

SWEP.Base = "weapon_zs_t_doomorgan"

SWEP.PrintName = "白金之星(时停)"
SWEP.Description = "左键使用后,召唤白金之星替身，然后发动时停."

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true

local STOP_DURATION = 5

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:SetNextPrimaryFire(CurTime() + 160)

    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    if SERVER then
        -- 音效
        owner:EmitSound("weapons/bugbait/bugbait_squeeze3.wav", 70, 70)
        owner:EmitSound("physics/flesh/flesh_squishy_impact_hard3.wav", 65, 135, 1, CHAN_AUTO)

        -- 清除负面状态
        local statuses = {"enfeeble", "slow", "dimvision", "frost"}
        for _, status in pairs(statuses) do
            if owner:GetStatus(status) then
                owner:RemoveStatus(status)
            end
        end

        -- 广播提示 + 灰屏
        net.Start("zs_platinum_star_world")
        net.WriteEntity(owner)
        net.Broadcast()

        for _, ply in ipairs(player.GetAll()) do
            if ply ~= owner then
                ply.FrozenByTheWorld = true
                ply.TheWorldDamageBuffer = {}
                ply:Freeze(true)

                -- 发送屏幕变灰指令
                net.Start("zs_theworld_screenfx")
                net.Send(ply)
            end
        end

        -- 拦截伤害
        hook.Add("EntityTakeDamage", "TheWorldDamageIntercept", function(target, dmginfo)
            if target:IsPlayer() and target.FrozenByTheWorld then
                table.insert(target.TheWorldDamageBuffer, dmginfo:GetDamage())
                return true -- 阻止实际伤害
            end
        end)

        -- 解除冻结 & 伤害结算
        timer.Simple(STOP_DURATION, function()
            for _, ply in ipairs(player.GetAll()) do
                if ply.FrozenByTheWorld then
                    ply:Freeze(false)
                    ply.FrozenByTheWorld = nil

                    if ply.TheWorldDamageBuffer then
                        for _, dmg in ipairs(ply.TheWorldDamageBuffer) do
                            local dmginfo = DamageInfo()
                            dmginfo:SetDamage(dmg)
                            dmginfo:SetAttacker(owner)
                            dmginfo:SetInflictor(self)
                            ply:TakeDamageInfo(dmginfo)
                        end
                        ply.TheWorldDamageBuffer = nil
                    end
                end

                -- 通知客户端恢复屏幕颜色
                net.Start("zs_theworld_endfx")
                net.Send(ply)
            end

            hook.Remove("EntityTakeDamage", "TheWorldDamageIntercept")
        end)
    end
end

-- 客户端：聊天提示 + 灰屏 + 恢复
if CLIENT then
    local grayEndTime = 0

    net.Receive("zs_platinum_star_world", function()
        local ply = net.ReadEntity()
        if IsValid(ply) then
            chat.AddText(Color(0, 255, 255), "[时停] ", Color(255, 255, 255), ply:Nick(), " 召唤了白金之星替身。")
            chat.AddText(Color(255, 0, 255), "[时停] ", Color(255, 255, 255), "白金之星发动了 ", Color(255, 255, 0), "The World！")
            chat.AddText(Color(255, 0, 0), "[时停] ", Color(255, 255, 255), "所有人禁止移动和攻击！")
        end
    end)

    net.Receive("zs_theworld_screenfx", function()
        grayEndTime = CurTime() + STOP_DURATION
    end)

    net.Receive("zs_theworld_endfx", function()
        grayEndTime = 0 -- 立即取消灰屏
    end)

    hook.Add("RenderScreenspaceEffects", "TheWorldGrayEffect", function()
        if CurTime() < grayEndTime then
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = -0.1,
                ["$pp_colour_contrast"] = 0.6,
                ["$pp_colour_colour"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            })
        end
    end)
else
    -- 服务器注册网络消息
    util.AddNetworkString("zs_platinum_star_world")
    util.AddNetworkString("zs_theworld_screenfx")
    util.AddNetworkString("zs_theworld_endfx")
end