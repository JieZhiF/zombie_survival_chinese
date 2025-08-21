-- 本文件主要负责定义和管理不同角色模型的语音音效集，并根据从服务器接收的网络事件指令，在客户端播放对应的玩家声音。

-- VoiceSets[VOICESET_MALE] 定义标准男性角色的语音集
-- VoiceSets[VOICESET_BARNEY] 定义Barney角色的语音集
-- VoiceSets[VOICESET_FEMALE] 定义标准女性角色的语音集
-- VoiceSets[VOICESET_ALYX] 定义Alyx角色的语音集
-- VoiceSets[VOICESET_COMBINE] 定义联合军士兵角色的语音集
-- VoiceSets[VOICESET_MONK] 定义Grigori神父角色的语音集
-- meta:GetVoiceLines 根据玩家当前语音模型和事件类型，获取对应的音效列表
-- meta:PlayEyePainSound 播放一个随机的眼部受伤音效
-- meta:PlayGiveAmmoSound 播放一个随机的给予弹药音效
-- meta:PlayDeathSound 播放一个随机的死亡音效
-- meta:PlayZombieDeathSound 播放玩家扮演僵尸时的死亡音效
-- meta:PlayPainSound 根据传入的生命值，播放轻度、中度或重度的受伤音效
-- meta:PlayZombiePainSound 播放玩家扮演僵尸时的受伤音效
-- net.Receive("voice_eyepain") 接收播放眼部受伤音效的网络消息
-- net.Receive("voice_giveammo") 接收播放给予弹药音效的网络消息
-- net.Receive("voice_death") 接收播放死亡音效的网络消息
-- net.Receive("voice_zombiedeath") 接收播放僵尸死亡音效的网络消息
-- net.Receive("voice_pain") 接收播放受伤音效的网络消息，并附带生命值信息
-- net.Receive("voice_zombiepain") 接收播放僵尸受伤音效的网络消息
local VoiceSets = {}

VoiceSets[VOICESET_MALE] = {
	[VOICELINE_GIVEAMMO] = {
		Sound("vo/npc/male01/ammo03.wav"),
		Sound("vo/npc/male01/ammo04.wav"),
		Sound("vo/npc/male01/ammo05.wav")
	},
	[VOICELINE_PAIN_LIGHT] = {
		Sound("vo/npc/male01/ow01.wav"),
		Sound("vo/npc/male01/ow02.wav"),
		Sound("vo/npc/male01/pain01.wav"),
		Sound("vo/npc/male01/pain02.wav"),
		Sound("vo/npc/male01/pain03.wav")
	},
	[VOICELINE_PAIN_MED] = {
		Sound("vo/npc/male01/pain04.wav"),
		Sound("vo/npc/male01/pain05.wav"),
		Sound("vo/npc/male01/pain06.wav")
	},
	[VOICELINE_PAIN_HEAVY] = {
		Sound("vo/npc/male01/pain07.wav"),
		Sound("vo/npc/male01/pain08.wav"),
		Sound("vo/npc/male01/pain09.wav")
	},
	[VOICELINE_DEATH] = {
		Sound("vo/npc/male01/no02.wav"),
		Sound("ambient/voices/citizen_beaten1.wav"),
		Sound("ambient/voices/citizen_beaten3.wav"),
		Sound("ambient/voices/citizen_beaten4.wav"),
		Sound("ambient/voices/citizen_beaten5.wav"),
		Sound("vo/npc/male01/pain07.wav"),
		Sound("vo/npc/male01/pain08.wav")
	},
	[VOICELINE_EYEPAIN] = {
		Sound("ambient/voices/m_scream1.wav")
	}
}

VoiceSets[VOICESET_BARNEY] = {
	[VOICELINE_GIVEAMMO] = {
		Sound("items/ammo_pickup.wav")
	},
	[VOICELINE_PAIN_LIGHT] = {
		Sound("vo/npc/Barney/ba_pain02.wav"),
		Sound("vo/npc/Barney/ba_pain07.wav"),
		Sound("vo/npc/Barney/ba_pain04.wav")
	},
	[VOICELINE_PAIN_MED] = {
		Sound("vo/npc/Barney/ba_pain01.wav"),
		Sound("vo/npc/Barney/ba_pain08.wav"),
		Sound("vo/npc/Barney/ba_pain10.wav")
	},
	[VOICELINE_PAIN_HEAVY] = {
		Sound("vo/npc/Barney/ba_pain05.wav"),
		Sound("vo/npc/Barney/ba_pain06.wav"),
		Sound("vo/npc/Barney/ba_pain09.wav")
	},
	[VOICELINE_DEATH] = {
		Sound("vo/npc/Barney/ba_ohshit03.wav"),
		Sound("vo/npc/Barney/ba_no01.wav"),
		Sound("vo/npc/Barney/ba_no02.wav"),
		Sound("vo/npc/Barney/ba_pain03.wav")
	},
	[VOICELINE_EYEPAIN] = {
		Sound("vo/k_lab/ba_thingaway02.wav")
	}
}

VoiceSets[VOICESET_FEMALE] = {
	[VOICELINE_GIVEAMMO] = {
		Sound("vo/npc/female01/ammo03.wav"),
		Sound("vo/npc/female01/ammo04.wav"),
		Sound("vo/npc/female01/ammo05.wav")
	},
	[VOICELINE_PAIN_LIGHT] = {
		Sound("vo/npc/female01/pain01.wav"),
		Sound("vo/npc/female01/pain02.wav"),
		Sound("vo/npc/female01/pain03.wav")
	},
	[VOICELINE_PAIN_MED] = {
		Sound("vo/npc/female01/pain04.wav"),
		Sound("vo/npc/female01/pain05.wav"),
		Sound("vo/npc/female01/pain06.wav")
	},
	[VOICELINE_PAIN_HEAVY] = {
		Sound("vo/npc/female01/pain07.wav"),
		Sound("vo/npc/female01/pain08.wav"),
		Sound("vo/npc/female01/pain09.wav")
	},
	[VOICELINE_DEATH] = {
		Sound("vo/npc/female01/no01.wav"),
		Sound("vo/npc/female01/ow01.wav"),
		Sound("vo/npc/female01/ow02.wav"),
		Sound("vo/npc/female01/goodgod.wav"),
		Sound("ambient/voices/citizen_beaten2.wav")
	},
	[VOICELINE_EYEPAIN] = {
		Sound("ambient/voices/f_scream1.wav")
	}
}

VoiceSets[VOICESET_ALYX] = {
	[VOICELINE_GIVEAMMO] = {
		Sound("vo/npc/female01/ammo03.wav"),
		Sound("vo/npc/female01/ammo04.wav"),
		Sound("vo/npc/female01/ammo05.wav")
	},
	[VOICELINE_PAIN_LIGHT] = {
		Sound("vo/npc/Alyx/gasp03.wav"),
		Sound("vo/npc/Alyx/hurt08.wav")
	},
	[VOICELINE_PAIN_MED] = {
		Sound("vo/npc/Alyx/hurt04.wav"),
		Sound("vo/npc/Alyx/hurt06.wav"),
		Sound("vo/Citadel/al_struggle07.wav"),
		Sound("vo/Citadel/al_struggle08.wav")
	},
	[VOICELINE_PAIN_HEAVY] = {
		Sound("vo/npc/Alyx/hurt05.wav"),
		Sound("vo/npc/Alyx/hurt06.wav")
	},
	[VOICELINE_DEATH] = {
		Sound("vo/npc/Alyx/no01.wav"),
		Sound("vo/npc/Alyx/no02.wav"),
		Sound("vo/npc/Alyx/no03.wav"),
		Sound("vo/Citadel/al_dadgordonno_c.wav"),
		Sound("vo/Streetwar/Alyx_gate/al_no.wav")
	},
	[VOICELINE_EYEPAIN] = {
		Sound("vo/npc/Alyx/uggh01.wav"),
		Sound("vo/npc/Alyx/uggh02.wav")
	}
}

VoiceSets[VOICESET_COMBINE] = {
	[VOICELINE_GIVEAMMO] = {
		Sound("npc/combine_soldier/vo/hardenthatposition.wav"),
		Sound("npc/combine_soldier/vo/readyweapons.wav"),
		Sound("npc/combine_soldier/vo/weareinaninfestationzone.wav"),
		Sound("npc/metropolice/vo/dismountinghardpoint.wav")
	},
	[VOICELINE_PAIN_LIGHT] = {
		Sound("npc/combine_soldier/pain1.wav"),
		Sound("npc/combine_soldier/pain2.wav"),
		Sound("npc/combine_soldier/pain3.wav")
	},
	[VOICELINE_PAIN_MED] = {
		Sound("npc/metropolice/pain1.wav"),
		Sound("npc/metropolice/pain2.wav")
	},
	[VOICELINE_PAIN_HEAVY] = {
		Sound("npc/metropolice/pain3.wav"),
		Sound("npc/metropolice/pain4.wav")
	},
	[VOICELINE_DEATH] = {
		Sound("npc/combine_soldier/die1.wav"),
		Sound("npc/combine_soldier/die2.wav"),
		Sound("npc/combine_soldier/die3.wav")
	},
	[VOICELINE_EYEPAIN] = {
		Sound("npc/combine_soldier/die1.wav"),
		Sound("npc/combine_soldier/die2.wav"),
		Sound("npc/metropolice/vo/shit.wav")
	}
}

VoiceSets[VOICESET_MONK] = {
	[VOICELINE_GIVEAMMO] = {
		Sound("vo/ravenholm/monk_giveammo01.wav")
	},
	[VOICELINE_PAIN_LIGHT] = {
		Sound("vo/ravenholm/monk_pain01.wav"),
		Sound("vo/ravenholm/monk_pain02.wav"),
		Sound("vo/ravenholm/monk_pain03.wav"),
		Sound("vo/ravenholm/monk_pain05.wav")
	},
	[VOICELINE_PAIN_MED] = {
		Sound("vo/ravenholm/monk_pain04.wav"),
		Sound("vo/ravenholm/monk_pain06.wav"),
		Sound("vo/ravenholm/monk_pain07.wav"),
		Sound("vo/ravenholm/monk_pain08.wav")
	},
	[VOICELINE_PAIN_HEAVY] = {
		Sound("vo/ravenholm/monk_pain09.wav"),
		Sound("vo/ravenholm/monk_pain10.wav"),
		Sound("vo/ravenholm/monk_pain12.wav")
	},
	[VOICELINE_DEATH] = {
		Sound("vo/ravenholm/monk_death07.wav")
	},
	[VOICELINE_EYEPAIN] = {
		Sound("vo/ravenholm/monk_death07.wav")
	}
}

local meta = FindMetaTable("Player")
if not meta then return end

function meta:GetVoiceLines(line_type)
	return VoiceSets[self:GetDTInt(DT_PLAYER_INT_VOICESET)][line_type]
end

function meta:PlayEyePainSound()
	local snds = self:GetVoiceLines(VOICELINE_EYEPAIN)
	if snds then
		self:EmitSound(snds[math.random(1, #snds)])
	end
end

function meta:PlayGiveAmmoSound()
	local snds = self:GetVoiceLines(VOICELINE_GIVEAMMO)
	if snds then
		self:EmitSound(snds[math.random(1, #snds)])
	end
end

function meta:PlayDeathSound()
	local snds = self:GetVoiceLines(VOICELINE_DEATH)
	if snds then
		self:EmitSound(snds[math.random(1, #snds)])
	end
end

function meta:PlayZombieDeathSound()
	if not self:CallZombieFunction0("PlayDeathSound") then
		local snds = self:GetZombieClassTable().DeathSounds
		if snds then
			self:EmitSound(snds[math.random(#snds)])
		end
	end
end

function meta:PlayPainSound(health)
	local snds

	if health >= 70 then
		snds = self:GetVoiceLines(VOICELINE_PAIN_LIGHT)
	elseif health >= 35 then
		snds = self:GetVoiceLines(VOICELINE_PAIN_MED)
	else
		snds = self:GetVoiceLines(VOICELINE_PAIN_HEAVY)
	end

	if snds then
		local snd = snds[math.random(#snds)]
		if snd then
			self:EmitSound(snd)
		end
	end
end

function meta:PlayZombiePainSound()
	if self:CallZombieFunction0("PlayPainSound") then return end

	local snds = self:GetZombieClassTable().PainSounds
	if snds then
		local snd = snds[math.random(#snds)]
		if snd then
			self:EmitSound(snd)
		end
	end
end

net.Receive("voice_eyepain", function(len)
	local ent = net.ReadEntity()
	if ent:IsValid() then
		ent:PlayEyePainSound()
	end
end)
net.Receive("voice_giveammo", function(len)
	local ent = net.ReadEntity()
	if ent:IsValid() then
		ent:PlayGiveAmmoSound()
	end
end)
net.Receive("voice_death", function(len)
	local ent = net.ReadEntity()
	if ent:IsValid() then
		ent:PlayDeathSound()
	end
end)
net.Receive("voice_zombiedeath", function(len)
	local ent = net.ReadEntity()
	if ent:IsValid() then
		ent:PlayZombieDeathSound()
	end
end)
net.Receive("voice_pain", function(len)
	local ent = net.ReadEntity()
	local health = net.ReadUInt(4) * 25
	if ent:IsValid() then
		ent:PlayPainSound(health)
	end
end)
net.Receive("voice_zombiepain", function(len)
	local ent = net.ReadEntity()
	if ent:IsValid() then
		ent:PlayZombiePainSound()
	end
end)
