-- ============================================================================
-- 快速僵尸躯干 (Fast Zombie Torso) — 特殊僵尸职业
-- 继承自：zombie_torso
-- 特点：快速僵尸死亡后分裂出的上半身、使用快速僵尸躯干模型、
--       低血量、低速度、隐藏职业
-- ============================================================================

-- 基础职业为"僵尸躯干"
CLASS.Base = "zombie_torso"

-- 隐藏职业
CLASS.Hidden = true

-- 职业显示名称
CLASS.Name = "Fast Zombie Torso"
-- 翻译键名
CLASS.TranslationName = "class_fast_zombie_torso"
-- 描述文本键名
CLASS.Description = "description_fast_zombie_torso"

-- 使用快速僵尸躯干模型
CLASS.Model = Model("models/zombie/fast_torso.mdl")

-- 绑定的武器
CLASS.SWEP = "weapon_zs_fastzombietorso"

-- 生命值
CLASS.Health = 75
-- 移动速度
CLASS.Speed = 150
-- 跳跃力
CLASS.JumpPower = 130

-- 击杀得分
CLASS.Points = CLASS.Health/GM.TorsoZombiePointRatio

-- 受伤/死亡音效（复用快速僵尸音效）
CLASS.PainSounds = {"NPC_FastZombie.Pain"}
-- 死亡音效
CLASS.DeathSounds = {"npc/fast_zombie/leap1.wav"}

-- 语音音调
CLASS.VoicePitch = 0.75

-- 标记为躯干
CLASS.IsTorso = true

-- 缓存动画常量
local ACT_IDLE = ACT_IDLE
local ACT_WALK = ACT_WALK

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return ACT_WALK, -1
end

-- 更新动画（默认）
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
end

-- 服务端逻辑
if SERVER then
	-- 获得第二风时播放狂暴音效
	function CLASS:OnSecondWind(pl)
		pl:EmitSound("NPC_FastZombie.Frenzy")
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fast_torso"
