--[[
==================================================================
远古梦魇 (Ancient Nightmare) — BOSS僵尸职业
继承自：boss_nightmare
特点：骷髅模型，脚步声为藤壶折颈音效，死亡时掉落武器箱
==================================================================
]]

-- 基础职业为"梦魇"
CLASS.Base = "boss_nightmare"

-- 职业显示名称
CLASS.Name = "Ancient Nightmare"
-- 翻译键名
CLASS.TranslationName = "class_ancient_nightmare"
-- 描述文本键名
CLASS.Description = "description_ancient_nightmare"
-- 控制帮助文本键名
CLASS.Help = "controls_ancient_nightmare"

-- 标记为BOSS
CLASS.Boss = true

-- 生命值
CLASS.Health = 3500
-- 移动速度
CLASS.Speed = 170

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_anightmare"

-- 使用骷髅模型
CLASS.Model = Model("models/player/skeleton.mdl")
-- 不覆盖模型
CLASS.OverrideModel = false

-- 标记为骷髅类僵尸（无血液、骨架效果）
CLASS.Skeletal = true

-- 缓存随机函数
local math_random = math.random

-- 脚步声：播放藤壶折颈音效
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if math_random(2) == 1 then
		pl:EmitSound("npc/barnacle/neck_snap1.wav", 65, math_random(115, 130), 0.27)
	else
		pl:EmitSound("npc/barnacle/neck_snap2.wav", 65, math_random(115, 130), 0.27)
	end
	return true
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/ancient_nightmare"

-- 服务端逻辑
if SERVER then
    -- 当僵尸被杀死时
    function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
        -- 掉落武器
        local pos = pl:LocalToWorld(pl:OBBCenter())
        local ent = ents.Create("prop_weapon")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:SetAngles(AngleRand())
            ent:SetWeaponType("weapon_zs_box")
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
                phys:AddAngleVelocity(VectorRand() * 200)
            end
        end
        return true
    end
end
