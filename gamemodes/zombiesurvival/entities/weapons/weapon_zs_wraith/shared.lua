-- ============================================================================
-- weapon_zs_wraith/shared.lua - 幽灵（Wraith）僵尸的近战利爪武器
-- 负责：定义幽灵僵尸的近战攻击属性、咆哮警报（AOE 镜头震动）及战斗音效
-- ============================================================================
-- 基于僵尸通用武器母本
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_wraith")

-- 近战攻击间隔（秒）
SWEP.MeleeDelay = 0.8
-- 近战攻击距离（单位）
SWEP.MeleeReach = 48
-- 近战攻击判定球体半径（单位）
SWEP.MeleeSize = 4.5
-- 近战伤害值
SWEP.MeleeDamage = 28
-- 近战伤害类型：劈砍
SWEP.MeleeDamageType = DMG_SLASH
-- 近战攻击动画触发延迟（秒）
SWEP.MeleeAnimationDelay = 0.25

-- 咆哮警报技能的冷却时间（秒）
SWEP.AlertDelay = 6

-- 主攻击（挥爪）间隔（秒）
SWEP.Primary.Delay = 1.8

-- 第一人称手臂模型
SWEP.ViewModel = Model("models/weapons/v_pza.mdl")
-- 世界模型（空字符串 = 不显示掉落物模型）
SWEP.WorldModel = ""

-- ==== StopMoaningSound - 停止持续呻吟声（幽灵不发声，空实现以覆盖母本） ====
function SWEP:StopMoaningSound()
end

-- ==== StartMoaningSound - 播放随机幽灵死亡呻吟声 ====
function SWEP:StartMoaningSound()
	self:GetOwner():EmitSound("zombiesurvival/wraithdeath"..math.random(4)..".ogg")
end

-- ==== PlayHitSound - 播放近战命中音效（随机切片机声） ====
function SWEP:PlayHitSound()
	self:EmitSound("ambient/machines/slicer"..math.random(4)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayMissSound - 播放近战挥空音效（随机僵尸爪子声） ====
function SWEP:PlayMissSound()
	self:EmitSound("npc/zombie/claw_miss"..math.random(2)..".wav", 75, 80, nil, CHAN_AUTO)
end

-- ==== PlayAttackSound - 播放攻击起始音效 ====
function SWEP:PlayAttackSound()
	self:EmitSound("npc/antlion/distract1.wav")
end


-- 对存活实体施加随机方向、按 power 缩放的镜头震动
local function viewpunch(ent, power)
	if ent:IsValid() and ent:Alive() then
		ent:ViewPunch(Angle(math.Rand(0.75, 1) * (math.random(0, 1) == 0 and 1 or -1), math.Rand(0.75, 1) * (math.random(0, 1) == 0 and 1 or -1), math.Rand(0.75, 1) * (math.random(0, 1) == 0 and 1 or -1)) * power)
	end
end

-- ==== DoAlert - 咆哮警报：对以嘴巴前方为球心、92 单位内可见的人类施加镜头震动（距离越近越强） ====
function SWEP:DoAlert()
	local owner = self:GetOwner()

	-- 播放警报音效并给自身一个向上甩的镜头震动
	owner:EmitSound("npc/stalker/go_alert2a.wav", 90)
	owner:ViewPunch(Angle(-20, 0, math.Rand(-10, 10)))
	owner:DoReloadEvent()

	-- 开启延迟补偿，保证命中判定基于对方当时的真实位置
	owner:LagCompensation(true)

	-- 以嘴巴前方 16 单位为球心搜索周围人类
	local mouthpos = owner:EyePos() + owner:GetUp() * -3
	local screampos = mouthpos + owner:GetAimVector() * 16
	for _, ent in pairs(ents.FindInSphere(screampos, 92)) do
		if ent and ent:IsValidHuman() then
			local entearpos = ent:EyePos()
			local dist = screampos:Distance(entearpos)
			-- 视线可见才算命中，距离越近震动越强，并在 0.75 秒内分 5 次衰减抖动
			if dist <= 92 and TrueVisible(entearpos, screampos) then
				local power = (92 / dist - 1) * 2
				viewpunch(ent, power)
				for i=1, 5 do
					timer.Simple(0.15 * i, function() viewpunch(ent, power - i * 0.125) end)
				end
			end
		end
	end

	owner:LagCompensation(false)
end

-- 预缓存咆哮与近战相关音效，避免实战中首次播放卡顿
util.PrecacheSound("npc/antlion/distract1.wav")
util.PrecacheSound("ambient/machines/slicer1.wav")
util.PrecacheSound("ambient/machines/slicer2.wav")
util.PrecacheSound("ambient/machines/slicer3.wav")
util.PrecacheSound("ambient/machines/slicer4.wav")
util.PrecacheSound("npc/zombie/claw_miss1.wav")
util.PrecacheSound("npc/zombie/claw_miss2.wav")
