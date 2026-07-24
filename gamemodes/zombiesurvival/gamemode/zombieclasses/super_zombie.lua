--[[
==================================================================
超级僵尸 (Super Zombie) — 特殊僵尸职业
继承自：freshdead
特点：超高血量（8888）、僵尸逃跑模式专用速度、可爬墙、
      无摔落伤害、隐藏职业
==================================================================
]]

-- 基础职业为"新鲜死者"
CLASS.Base = "freshdead"

-- 隐藏职业
CLASS.Hidden = true

-- 职业显示名称
CLASS.Name = "Super Zombie"
-- 翻译键名
CLASS.TranslationName = "class_super_zombie"

-- 超高血量
CLASS.Health = 8888
-- 使用僵尸逃跑模式的僵尸速度
CLASS.Speed = SPEED_ZOMBIEESCAPE_ZOMBIE
-- 极低得分
CLASS.Points = 5

-- 绑定的武器
CLASS.SWEP = "weapon_zs_superzombie"

-- 使用玩家模型
CLASS.UsePlayerModel = true
CLASS.UsePreviousModel = false
-- 无摔落伤害
CLASS.NoFallDamage = true

-- 缓存的动画和函数
local ACT_ZOMBIE_CLIMB_UP = ACT_ZOMBIE_CLIMB_UP
local math_Clamp = math.Clamp

-- 服务端逻辑
if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end

	-- 备用使用键：非僵尸逃跑模式时触发装死
	function CLASS:AltUse(pl)
		if not GAMEMODE.ZombieEscape then
			pl:StartFeignDeath()
		end
	end
end

-- 移动逻辑
function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.Move and wep:Move(mv) then
		return true
	end
end

-- 活动动画（爬墙支持）
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end
	return self.BaseClass.CalcMainActivity(self, pl, velocity)
end

-- 更新动画
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

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/fresh_dead"
