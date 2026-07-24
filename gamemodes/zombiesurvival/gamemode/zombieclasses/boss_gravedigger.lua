--[[
==================================================================
掘墓人 (The Grave Digger) — BOSS僵尸职业
继承自：boss_butcher
特点：高血量、可嘲讽、死亡掉落武器箱、生成时播放环境音效、
      紫色发光眼睛、紫色色调渲染
==================================================================
]]

-- 基础职业为"屠夫"
CLASS.Base = "boss_butcher"

-- 职业显示名称
CLASS.Name = "The Grave Digger"
-- 翻译键名
CLASS.TranslationName = "class_gravedigger"
-- 描述文本键名
CLASS.Description = "description_gravedigger"
-- 控制帮助文本键名
CLASS.Help = "controls_gravedigger"

-- 标记为BOSS
CLASS.Boss = true

-- 生命值
CLASS.Health = 4500
-- 移动速度
CLASS.Speed = 200

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器（坟铲）
CLASS.SWEP = "weapon_zs_graveshovelz"

-- 服务端逻辑
if SERVER then
	-- 生成时播放环境音效
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("gravediggerambience")
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标（复用屠夫图标，紫色调）
CLASS.Icon = "zombiesurvival/killicons/butcher"
CLASS.IconColor = Color(100, 0, 220)

-- 客户端渲染相关变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 眼睛发光颜色（紫色）
local colGlow = Color(180, 0, 255)
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前颜色调制（深紫色）
function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0.4, 0.1, 0.6)
end

-- 绘制后恢复颜色并绘制发光眼睛
function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local id = pl:LookupBone("ValveBiped.Bip01_Head1")
	if id and id > 0 then
		local pos, ang = pl:GetBonePositionMatrixed(id)
		if pos then
			render_SetMaterial(matGlow)
			render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
			render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
		end
	end
end

-- 服务端逻辑：死亡掉落武器箱
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
