AddCSLuaFile()

SWEP.PrintName = "白金之星(时停)"
SWEP.Description = "左键使用后,召唤白金之星替身，然后发动时停."

if CLIENT then
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	
	SWEP.VElements = {
	["main"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1, 5, 1), angle = Angle(-61.949, 87.662, 127.402), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
	["1++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(-1.558, -1.558, 0.2), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 127, 200, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["base++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
	["base+"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
	["1+++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(0.518, 1, 1.557), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 127, 200, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["base"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = true},
	["1+"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(1.557, 0, 0.2), angle = Angle(0, 99.35, 52.597), size = Vector(0.05, 0.05, 0.05), color = Color(72, 127, 200, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["1"] = { type = "Model", model = "models/props_wasteland/medbridge_post01.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "main", pos = Vector(0, 0, -1.5), angle = Angle(0, 0, 0), size = Vector(0.029, 0.029, 0.029), color = Color(166, 200, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["main"] = { type = "Model", model = "", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 5, -0.5), angle = Angle(-17.532, 45.583, 127.402), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["1++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(-1.558, -1.558, 0.2), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 127, 200, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["base++"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1++", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["base+"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "1+", pos = Vector(0, 0, 0), size = { x = 2, y = 2 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["1+++"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0.518, 1, 1.557), angle = Angle(75.973, -43.248, -24.546), size = Vector(0.05, 0.05, 0.05), color = Color(72, 127, 200, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} },
	["1"] = { type = "Model", model = "models/props_wasteland/medbridge_post01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0, 0, -1.5), angle = Angle(0, 0, 0), size = Vector(0.029, 0.029, 0.029), color = Color(166, 200, 255, 255), surpresslightning = true, material = "", skin = 0, bodygroup = {} },
	["base"] = { type = "Sprite", sprite = "sprites/light_glow02", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(0, 0, 0), size = { x = 10, y = 10 }, color = Color(123, 208, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["1+"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "main", pos = Vector(1.557, 0, 0.2), angle = Angle(0, 99.35, 52.597), size = Vector(0.05, 0.05, 0.05), color = Color(72, 127, 200, 255), surpresslightning = true, material = "models/shiny", skin = 0, bodygroup = {} }
}
end

SWEP.Base = "weapon_zs_basemelee"

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"
SWEP.UseHands = true

SWEP.HoldType = "melee2"

SWEP.MeleeDamage = 1
SWEP.MeleeRange = 1
SWEP.MeleeSize = 1.5

SWEP.WalkSpeed = SPEED_FAST

SWEP.SwingTime = 0.6
SWEP.SwingRotation = Angle(0, -20, -40)
SWEP.SwingOffset = Vector(10, 0, 0)
SWEP.SwingHoldType = "melee"

SWEP.Undroppable = true
SWEP.NoPickupNotification = true
SWEP.NoDismantle = true
SWEP.NoGlassWeapons = true

local STOP_DURATION = 5

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    self:SetNextPrimaryFire(CurTime() + 120)

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
            if ply ~= owner and ply:Team() ~= TEAM_SURVIVORS then
                ply.FrozenByTheWorld = true
                ply.TheWorldDamageBuffer = {}
                ply:Freeze(true)

                -- 发送屏幕变灰指令
                net.Start("zs_theworld_screenfx")
                net.Send(ply)
            end
        end

        -- 拦截伤害：仅 TEAM_SURVIVORS 的攻击缓存，其他伤害无效
        hook.Add("EntityTakeDamage", "TheWorldDamageIntercept", function(target, dmginfo)
            if not target:IsPlayer() then return end

            local attacker = dmginfo:GetAttacker()
            if not IsValid(attacker) or not attacker:IsPlayer() then return end

            if target.FrozenByTheWorld then
                if attacker:Team() == TEAM_SURVIVORS then
                    target.TheWorldDamageBuffer = target.TheWorldDamageBuffer or {}
                    table.insert(target.TheWorldDamageBuffer, {
                        amount = dmginfo:GetDamage(),
                        attacker = attacker,
                        inflictor = dmginfo:GetInflictor(),
                        dmgtype = dmginfo:GetDamageType()
                    })
                end

                return true -- 阻止伤害立即生效
            end
        end)

        -- 解除冻结 & 伤害结算
        local STOP_DURATION = 5 -- 设置你想要的时停持续时间（单位：秒）
        timer.Simple(STOP_DURATION, function()
            for _, ply in ipairs(player.GetAll()) do
                if ply.FrozenByTheWorld and ply:Team() ~= TEAM_SURVIVORS then
                    ply:Freeze(false)
                    ply.FrozenByTheWorld = nil

                    -- 结算缓存在其身上的伤害
                    if ply.TheWorldDamageBuffer then
                        for _, dmg in ipairs(ply.TheWorldDamageBuffer) do
                            local dmginfo = DamageInfo()
                            dmginfo:SetDamage(dmg.amount)
                            dmginfo:SetAttacker(IsValid(dmg.attacker) and dmg.attacker or owner)
                            dmginfo:SetInflictor(IsValid(dmg.inflictor) and dmg.inflictor or self)
                            dmginfo:SetDamageType(dmg.dmgtype or DMG_GENERIC)
                            ply:TakeDamageInfo(dmginfo)
                        end
                        ply.TheWorldDamageBuffer = nil
                    end
                end

                -- 通知客户端恢复屏幕颜色（只发给非幸存者）
                if ply:Team() ~= TEAM_SURVIVORS then
                    net.Start("zs_theworld_endfx")
                    net.Send(ply)
                end
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
