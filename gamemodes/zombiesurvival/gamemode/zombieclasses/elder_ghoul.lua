--[[
==================================================================
长者食尸鬼 (Elder Ghoul) — 僵尸职业
继承自：ghoul
特点：被攻击时喷射毒肉块、黄色发光眼睛、绿色调渲染
==================================================================
]]

-- 基础职业为"食尸鬼"
CLASS.Base = "ghoul"

-- 出现波次
CLASS.Wave = 2 / 6

-- 职业显示名称
CLASS.Name = "Elder Ghoul"
-- 翻译键名
CLASS.TranslationName = "class_elderghoul"
-- 描述文本键名
CLASS.Description = "description_elderghoul"
-- 控制帮助文本键名
CLASS.Help = "controls_elderghoul"

-- 进阶版本
CLASS.BetterVersion = "Noxious Ghoul"

-- 生命值
CLASS.Health = 175
-- 移动速度
CLASS.Speed = 165

-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 绑定的武器
CLASS.SWEP = "weapon_zs_elderghoul"

-- 创建毒肉块投射物（被攻击时溅射）
local function CreateFlesh(pl, damage, damagepos, damagedir)
	damage = math.min(damage, 100)

	pl:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 74, 125 - damage * 0.50)

	-- 服务端创建投射物
	if SERVER then
		damagepos = pl:LocalToWorld(damagepos)

		for i=1, math.max(1, math.floor(damage / 15)) do
			local ent = ents.Create("projectile_poisonflesh")
			if ent:IsValid() then
				local heading = (damagedir + VectorRand() * 0.3):GetNormalized()
				ent:SetPos(damagepos + heading)
				ent:SetOwner(pl)
				ent:Spawn()

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:SetVelocityInstantaneous(math.min(300, 50 + damage ^ math.Rand(1.15, 1.25)) * heading)
				end
			end
		end
	end
end

-- 受伤时触发毒肉块溅射
function CLASS:ProcessDamage(pl, dmginfo)
	local attacker, damage = dmginfo:GetAttacker(), math.min(dmginfo:GetDamage(), pl:Health())
	if attacker ~= pl and damage >= 5 and CurTime() >= (pl.m_NextPukeEmit or 0) then
		pl.m_NextPukeEmit = CurTime() + 0.3

		local pos = pl:WorldToLocal(dmginfo:GetDamagePosition())
		local norm = dmginfo:GetDamageForce():GetNormalized() * -1
		timer.Simple(0, function()
			if pl:IsValid() then
				CreateFlesh(pl, damage, pos, norm)
			end
		end)
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标（复用食尸鬼图标，黄绿色）
CLASS.Icon = "zombiesurvival/killicons/ghoul"
CLASS.IconColor = Color(170, 220, 0)

-- 渲染变量
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

-- 发光颜色（黄褐色）
local colGlow = Color(200, 160, 50)
local matSkin = Material("Models/humans/corpse/corpse1.vtf")
local matGlow = Material("sprites/glow04_noz")
local vecEyeLeft = Vector(4, -4.6, -1)
local vecEyeRight = Vector(4, -4.6, 1)

-- 绘制前：覆盖皮肤材质并调制黄绿色
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.66, 0.86, 0)
end

-- 绘制后恢复并绘制发光眼睛
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)

	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end

	local pos, ang = pl:GetBonePositionMatrixed(6)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
