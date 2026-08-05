-- ============================================================================
-- 经典僵尸 (Classic Zombie) — 特殊僵尸职业
-- 继承自：freshdead
-- 特点：隐藏职业、比Fresh Dead更强、拥有爬墙功能、无摔落伤害、
--       专为地图设计者准备的定制职业
-- ============================================================================

-- 这是特殊职业，本质上是对Fresh Dead的强化版本，供地图作者使用。
-- 它也有爬墙功能，但不如Fast Zombie，防止玩家利用地形。
CLASS.Base = "freshdead"

-- 隐藏职业
CLASS.Hidden = true

-- 职业显示名称
CLASS.Name = "Classic Zombie"
-- 翻译键名
CLASS.TranslationName = "class_classic_zombie"

-- 生命值
CLASS.Health = 150
-- 移动速度
CLASS.Speed = 200
-- 击杀得分
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 绑定的武器
CLASS.SWEP = "weapon_zs_classiczombie"

-- 使用玩家模型
CLASS.UsePlayerModel = true
-- 不使用之前的模型
CLASS.UsePreviousModel = false
-- 无摔落伤害
CLASS.NoFallDamage = true

-- 缓存动作常量
local ACT_ZOMBIE_CLIMB_UP = ACT_ZOMBIE_CLIMB_UP
local math_Clamp = math.Clamp

-- 服务端：被击杀时不做特殊处理
if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end
end

-- 移动逻辑：处理武器移动
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.Move and wep:Move(mv) then
		return true
	end
end

-- 计算主要活动动画（爬墙时播放爬墙动画）
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end
	return self.BaseClass.CalcMainActivity(self, pl, velocity)
end

-- 更新动画播放速率
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		local vel = pl:GetVelocity()
		local speed = vel:LengthSqr()
		if speed > 64 then
			pl:SetPlaybackRate(math_Clamp(speed / 3600, 0, 1) * (vel.z < 0 and -1 or 1) * 0.25)
		else
			pl:SetPlaybackRate(0)
		end
		return true
	end
	return self.BaseClass.UpdateAnimation(self, pl, velocity, maxseqgroundspeed)
end
