--[[
==================================================================
人类叛徒 (Human Traitor) — 隐藏僵尸职业
特点：隐藏职业、使用防暴警察模型、无脚步声、自定义死亡掉落武器
==================================================================
]]

-- 职业显示名称
CLASS.Name = "humantraitor"
-- 翻译键名
CLASS.TranslationName = "class_humantraitor"
-- 描述文本键名
CLASS.Description = "description_humantraitor"
-- 控制帮助文本键名
CLASS.Help = "controls_humantraitor"

-- 非正式BOSS（隐藏）
CLASS.Boss = false
-- 迷你BOSS（通过僵尸商店购买获得）
CLASS.MiniBoss = true
-- 隐藏职业
CLASS.Hidden = true
-- 未解锁
CLASS.Unlocked = false
-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 生命值
CLASS.Health = 700
-- 移动速度
CLASS.Speed = 265

-- 可嘲讽
CLASS.CanTaunt = true

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 击杀得分
CLASS.Points = 50

-- 绑定的武器（BOSS长剑）
CLASS.SWEP = "weapon_zs_boss_longsword"

-- 使用防暴警察模型
CLASS.Model = Model("models/player/riot.mdl")

-- 受伤音效列表
CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
-- 死亡音效列表
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

-- 语音音调
CLASS.VoicePitch = 0.65

-- 不可装死
CLASS.CanFeignDeath = false

-- 无脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	return false
end

-- 无脚步音效间隔
function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	return false
end

-- 无主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	return false
end

-- 无动画更新
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	return false
end

-- 无动画事件
function CLASS:DoAnimationEvent(pl, event, data)
end

-- 不产生恐惧
function CLASS:DoesntGiveFear(pl)
end

-- 客户端逻辑
if CLIENT then
	CLASS.Icon = "zombiesurvival/killicons/zombie"
end

-- 服务端逻辑
if SERVER then
	-- 生成时播放环境音效
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("butcherambience")
	end

	-- 创建武器掉落物
	local function MakeButcherKnife(pos)
		local ent = ents.Create("prop_weapon")
		if ent:IsValid() then
			ent:SetPos(pos)
			ent:SetAngles(AngleRand())
			ent:SetWeaponType("weapon_zs_box")
			ent:Spawn()

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
				phys:AddAngleVelocity(VectorRand() * 200)
			end
		end
	end

	-- 死亡时延迟掉落武器
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
		local pos = pl:LocalToWorld(pl:OBBCenter())
		timer.Simple(0, function()
			MakeButcherKnife(pos)
		end)
	end
end
