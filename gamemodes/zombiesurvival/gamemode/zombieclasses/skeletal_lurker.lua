--[[
==================================================================
骷髅爬行者 (Skeletal Crawler) — 僵尸职业
继承自：zombie_torso
特点：骷髅模型、子弹伤害大幅减免（64%）、非斩击/棍棒伤害减免55%、
      死亡时创建骷髅假尸体
==================================================================
]]

-- 基础职业为"僵尸躯干"
CLASS.Base = "zombie_torso"

-- 职业显示名称
CLASS.Name = "Skeletal Crawler"
-- 翻译键名
CLASS.TranslationName = "class_skeletal_lurker"
-- 描述文本键名
CLASS.Description = "description_skeletal_lurker"
-- 控制帮助文本键名
CLASS.Help = "controls_skeletal_lurker"

-- 主模型（经典躯干）+ 覆盖模型（骷髅）
CLASS.Model = Model("models/zombie/classic_torso.mdl")
CLASS.OverrideModel = Model("models/player/skeleton.mdl")

-- 小碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 22)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 22)}

-- 绑定的武器
CLASS.SWEP = "weapon_zs_skeletallurker"

-- 出现波次
CLASS.Wave = 2 / 6
CLASS.Unlocked = false
CLASS.Hidden = false

-- 生命值/速度
CLASS.Health = 75
CLASS.Speed = 155
CLASS.JumpPower = 160

-- 击杀得分
CLASS.Points = CLASS.Health/GM.SkeletonPointRatio

-- 语音音调
CLASS.VoicePitch = 0.8

-- 标记为躯干和骷髅
CLASS.IsTorso = true
CLASS.Skeletal = true
CLASS.SkeletalRes = true

-- 缓存
local math_random = math.random
local ACT_IDLE = ACT_IDLE
local ACT_WALK = ACT_WALK
local bit_band = bit.band
local DMG_BULLET = DMG_BULLET
local DMG_CLUB = DMG_CLUB
local DMG_SLASH = DMG_SLASH
local string_format = string.format

-- 活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return ACT_WALK, -1
end

-- 受伤/死亡音效
function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("npc/metropolice/pain%d.wav", math_random(4)), 65, math_random(80, 85))
	return true
end

function CLASS:PlayDeathSound(pl)
	pl:EmitSound(string_format("npc/zombie/zombie_die%d.wav", math_random(3)), 75, math_random(132, 138))
	return true
end

-- 脚步声
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

-- 操控覆盖模型
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
	-- 伤害减免：子弹64%，其他非斩击/棍棒55%
	function CLASS:ProcessDamage(pl, dmginfo)
		if bit_band(dmginfo:GetDamageType(), DMG_BULLET) ~= 0 then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.36)
		elseif bit_band(dmginfo:GetDamageType(), DMG_SLASH) == 0 and bit_band(dmginfo:GetDamageType(), DMG_CLUB) == 0 then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.45)
		end
	end

	-- 死亡时创建骷髅假尸体
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local fakedeath = pl:FakeDeath(462, 1, 1, 1)
		if fakedeath and fakedeath:IsValid() then
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
