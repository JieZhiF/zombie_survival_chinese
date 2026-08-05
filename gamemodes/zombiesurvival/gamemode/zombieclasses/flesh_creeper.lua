-- ============================================================================
-- 血肉爬行者 (Flesh Creeper) — 僵尸职业
-- 特点：蚁狮模型、可挖地突进、可扑击、后退时减速、
--       死亡时播放假死动画、自定义攻击动画、肉材质皮肤
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Flesh Creeper"
-- 翻译键名
CLASS.TranslationName = "class_flesh_creeper"
-- 描述文本键名
CLASS.Description = "description_flesh_creeper"
-- 控制帮助文本键名
CLASS.Help = "controls_flesh_creeper"

-- 初始可用/隐藏/非随机起始
CLASS.Wave = 0
-- 隐藏（不直接可选）
CLASS.Hidden = true
-- 初始解锁
CLASS.Unlocked = true
-- 不作为随机起始职业
CLASS.NotRandomStart = true

-- 生命值
CLASS.Health = 175
-- 绑定的武器
CLASS.SWEP = "weapon_zs_fleshcreeper"
-- 蚁狮模型
CLASS.Model = Model("models/antlion.mdl")
-- 移动速度
CLASS.Speed = 160
-- 跳跃力
CLASS.JumpPower = 220

-- 击杀得分
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio

-- 语音音调
CLASS.VoicePitch = 0.55

-- 受伤/死亡音效
CLASS.PainSounds = {Sound("npc/barnacle/barnacle_pull1.wav"), Sound("npc/barnacle/barnacle_pull2.wav"), Sound("npc/barnacle/barnacle_pull3.wav"), Sound("npc/barnacle/barnacle_pull4.wav")}
-- 死亡音效
CLASS.DeathSounds = {Sound("npc/barnacle/barnacle_die1.wav"), Sound("npc/barnacle/barnacle_die2.wav")}

-- 模型缩放
CLASS.ModelScale = 0.65

-- 缓存缩放值（用于碰撞体积计算）
local scale = CLASS.ModelScale
-- 碰撞体积（根据缩放调整）
CLASS.Hull = {Vector(-16 / scale, -16 / scale, 0), Vector(16 / scale, 16 / scale, 36 / scale)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16 / scale, -16 / scale, 0), Vector(16 / scale, 16 / scale, 36 / scale)}

-- 视角偏移
CLASS.ViewOffset = Vector(0, 0, 35.5)
-- 视角偏移（蹲下）
CLASS.ViewOffsetDucked = Vector(0, 0, 35.5)

-- 缓存函数
local CurTime = CurTime
local math_random = math.random
local math_sin = math.sin
local IN_JUMP = IN_JUMP

-- 可用条件：仅动态生成模式且非僵尸逃跑模式
function CLASS:CanUse(pl)
	return GAMEMODE:GetDynamicSpawning() and not GAMEMODE.ZombieEscape
end

-- 移动逻辑
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end

	if mv:GetForwardSpeed() <= 0 then
		mv:SetMaxSpeed(mv:GetMaxSpeed() * 0.45)
		mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.45)
	end
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsInAttackAnim then
		if wep:IsInAttackAnim() then
			return 1, 14
		end
		if wep:GetHoldingRightClick() then
			return 1, 21
		end
	end

	if wep.IsPouncing and wep:IsPouncing() then
		return ACT_GLIDE, -1
	end

	if velocity:Length2DSqr() > 1 then
		return 1, 4
	end

	return 1, 2
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsInAttackAnim then
		if wep:IsInAttackAnim() then
			pl:SetPlaybackRate(0)
			pl:SetCycle(1 - (wep:GetAttackAnimTime() - CurTime()) / wep.Primary.Delay)
			return true
		elseif wep:GetHoldingRightClick() then
			pl:SetPlaybackRate(0)
			local delta = CurTime() - wep:GetRightClickStart()
			if delta > 1 then
				pl:SetCycle(0.5 + math_sin(delta * 12) * 0.05)
			else
				pl:SetCycle(delta / 2)
			end
			return true
		end
	end

	if velocity:Length2DSqr() >= 256 then
		GAMEMODE.BaseClass.UpdateAnimation(GAMEMODE.BaseClass, pl, velocity, maxseqgroundspeed)
		pl:SetPlaybackRate(pl:GetPlaybackRate() / self.ModelScale)
		return true
	end
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		return ACT_INVALID
	end
end

-- 客户端移动指令：扑击时取消跳跃键
function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsSwinging and wep:IsSwinging() and bit.band(cmd:GetButtons(), IN_JUMP) ~= 0 then
		cmd:SetButtons(cmd:GetButtons() - IN_JUMP)
	end
end

-- 脚步声列表
local FootSounds = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav"
}

-- 自定义脚步声
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	pl:EmitSound(FootSounds[math_random(#FootSounds)], 65, math.random(105, 115))
	return true
end

-- 服务端逻辑
if SERVER then
	-- 死亡时播放假死动画
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo)
		local ent = pl:FakeDeath(pl:LookupSequence("Flip1"), self.ModelScale, math.Rand(0.45, 0.5))
		if ent:IsValid() then
			ent:SetMaterial("models/flesh")
		end
		return true
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fleshcreeper"

-- 肉材质
local matFlesh = Material("models/flesh")
-- 绘制前：覆盖为生肉材质
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matFlesh)
end

-- 绘制后：恢复材质
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
end

-- 强制绘制本地玩家
function CLASS:ShouldDrawLocalPlayer()
	return true
end
