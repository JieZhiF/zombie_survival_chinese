-- ============================================================================
-- weapon_zs_hook.lua - 肉钩（Meathook）近战武器
-- 负责：一次性消耗品近战——命中未死的玩家时把肉钩刺入其身体（持续流血
--       2 点 × 20 tick），随后自动消耗掉本武器；含削弱伤害的改造分支
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称与描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_hook")
SWEP.Description = ""..translate.Get("weapon_zs_hook_description")

if CLIENT then
	-- 视模型不翻转，第一人称镜头 FOV
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 60

	-- 隐藏视/世界模型（外观由附加模型拼装）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 第一人称附加模型：右手上的肉钩
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.363, -5), angle = Angle(0, 90, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称附加模型：同款肉钩
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 4, -9), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承通用近战武器基底
SWEP.Base = "weapon_zs_basemelee"

-- 伤害类型：劈砍
SWEP.DamageType = DMG_SLASH

-- 视/世界模型（撬棍占位 + 肉钩世界模型），使用玩家手臂
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_junk/meathook001a.mdl"
SWEP.UseHands = true

-- 近战伤害（随游戏进程倍率缩放），攻击距离与判定盒大小
SWEP.MeleeDamage = 40 * GAMEMODE.LabourTime
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.15

-- 命中/挥空手势动画（近战攻击手势）
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

-- 挥击旋转角度与时长，挥击期间持枪姿势
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.75
SWEP.SwingHoldType = "grenade"

-- 非玻璃武器（可破坏玻璃判定）
SWEP.NoGlassWeapons = true

-- 格挡姿态的偏移与角度
SWEP.BlockPos = Vector(-1, -5, -5)
SWEP.BlockAng = Angle(0, 20, -25)

-- 允许强化（品质改造）
SWEP.AllowQualityWeapons = true
-- 默认不启用削弱效果（改造分支可开启）
SWEP.Weaken = false

-- 附加武器修改器：近战判定提前 0.1 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.1)
-- 改造分支：开启削弱效果，但伤害降低 35%
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_hook_r1"), ""..translate.Get("weapon_zs_hook_r1_description"), function(wept)
	wept.Weaken = true
	wept.MeleeDamage = wept.MeleeDamage * 0.65
end)

-- ==== PlaySwingSound - 挥击音效（冰镐破空） ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(95, 105))
end

-- ==== PlayHitFleshSound - 命中血肉音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.random(120, 130))
end

-- ==== PlayHitSound - 命中硬物音效（金属板撞击） ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_sheet_impact_bullet"..math.random(2)..".wav")
end

-- ==== OnMeleeHit - 近战命中瞬间：命中可存活玩家时把肉钩刺入其身体并消耗武器 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	-- 仅服务端、目标为玩家、未被一击杀死、且无出生保护时才挂钩
	if SERVER and hitent:IsValid() and hitent:IsPlayer() and hitent:Health() > self.MeleeDamage and not hitent.SpawnProtection then
		-- 肉钩朝向：与视线平行的反向旋转
		local ang = self:GetOwner():EyeAngles()
		ang:RotateAroundAxis(ang:Forward(), 180)

		-- 创建肉钩实体，刺入命中点并挂在目标玩家身上
		local ent = ents.Create("prop_meathook")
		if ent:IsValid() then
			ent:SetPos(tr.HitPos)
			ent.BaseWeapon = self:GetClass()
			ent.Weaken = true
			ent:Spawn()
			-- 每 tick 流血 2 点，共 20 tick
			ent.BleedPerTick = 2
			ent.TicksRemaining = 20
			ent:SetOwner(self:GetOwner())
			ent:SetParent(hitent)
			ent:SetAngles(ang)
		end

		-- 命中后立即消耗掉本武器（一次性用品）
		timer.Simple(0, function() self:GetOwner():StripWeapon(self:GetClass()) end)
	end
end
