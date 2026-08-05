-- ============================================================================
-- 呕吐脓 (Puke Pus) — BOSS僵尸职业
-- 特点：毒僵尸模型、受伤时喷出毒肉块、无手臂骨骼缩放、
--       黄色血液、死亡时大规模毒肉块爆发
-- ============================================================================

-- 职业显示名称
CLASS.Name = "Puke Pus"
-- 翻译键名
CLASS.TranslationName = "class_pukepus"
-- 描述文本键名
CLASS.Description = "description_pukepus"
-- 控制帮助文本键名
CLASS.Help = "controls_pukepus"

-- 标记为BOSS
CLASS.Boss = true

-- 完全免疫击退
CLASS.KnockbackScale = 0

-- 每次出现增加的恐惧值
CLASS.FearPerInstance = 1

-- 生命值
CLASS.Health = 3300
-- 绑定的武器
CLASS.SWEP = "weapon_zs_pukepus"

-- 使用毒僵尸模型
CLASS.Model = Model("models/Zombie/Poison.mdl")

-- 移动速度
CLASS.Speed = 135
-- 击杀得分
CLASS.Points = 40

-- 受伤/死亡音效（毒僵尸专用）
CLASS.PainSounds = {"NPC_PoisonZombie.Pain"}
-- 死亡音效
CLASS.DeathSounds = {Sound("npc/zombie_poison/pz_call1.wav")}

-- 语音音调
CLASS.VoicePitch = 0.5

-- 视角偏移和碰撞体积
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

-- 黄色血液
CLASS.BloodColor = BLOOD_COLOR_YELLOW

-- 缓存函数
local math_random = math.random
local math_min = math.min

-- 缓存常量和动画
local ACT_IDLE = ACT_IDLE
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE

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
		return (365 - pl:GetVelocity():Length()) * 1.5
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 450
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 600
	end
	return 200
end

-- 更新动画速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if len2d > 1 then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.5, 3))
	else
		pl:SetPlaybackRate(0.5)
	end
	return true
end

-- 服务端逻辑：生成时播放环境音效
if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("pukepusambience")
	end
end

-- 需要缩放到零的手臂骨骼列表
local BonesToZero = {
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_R_Finger1",
	"ValveBiped.Bip01_R_Finger11",
	"ValveBiped.Bip01_R_Finger12",
	"ValveBiped.Bip01_R_Finger2",
	"ValveBiped.Bip01_R_Finger21",
	"ValveBiped.Bip01_R_Finger22",
	"ValveBiped.Bip01_R_Finger3",
	"ValveBiped.Bip01_R_Finger31",
	"ValveBiped.Bip01_R_Finger32"
}

-- 构建骨骼位置：隐藏手臂骨骼
function CLASS:BuildBonePositions(pl)
	for _, bone in pairs(BonesToZero) do
		local boneid = pl:LookupBone(bone)
		if boneid and boneid > 0 then
			pl:ManipulateBoneScale(boneid, vector_tiny)
		end
	end
end

-- 创建毒肉块飞溅效果
local function CreateFlesh(pl, damage, damagepos, damagedir)
	damage = math.min(damage, 300)

	pl:EmitSound(string.format("physics/body/body_medium_break%d.wav", math.random(2, 4)), 74, 125 - damage * 0.50)

	if SERVER then
		damagepos = pl:LocalToWorld(damagepos)

		for i=1, math.max(1, math.floor(damage / 12)) do
			local ent = ents.Create("projectile_poisonflesh")
			if ent:IsValid() then
				local heading = (damagedir + VectorRand() * 0.3):GetNormalized()
				ent:SetPos(damagepos + heading)
				ent:SetOwner(pl)
				ent:Spawn()

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:SetVelocityInstantaneous(math.min(325, 100 + damage ^ math.Rand(1.15, 1.25)) * heading)
				end
			end
		end
	end
end

-- 受伤时喷射毒肉块
function CLASS:ProcessDamage(pl, dmginfo)
	local attacker, damage = dmginfo:GetAttacker(), dmginfo:GetDamage()
	if attacker ~= pl and damage >= 5 and damage < pl:Health() and CurTime() >= (pl.m_NextPukeEmit or 0) then
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

-- 服务端逻辑：死亡时掉落武器箱并触发大规模毒肉块爆发
if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
        -- 掉落武器
        local pos = pl:LocalToWorld(pl:OBBCenter())
        local ent = ents.Create("prop_weapon")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:SetAngles(AngleRand())
            ent:SetWeaponType("weapon_zs_box")
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:SetVelocityInstantaneous(VectorRand():GetNormalized() * math.Rand(24, 100))
                phys:AddAngleVelocity(VectorRand() * 200)
            end
        end

		local pos = pl:WorldToLocal(dmginfo:GetDamagePosition())
		local norm = dmginfo:GetDamageForce():GetNormalized() * -1
		timer.Simple(0, function()
			if pl:IsValid() then
				CreateFlesh(pl, 300, pos, norm)
			end
		end)
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/pukepus"

-- 藤壶皮肤材质
local matSkin = Material("Models/Barnacle/barnacle_sheet")
-- 绘制前覆盖材质为藤壶皮肤
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
end

-- 绘制后恢复材质
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
end
