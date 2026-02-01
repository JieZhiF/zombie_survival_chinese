AddCSLuaFile()
--weapon_zs_box <<武器代码
SWEP.PrintName = "奖励箱"
SWEP.Description = "打开后随机获得不同品质的武器"

SWEP.Slot = 2
SWEP.SlotPos = 0

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 50

    SWEP.HUD3DBone = "v_weapon.AK47_Parent"
    SWEP.HUD3DPos = Vector(-1, -4.5, -4)
    SWEP.HUD3DAng = Angle(0, 0, 0)
    SWEP.HUD3DScale = 0.015
end

SWEP.Base = "weapon_zs_base"
SWEP.HoldType = "ar2"

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props_junk/wood_crate001a.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.ConeMax = 0
SWEP.ConeMin = 0
SWEP.WalkSpeed = SPEED_SLOW
SWEP.IronSightsPos = Vector(-6.6, 20, 3.1)
--[[
normal	  = 普通
advanced  = 高级
rare	  = 稀有
legendary = 传说
mythic	  = 特级
--]]

----------------------------------------------------
-- 奖励池：每个品质有不同武器
----------------------------------------------------
local RewardPools = {
    ["normal"] = {
        "weapon_zs_glock3",
        "weapon_zs_magnum",
        "weapon_zs_htf_amt",
        "weapon_zs_sawedoff",
        "weapon_zs_autoshotgun",
        "weapon_zs_uzi",
        "weapon_zs_annabelle",
        "weapon_zs_inquisitor",
        "weapon_zs_amigo",
        "weapon_zs_hurricane",
        "weapon_zs_butcherknife_boss"
    },
    ["advanced"] = {
        "weapon_zs_deagle",
        "weapon_zs_tempest",
        "weapon_zs_htf_sg15",
        "weapon_zs_smg",
        "weapon_zs_silencer",
        "weapon_zs_hunter",
        "weapon_zs_onyx",
        "weapon_zs_charon",
        "weapon_zs_akbar",
        "weapon_zs_enderp",
        "weapon_zs_oberon",
        "weapon_zs_hyena",
        "weapon_zs_pollutor",
        "weapon_zs_butcherknife_boss"
    },
    ["rare"] = {
        "weapon_zs_longarm",
        "weapon_zs_dag",
        "weapon_zs_sweepershotgun",
        "weapon_zs_jackhammer",
        "weapon_zs_epsilon_shotgun",
        "weapon_zs_bulletstorm",
        "weapon_zs_reaper",
        "weapon_zs_quicksilver",
        "weapon_zs_slugrifle",
        "weapon_zs_artemis",
        "weapon_zs_zeus",
        "weapon_zs_m4",
        "weapon_zs_inferno",
        "weapon_zs_htf_ebanator",
        "weapon_zs_quasar",
        "weapon_zs_gluon",
        "weapon_zs_barrage",
        "weapon_zs_butcherknife_boss"
    },
    ["legendary"] = {
        "weapon_zs_novacolt",
        "weapon_zs_bulwark",
        "weapon_zs_citadel",
        "weapon_zs_nexus",
        "weapon_zs_tokamak",
        "weapon_zs_boomstick",
        "weapon_zs_deathdealers",
        "weapon_zs_hammerdown",
        "weapon_zs_colossus",
        "weapon_zs_renegade",
        "weapon_zs_crossbow",
        "weapon_zs_pulserifle",
        "weapon_zs_spinfusor",
        "weapon_zs_broadside",
        "weapon_zs_smelter",
        "weapon_zs_magnum_a",
        "weapon_zs_butcherknife_boss"
    },
    ["mythic"] = {
        "weapon_zs_m82a3"
        --"weapon_zs_butcherknife_boss"
        --"weapon_zs_boss_longsword"
        --"weapon_zs_spm4",
    }
}

----------------------------------------------------
-- 武器名字表
----------------------------------------------------
local WeaponNames = {
    ["weapon_zs_glock3"]        = "格洛克手枪-普通",
    ["weapon_zs_magnum"]        = "马格南手枪-普通",
    ["weapon_zs_htf_amt"]       = "ALD手枪-普通",
    ["weapon_zs_sawedoff"]      = "裂片霰弹枪-普通",
    ["weapon_zs_autoshotgun"]   = "脉冲自动霰弹枪-普通",
    ["weapon_zs_uzi"]           = "乌兹冲锋枪-普通",
    ["weapon_zs_annabelle"]     = "安娜贝尔狙击枪-普通",
    ["weapon_zs_inquisitor"]    = "审判弩-普通",
    ["weapon_zs_amigo"]         = "阿米诺斯突击步枪-普通",
    ["weapon_zs_hurricane"]     = "飓风脉冲冲锋枪-普通",
    ["weapon_zs_deagle"]        = "沙鹰手枪-高级",
    ["weapon_zs_tempest"]       = "风暴手枪-高级",
    ["weapon_zs_htf_sg15"]      = "终结者霰弹枪-高级",
    ["weapon_zs_smg"]           = "MP5冲锋枪-高级",
    ["weapon_zs_silencer"]      = "TMP冲锋枪-高级",
    ["weapon_zs_hunter"]        = "AWM狙击枪-高级",
    ["weapon_zs_onyx"]          = "黑曜石狙击枪-高级",
    ["weapon_zs_charon"]        = "卡戎连弩-高级",
    ["weapon_zs_akbar"]         = "AK47突击步枪-高级",
    ["weapon_zs_enderp"]        = "末影突击步枪-高级",
    ["weapon_zs_oberon"]        = "欧贝隆脉冲霰弹枪-高级",
    ["weapon_zs_hyena"]         = "鬣狗榴弹发射器-高级",
    ["weapon_zs_pollutor"]      = "污染者酸性步枪-高级",
    ["weapon_zs_longarm"]       = "长臂手枪-稀有",
    ["weapon_zs_dag"]           = "大卫与歌莉娅手枪-稀有",
    ["weapon_zs_sweepershotgun"] = "清扫者霰弹枪-稀有",
    ["weapon_zs_jackhammer"]    = "冲击锤霰弹枪-稀有",
    ["weapon_zs_epsilon_shotgun"] = "伊普西隆等离子霰弹枪-稀有",
    ["weapon_zs_bulletstorm"]   = "子弹风暴冲锋枪-稀有",
    ["weapon_zs_reaper"]        = "收割者UMP-稀有",
    ["weapon_zs_quicksilver"]   = "水银半自动步枪-稀有",
    ["weapon_zs_slugrifle"]     = "小型狙击枪-稀有",
    ["weapon_zs_artemis"]       = "阿耳忒弥斯双弩-稀有",
    ["weapon_zs_zeus"]          = "宙斯闪电弩-稀有",
    ["weapon_zs_m4"]            = "M4突击步枪-稀有",
    ["weapon_zs_inferno"]       = "AUG突击步枪-稀有",
    ["weapon_zs_htf_ebanator"]  = "EBAR突击步枪-稀有",
    ["weapon_zs_quasar"]        = "类星体脉冲狙击枪-稀有",
    ["weapon_zs_gluon"]         = "赫利俄斯脉冲射线-稀有",
    ["weapon_zs_barrage"]       = "猛攻榴弹发射器-稀有",
    ["weapon_zs_novacolt"]      = "新星手炮-传说",
    ["weapon_zs_bulwark"]       = "堡垒加特林-传说",
    ["weapon_zs_citadel"]       = "堡垒等离子机枪-传说",
    ["weapon_zs_nexus"]         = "SCAR突击步枪-传说",
    ["weapon_zs_tokamak"]       = "托卡马克脉冲步枪-传说",
    ["weapon_zs_boomstick"]     = "爆能霰弹枪-传说",
    ["weapon_zs_deathdealers"]  = "死亡交易霰弹枪-传说",
    ["weapon_zs_hammerdown"]    = "撼地者自动霰弹枪-传说",
    ["weapon_zs_colossus"]      = "巨像狙击枪-传说",
    ["weapon_zs_renegade"]      = "叛徒狙击枪-传说",
    ["weapon_zs_crossbow"]      = "刺客弩-传说",
    ["weapon_zs_pulserifle"]    = "阿多尼斯脉冲步枪AR2-传说",
    ["weapon_zs_spinfusor"]     = "旋转飞碟脉冲发射器-传说",
    ["weapon_zs_broadside"]     = "导弹发射器-传说",
    ["weapon_zs_smelter"]       = "高射炮-传说",
    ["weapon_zs_magnum_a"]      = "迷你超载马格南-传说",
    ["weapon_zs_spm4"]          = "自瞄步枪-特级",
    ["weapon_zs_m82a3"]         = "M82A3自动重型狙击枪-特级",
    ["weapon_zs_butcherknife_boss"] = "疯狂屠刀(BOSS)-特殊",
    ["weapon_zs_boss_longsword"] = "修罗剑(特级)-特级"
}
--weapon_zs_stabber
----------------------------------------------------
-- 音效池：每个品质不同
----------------------------------------------------
local RewardSounds = {
    ["normal"] = {
        "items/ammo_pickup.wav",
        "items/itempickup.wav"
    },
    ["advanced"] = {
        "items/smallmedkit1.wav",
        "items/battery_pickup.wav"
    },
    ["rare"] = {
        "ui/item_paper_pickup.wav",
        "ui/hint.wav"
    },
    ["legendary"] = {
        "ambient/levels/labs/coinslot1.wav",
        "ambient/energy/zap1.wav"
    },
    ["mythic"] = {
        "ambient/levels/citadel/portal_beam_shoot6.wav",
        "ambient/energy/weld1.wav"
    }
}

----------------------------------------------------
-- 品质颜色（HUD/聊天用）
----------------------------------------------------
local RewardColors = {
    ["normal"]    = Color(200, 200, 200),
    ["advanced"]  = Color(50, 200, 50),
    ["rare"]      = Color(0, 150, 255),
    ["legendary"] = Color(255, 100, 0),
    ["mythic"]    = Color(200, 0, 200)
}

----------------------------------------------------
-- 抽取概率（总和必须为 1）
----------------------------------------------------
local RewardChances = {
    ["normal"]    = 0.20, --20%。普通
    ["advanced"]  = 0.45, --45%。高级
    ["rare"]      = 0.20, --20%。稀有
    ["legendary"] = 0.10, --10%。传说
    ["mythic"]    = 0.05  --5%。特级
}

----------------------------------------------------
-- 阶级对应 零件 数量
----------------------------------------------------
local TierScrap = {
    [1] = 5,
    [2] = 16,
    [3] = 30,
    [4] = 46,
    [5] = 70
}

----------------------------------------------------
-- 随机抽品质
----------------------------------------------------
local function RollQuality()
    local roll = math.Rand(0, 1)
    local sum = 0
    for quality, chance in pairs(RewardChances) do
        sum = sum + chance
        if roll <= sum then
            return quality
        end
    end
    return "normal"
end

----------------------------------------------------
-- 主攻击（开箱）
----------------------------------------------------
function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    if SERVER then
        -- 1. 随机品质
        local quality = RollQuality()

        -- 2. 随机武器
        local weaponList = RewardPools[quality]
        local randomWeapon = table.Random(weaponList or {})

        -- 3. 显示名字
        local displayName = WeaponNames[randomWeapon] or (randomWeapon or "未知")

        if randomWeapon then
            if not owner:HasWeapon(randomWeapon) then
                -- 正常给武器
                owner:Give(randomWeapon)
                owner:SelectWeapon(randomWeapon)

                -- 全服广播（稀有以上）
                if quality == "rare" or quality == "legendary" or quality == "mythic" then
                    for _, ply in ipairs(player.GetAll()) do
                        ply:ChatPrint(owner:Nick() .. " 开出了 " .. quality .. " 武器: " .. displayName .. "！")
                    end
                end

                owner:ChatPrint("你获得了 [" .. quality .. "] 武器: " .. displayName)
            else
                -- 转换为 scrap（根据武器 SWEP.Tier，如果没有则默认为 1）
                local tier = 1
                local weptab = weapons.GetStored(randomWeapon)
                if weptab and weptab.Tier then
                    tier = weptab.Tier
                end

                local scrap = TierScrap[tier] or TierScrap[1]
                owner:GiveAmmo(scrap, "scrap")

                owner:ChatPrint("你已拥有 [" .. quality .. "] 武器: " .. displayName .. "，转化为 " .. scrap .. " scrap。")
            end
        end
        -- 4. 播放品质音效
        local sndList = RewardSounds[quality]
        if sndList then
            local snd = table.Random(sndList)
            owner:EmitSound(snd, 75, 100, 1, CHAN_AUTO)
        end

        -- 5. HUD 提示（只给自己）
        net.Start("zs_box_reward")
            net.WriteString(quality)
            net.WriteString(displayName)
        net.Send(owner)

        -- 6. 移除奖励箱
        owner:StripWeapon(self:GetClass())
    end
end
function SWEP:Reload()
    return false
end

function SWEP:CanPrimaryAttack()
    return true
end

----------------------------------------------------
-- 客户端 HUD 提示
----------------------------------------------------
if CLIENT then
    net.Receive("zs_box_reward", function()
        local quality = net.ReadString()
        local wepname = net.ReadString()
        local col = RewardColors[quality] or color_white

        notification.AddLegacy("你获得了 [" .. quality .. "] " .. wepname, NOTIFY_HINT, 5)
        surface.PlaySound("buttons/button15.wav")

        -- 中心文字提示
        chat.AddText(col, "[奖励箱] 你获得了 " .. wepname .. " (" .. quality .. ")")
    end)
end

if SERVER then
    util.AddNetworkString("zs_box_reward")
end