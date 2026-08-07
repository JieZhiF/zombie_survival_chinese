-- ============================================================================
-- sv_block_melee_functions.lua - 近战武器格挡系统（服务器端）
-- 负责：当玩家持有可格挡的近战武器时，根据格挡时机（完美格挡/普通格挡/格挡穿透）
-- 对受到的近战伤害进行减免或完全抵消，并播放对应的格挡音效与特效。
-- ============================================================================

-- ZS_Blocking 处理玩家被近战攻击时的格挡判定
-- 根据格挡状态（完美格挡/普通格挡/格挡穿透）缩放受到的伤害
function ZS_Blocking(target, dmginfo)
    if target:IsPlayer() and target:Alive() and target ~= dmginfo:GetAttacker() then
        local wep = target:GetActiveWeapon()
        local block = wep and wep.IsBlocking and wep:IsBlocking()
        local blockPercent = wep and wep.DefendingDamageBlocked
        local blockPercentDefault = wep and wep.DefendingDamageBlockedDefault
        local parryWindow = 0.2  -- Parry time window in seconds
        -- 计算格挡特效的生成位置（枪口前方 20 单位处）
        local effectPos = target:GetShootPos() + target:GetAimVector() * 20

        -- 仅对近战类伤害（斩击/通用/钝击）进行格挡处理
        if block and (dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_GENERIC) or dmginfo:IsDamageType(DMG_CLUB)) then
            -- 播放格挡音效
            target:EmitSound(wep.BlockSound, 100, wep.BlockSoundPitch)

            -- Check if it's within the perfect parry window
            -- 判断是否处于完美格挡（招架）时间窗口内
            local isPerfectParry = (CurTime() - wep.ParryStartTime) <= parryWindow

            if isPerfectParry then
                -- Perfect parry effect and damage reduction
                -- 完美格挡：完全抵消伤害并播放特殊音效与特效
                if IsFirstTimePredicted() then
                target:EmitSound("zombiesurvival/ui/survival_medal.wav", 50, math.random(100,wep.BlockSoundPitch+20), 0.75, CHAN_WEAPON+7)  -- Play a special sound for perfect parry
                dmginfo:ScaleDamage(0)  -- Completely negate the damage for a perfect parry
                end

                local parryEffect = EffectData()
                parryEffect:SetOrigin(effectPos)
                parryEffect:SetEntity(target)
                parryEffect:SetAttachment(1)
                util.Effect("melee_parry_text", parryEffect)
            elseif blockPercent < blockPercentDefault then

                -- 普通格挡：防御力衰减时按比例减免伤害并播放格挡文字特效
                local deflectionEffect = EffectData()
                deflectionEffect:SetOrigin(effectPos)
                deflectionEffect:SetEntity(target)
                deflectionEffect:SetAttachment(1)
                util.Effect("stundeflection", deflectionEffect)

                local blockTextEffect = EffectData()
                blockTextEffect:SetOrigin(effectPos)
                blockTextEffect:SetEntity(target)
                blockTextEffect:SetAttachment(1)
                util.Effect("melee_block_text", blockTextEffect)

                dmginfo:ScaleDamage(0.95 / blockPercent)
            else
                
                -- 格挡穿透：防御力充足时伤害按穿透比例计算并播放穿刺特效
                local pierceEffect = EffectData()
                pierceEffect:SetOrigin(effectPos)
                pierceEffect:SetEntity(target)
                pierceEffect:SetAttachment(1)
                util.Effect("spearpierce", pierceEffect)

                dmginfo:ScaleDamage(1 / blockPercent)
            end
        end
    end
end

-- 注册实体受到伤害钩子，将 ZS_Blocking 接入伤害流程
hook.Add("EntityTakeDamage", "ZSBlocking-System", ZS_Blocking)

-- IsDefending 判断玩家当前是否处于格挡状态
function IsDefending(pl)
    local wep = pl:GetActiveWeapon()
    return wep and wep.IsBlocking and wep:IsBlocking()
end

-- GetBlockDefense 返回本地玩家当前武器的格挡减伤比例
function GetBlockDefense()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    return wep and wep.DefendingDamageBlocked
end

-- GetBlockDefenseDefault 返回本地玩家当前武器的格挡减伤基准比例
function GetBlockDefenseDefault()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    return wep and wep.DefendingDamageBlockedDefault
end
