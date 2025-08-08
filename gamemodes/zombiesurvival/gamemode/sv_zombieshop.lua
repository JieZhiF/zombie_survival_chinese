//这个是处理增加僵尸的突变点数的。请根据你自己的情况修改
hook.Add("PostEntityTakeDamage", "OnEntityDamaged", function(ent, dmginfo)
    //检查收伤害的实体是否是玩家
if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():Team() == TEAM_UNDEAD then
    if ent:GetBarricadeHealth() > 0 then //如果命中的实体的素材
        local weapon = dmginfo:GetAttacker():GetActiveWeapon()
            -- Check if the damaged entity is a player
        local tokendmg = dmginfo:GetDamage()
        local attacker = dmginfo:GetAttacker()
        if IsValid(weapon) then
            local damage = weapon.MeleeDamage or weapon.Primary.Damage or weapon.PounceDamage or 0
            if weapon.MeleeDamageVsProps then 
                damage = weapon.MeleeDamageVsProps
            end
            local adddmg = damage * 0.3
            -- Give the player the amount of tokens equal to the damage attribute
            dmginfo:GetAttacker():AddTokens(adddmg)
        end
    elseif ent:IsPlayer() and ent:IsValid() and ent:Team() ~= dmginfo:GetAttacker():Team() then//确保受伤害的实体是玩家并且不是同一队伍，这个是防止万磁拿东西砸僵尸也会获得点数。
        local damage = dmginfo:GetDamage()
        local token = damage * 2
        dmginfo:GetAttacker():AddTokens(token)
    end

end
end)
