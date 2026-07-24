--[[
==================================================================
化学僵尸 (Chem Zombie) — 特殊僵尸职业（已禁用）
特点：隐藏/禁用状态、死亡时产生化学爆炸、毒雾伤害、
      使用毒僵尸模型、不可被玩家选择使用
==================================================================
]]

-- 隐藏/禁用状态
CLASS.Hidden = true
CLASS.Disabled = true
CLASS.Unlocked = true

-- 职业显示名称
CLASS.Name = "Chem Zombie"
-- 翻译键名
CLASS.TranslationName = "class_chem_zombie"
-- 描述文本键名
CLASS.Description = "description_chem_zombie"
-- 控制帮助文本键名
CLASS.Help = "controls_chem_zombie"

-- 出现波次
CLASS.Wave = 6 / 6

-- 生命值
CLASS.Health = 200
-- 绑定的武器
CLASS.SWEP = "weapon_zs_chemzombie"
-- 使用毒僵尸模型
CLASS.Model = Model("models/Zombie/Poison.mdl")
-- 移动速度
CLASS.Speed = 200

-- 击杀得分
CLASS.Points = 3

-- 受伤/死亡音效
CLASS.PainSounds = {Sound("npc/metropolice/knockout2.wav"), Sound("npc/metropolice/pain1.wav"), Sound("npc/metropolice/pain2.wav"), Sound("npc/metropolice/pain3.wav"), Sound("npc/metropolice/pain4.wav")}
CLASS.DeathSounds = {Sound("ambient/fire/gascan_ignite1.wav")}
-- 语音音调
CLASS.VoicePitch = 0.65

-- 视角偏移和碰撞体积
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

-- 缓存函数
local math_random = math.random
local ACT_IDLE = ACT_IDLE

-- 不可被玩家使用
function CLASS:CanUse(pl)
	return false
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return 1, 2
end

-- 脚步声列表
local StepSounds = {
	"npc/zombie_poison/pz_left_foot1.wav"
}
local ScuffSounds = {
	"npc/zombie_poison/pz_right_foot1.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math_random() < 0.333 then
		pl:EmitSound(ScuffSounds[math_random(#ScuffSounds)], 80, 90)
	else
		pl:EmitSound(StepSounds[math_random(#StepSounds)], 80, 90)
	end
	return true
end

-- 脚步音效间隔时间
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 365 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 300
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 450
	end
	return 150
end

-- 服务端逻辑
if SERVER then
	-- 生成时创建环境音效
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("chemzombieambience")
	end

	-- 创建化学僵尸假人实体（用于爆炸伤害来源）
	hook.Add("InitPostEntityMap", "MakeChemDummy", function()
		DUMMY_CHEMZOMBIE = ents.Create("dummy_chemzombie")
		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:Spawn()
		end
	end)

	-- 化学爆炸函数
	local function ChemBomb(pl, pos)
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("explosion_chem", effectdata, true)

		if DUMMY_CHEMZOMBIE:IsValid() then
			DUMMY_CHEMZOMBIE:SetPos(pos)
		end
		util.PoisonBlastDamage(DUMMY_CHEMZOMBIE, pl, pos, 128, 85, true)

		pl:CheckRedeem()
	end

	-- 死亡时触发化学爆炸
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		if attacker ~= pl and not suicide then
			local pos = pl:LocalToWorld(pl:OBBCenter())

			pl:Gib(dmginfo)
			timer.Simple(0, function() ChemBomb(pl, pos) end)

			return true
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/chemzombie"
