-- ============================================================================
-- prop_rollermine/shared.lua - 滚动地雷（共享定义）
-- 负责：定义人类可部署/遥控的滚动地雷基础属性：移动参数、耐久、
--       撞击伤害与碰撞豁免规则，以及血量/所属者的网络同步接口
-- ============================================================================
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 禁止被钉子解冻（防御工事系统相关）
ENT.m_NoNailUnfreeze = true
-- 禁止在表面钉挂
ENT.NoNails = true

-- 扳手修复效率倍率（0.25 倍）
ENT.WrenchRepairMultiplier = 0.25

-- 实体模型：滚动地雷
ENT.Model = "models/roller.mdl"
-- 命中判定半径（单位）
ENT.HitBoxSize = 11.5
-- 物理质量
ENT.Mass = 50
-- 部署后对应的武器
ENT.WeaponClass = "weapon_zs_rollermine"
-- 对应的遥控器武器
ENT.ControllerClass = "weapon_zs_rollerminecontrol"
-- 弹药类型
ENT.AmmoType = "rollermine"

-- 加速度
ENT.Acceleration = 900
-- 最大移动速度
ENT.MaxSpeed = 450
-- 转向速度
ENT.TurnSpeed = 30
-- 闲置状态下的空气阻力系数
ENT.IdleDrag = 0.25

-- 最大生命值
ENT.MaxHealth = 225
-- 两次撞击伤害的最小间隔（秒）
ENT.HitCooldown = 1.15
-- 撞击对目标造成的伤害
ENT.HitDamage = 25
-- 命中血肉时的反弹速度
ENT.BounceFleshVelocity = 320

-- 免疫子弹伤害
ENT.IgnoreBullets = true
-- 可被幽影（shade）技能抓取
ENT.IsShadeGrabbable = true
-- 不阻挡爆炸伤害传播
ENT.NoBlockExplosions = true

-- 网络化属性：所属玩家（通过 DT 实体引用跨端同步）
AccessorFuncDT(ENT, "ObjectOwner", "Entity", 0)

-- ==== ShouldNotCollide - 碰撞豁免：人类发射的投射物与人类玩家直接穿过 ====
function ENT:ShouldNotCollide(ent)
	-- 人类发射的普通投射物（非蓄力类）不与其碰撞
	if not ent.ChargeTime and ent:IsProjectile() then
		local owner = ent:GetOwner()
		if owner:IsValidHuman() then
			return true
		end
	end

	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- ==== SetObjectHealth - 写入血量到网络字段，归零时标记销毁 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 and not self.Destroyed then
		self.Destroyed = true
	end
end

-- ==== BeingControlled - 判断是否正被遥控：持有遥控器且处于控制状态 ====
function ENT:BeingControlled()
	local owner = self:GetObjectOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		return wep:IsValid() and wep:GetClass() == self.ControllerClass and wep:GetDTBool(0)
	end

	return false
end

-- ==== GetObjectHealth - 读取当前血量（网络字段） ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== SetMaxObjectHealth - 写入最大血量到网络字段 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== GetMaxObjectHealth - 读取最大血量 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

local vecOffset = Vector(0, 0, -3)
-- ==== GetRedLightPos - 红色警示灯的世界位置（本地偏移换算） ====
function ENT:GetRedLightPos()
	return self:LocalToWorld(vecOffset)
end

-- ==== GetRedLightAngles - 红色警示灯的角度 ====
function ENT:GetRedLightAngles()
	return self:GetAngles()
end
