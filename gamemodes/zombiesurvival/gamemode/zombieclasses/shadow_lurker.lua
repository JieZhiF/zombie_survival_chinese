--[[
==================================================================
暗影潜伏者 (Shadow Lurker) — 僵尸职业
继承自：zombie_torso
特点：骷髅覆盖模型、半透明黑色渲染、近战伤害减半、
      死亡时触发暗影特效、红色发光眼睛
==================================================================
]]

-- 基础职业为"僵尸躯干"
CLASS.Base = "zombie_torso"

-- 职业显示名称
CLASS.Name = "Shadow Lurker"
-- 翻译键名
CLASS.TranslationName = "class_shadow_lurker"
-- 描述文本键名
CLASS.Description = "description_shadow_lurker"
-- 控制帮助文本键名
CLASS.Help = "controls_shadow_lurker"

-- 主模型（经典躯干）+ 覆盖模型（骷髅）
CLASS.Model = Model("models/zombie/classic_torso.mdl")
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 小碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 22)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 22)}

-- 绑定的武器
CLASS.SWEP = "weapon_zs_shadowlurker"

-- 出现波次/解锁状态
CLASS.Wave = 2 / 6
CLASS.Unlocked = false
CLASS.Hidden = false

-- 生命值/移动
CLASS.Health = 165
CLASS.Speed = 160
CLASS.JumpPower = 160

-- 击杀得分
CLASS.Points = CLASS.Health/GM.TorsoZombiePointRatio

-- 语音音调
CLASS.VoicePitch = 0.55

-- 不隐藏主模型
CLASS.NoHideMainModel = true

-- 标记为躯干和骷髅
CLASS.IsTorso = true
CLASS.Skeletal = true

-- 缓存函数
local math_random = math.random
local ACT_IDLE = ACT_IDLE
local ACT_WALK = ACT_WALK

-- 计算活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return ACT_WALK, -1
end

-- 受伤/死亡音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/antlion/pain2.wav", 70, math_random(240, 250))
	pl.NextPainSound = CurTime() + 0.5
	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/antlion/pain"..math_random(2)..".wav", 70, math_random(240, 250))
	return true
end

-- 脚步声（藤壶折颈音效）
local StepSounds = {
	Sound("npc/barnacle/neck_snap1.wav"),
	Sound("npc/barnacle/neck_snap2.wav")
}

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(StepSounds[math_random(#StepSounds)], 50, math_random(210, 220), 0.5)
	return true
end

-- 脚步间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return GAMEMODE.BaseClass.PlayerStepSoundTime(GAMEMODE, pl, iType, bWalking)
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
end

-- 操控覆盖模型（隐藏特定骨骼）
function CLASS:ManipulateOverrideModel(pl, overridemodel)
	overridemodel:ManipulateBoneScale(0, vector_origin)
	overridemodel:ManipulateBoneScale(2, vector_origin)
	overridemodel:ManipulateBoneScale(4, vector_origin)
	for i=18, 25 do
		overridemodel:ManipulateBoneScale(i, vector_origin)
	end
end

-- 服务端逻辑
if SERVER then
	-- 近战伤害减半
	function CLASS:ProcessDamage(pl, dmginfo)
		if dmginfo:GetInflictor().IsMelee then
			dmginfo:SetDamage(dmginfo:GetDamage() / 2)
		end
	end

	-- 死亡时触发特效
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos())
			effectdata:SetNormal(pl:GetForward())
			effectdata:SetEntity(pl)
		util.Effect("death_shadowlurker", effectdata, nil, true)

		local fakedeath = pl:FakeDeath(462, 1, 1, 1)
		if fakedeath and fakedeath:IsValid() then
			fakedeath:SetColor(color_black)
			fakedeath:SetModel(self.OverrideModel)
			fakedeath:SetPos(fakedeath:GetPos() - fakedeath:GetDeathAngles():Up() * 46)
			self:ManipulateOverrideModel(pl, fakedeath)
		end
		return true
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/skeletal_lurker"
CLASS.IconColor = Color(20, 20, 20)

-- 渲染变量
local render_SetBlend = render.SetBlend
local render_SetColorModulation = render.SetColorModulation
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_ModelMaterialOverride = render.ModelMaterialOverride
local angle_zero = angle_zero
local LocalToWorld = LocalToWorld

local colGlow = Color(255, 0, 0)
local matGlow = Material("sprites/glow04_noz")
local matBlack = CreateMaterial("shadowlurkersheet", "UnlitGeneric", {["$basetexture"] = "Tools/toolsblack", ["$model"] = 1})
local vecEyeLeft = Vector(5, -3.5, -1)
local vecEyeRight = Vector(5, -3.5, 1)

-- 主模型绘制
function CLASS:PrePlayerDraw(pl)
	render_SetBlend(0.45)
	render_SetColorModulation(0.1, 0.1, 0.1)
end

function CLASS:PostPlayerDraw(pl)
	render_SetBlend(1)
	render_SetColorModulation(1, 1, 1)
end

-- 覆盖模型绘制
function CLASS:PrePlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(matBlack)
end

function CLASS:PostPlayerDrawOverrideModel(pl)
	render_ModelMaterialOverride(nil)
	if pl == MySelf and not pl:ShouldDrawLocalPlayer() or pl.SpawnProtection then return end
	local pos, ang = pl:GetBonePositionMatrixed(5)
	if pos then
		render_SetMaterial(matGlow)
		render_DrawSprite(LocalToWorld(vecEyeLeft, angle_zero, pos, ang), 4, 4, colGlow)
		render_DrawSprite(LocalToWorld(vecEyeRight, angle_zero, pos, ang), 4, 4, colGlow)
	end
end
