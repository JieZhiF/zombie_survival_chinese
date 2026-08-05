-- ============================================================================
-- 弹弓僵尸躯干 (Slingshot Zombie Torso) — 特殊僵尸职业
-- 继承自：zombie_torso
-- 特点：弹弓僵尸死亡后分裂出的上半身、可扑击、无摔落伤害、
--       扑击时视角锁定、暗红色调
-- ============================================================================

-- 基础职业为"僵尸躯干"
CLASS.Base = "zombie_torso"

-- 隐藏职业
CLASS.Hidden = true

-- 职业显示名称
CLASS.Name = "Slingshot Zombie Torso"
-- 翻译键名
CLASS.TranslationName = "class_fast_zombie_torso_slingshot"
-- 描述文本键名
CLASS.Description = "description_fast_zombie_torso_slingshot"

-- 使用快速僵尸躯干模型
CLASS.Model = Model("models/zombie/fast_torso.mdl")

-- 碰撞体积
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 28)}
-- 碰撞体积（蹲下）
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 28)}

-- 绑定的武器
CLASS.SWEP = "weapon_zs_fastzombietorso_slingshot"

-- 生命值
CLASS.Health = 140
-- 移动速度
CLASS.Speed = 160
-- 跳跃力
CLASS.JumpPower = 130

-- 击杀得分
CLASS.Points = CLASS.Health/GM.TorsoZombiePointRatio

-- 受伤/死亡音效
CLASS.PainSounds = {"NPC_FastZombie.Pain"}
-- 死亡音效
CLASS.DeathSounds = {"npc/fast_zombie/leap1.wav"}

-- 语音音调
CLASS.VoicePitch = 0.75

-- 标记为躯干
CLASS.IsTorso = true

-- 无摔落伤害/减速
CLASS.NoFallDamage = true
-- 无摔落减速
CLASS.NoFallSlowdown = true

-- 缓存函数
local math_min = math.min
local ACT_IDLE = ACT_IDLE
local ACT_WALK = ACT_WALK

-- 移动逻辑
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end
end

-- 计算主要活动动画
function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end
	return ACT_WALK, -1
end

-- 更新动画
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local len2d = velocity:Length2D()
	if pl:IsOnGround() then
		pl:SetPlaybackRate(math_min(len2d / maxseqgroundspeed * 0.66, 3))
	else
		pl:SetPlaybackRate(1)
	end
	return true
end

-- 服务端逻辑：扑击时受伤中断扑击
if SERVER then
	function CLASS:ProcessDamage(pl, dmginfo)
		local wep = pl:GetActiveWeapon()
		if wep:IsValid() and wep.IsPouncing and wep:IsPouncing() then
			if dmginfo:GetAttacker():IsValidLivingHuman() and dmginfo:GetDamage() >= 8 then
				wep:StopPounce()
				pl:SetLocalVelocity(pl:GetVelocity() * 0.9)
			end
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fast_torso"
-- 图标颜色（锈红色）
CLASS.IconColor = Color(163, 94, 99)

-- 客户端移动指令：扑击时视角锁定
function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsPouncing and wep.m_ViewAngles then
		local maxdiff = FrameTime() * 20
		local mindiff = -maxdiff
		local originalangles = wep.m_ViewAngles
		local viewangles = cmd:GetViewAngles()

		local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
		if diff > maxdiff or diff < mindiff then
			viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
		end

		wep.m_ViewAngles = viewangles
		cmd:SetViewAngles(viewangles)
	end
end

-- 皮肤材质和颜色
local matSkin = Material("models/barnacle/barnacle_sheet")

-- 绘制前：覆盖藤壶材质并调色
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(0.64, 0.37, 0.39)
end

-- 绘制后：恢复材质和颜色
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
