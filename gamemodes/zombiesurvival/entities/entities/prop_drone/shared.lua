-- ============================================================================
-- prop_drone/shared.lua - 武装无人机（共享定义）
-- 负责：定义人类可部署/遥控的飞行炮台无人机：飞行悬停参数、耐久与弹药、
--       枪口自动追踪逻辑、射线过滤器与血量/状态网络同步接口
-- ============================================================================
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 禁止被钉子解冻
ENT.m_NoNailUnfreeze = true
-- 禁止在表面钉挂
ENT.NoNails = true
-- 可打包回收
ENT.CanPackUp = true
-- 打包所需时间（秒）
ENT.PackUpTime = 0.25

-- 扳手修复效率倍率
ENT.WrenchRepairMultiplier = 0.666
-- 最大弹药量
ENT.MaxAmmo = 450

-- 枪口俯仰角（平滑追踪用）
ENT.FirePitch = 0
-- 枪口偏航角（平滑追踪用）
ENT.FireYaw = 0

-- 飞行加速度
ENT.Acceleration = 170
-- 最大飞行速度
ENT.MaxSpeed = 180
-- 悬停补偿速度
ENT.HoverSpeed = 40
-- 悬停高度
ENT.HoverHeight = 92
-- 悬停维持力
ENT.HoverForce = 128
-- 转向速度
ENT.TurnSpeed = 55
-- 闲置阻力系数
ENT.IdleDrag = 0.25

-- 最大生命值
ENT.MaxHealth = 190
-- 枪械射程
ENT.GunRange = 275
-- 可携带的物体质量上限
ENT.CarryMass = 80

-- 免疫子弹伤害
ENT.IgnoreBullets = true

-- 受到扑击时的伤害倍率弱点
ENT.PounceWeakness = 2
-- 可被幽影（shade）技能抓取
ENT.IsShadeGrabbable = true
-- 属于可飞行控制的载具
ENT.FlyingControllable = true
-- 不阻挡爆炸伤害传播
ENT.NoBlockExplosions = true

-- 部署时消耗的弹药类型
ENT.DeployableAmmo = "drone"
-- 部署后对应的武器
ENT.SWEP = "weapon_zs_drone"
-- 弹药类型
ENT.AmmoType = "smg1"

-- 网络化属性：所属玩家（DT 实体引用）
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

-- ==== BeingControlled - 遥控判定：持有无人机遥控器且处于控制状态 ====
function ENT:BeingControlled()
	local owner = self:GetObjectOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		return wep:IsValid() and wep:GetClass() == "weapon_zs_dronecontrol" and wep:GetDTBool(0)
	end

	return false
end

-- 手动射线过滤器：跳过自身、所有人类玩家、命中盒与巢穴实体
local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team
local temp_attacker
local function ManualTraceFilter(ent)
	if ent == temp_attacker or getmetatable(ent) == M_Player and P_Team(ent) == TEAM_HUMAN or ent.FHB or ent.IsCreeperNest then
		return false
	end

	return true
end

-- ==== GetTraceFilter - 返回手动射线过滤器（记录自身为临时攻击者） ====
function ENT:GetTraceFilter()
	temp_attacker = self
	return ManualTraceFilter
end

local trace_manual = {mask = MASK_SHOT, filter = ManualTraceFilter}
-- ==== GetManualTrace - 从相机位置沿拥有者瞄准方向追踪（射程受技能加成） ====
function ENT:GetManualTrace()
	local owner = self:GetObjectOwner()
	local start = self:GetCameraPosition()

	trace_manual.start = start
	trace_manual.endpos = start + owner:GetAimVector() * (self.GunRange * (owner.DroneGunRangeMul or 1))

	temp_attacker = self

	return util.TraceLine(trace_manual)
end

-- ==== GetLocalAnglesToPos - 换算目标点相对本体的本地角度 ====
function ENT:GetLocalAnglesToPos(pos)
	return self:WorldToLocalAngles(self:GetAnglesToPos(pos))
end

-- ==== GetAnglesToPos - 目标点相对枪口位置的朝向角度 ====
function ENT:GetAnglesToPos(pos)
	return (pos - self:GetRedLightPos()):Angle()
end

-- ==== CalculateFireAngles - 平滑计算枪口俯仰/偏航：朝向瞄准点，受限角钳制 ====
function ENT:CalculateFireAngles()
	local owner = self:GetObjectOwner()
	-- 无拥有者或处于熔毁（材质变化）状态时：枪口回归默认角度
	if not owner:IsValid() or self:GetMaterial() ~= "" then
		self.FireYaw = math.Approach(self.FireYaw, 0, FrameTime() * 60)
		self.FirePitch = math.Approach(self.FirePitch, 15, FrameTime() * 30)
		return
	end

	-- 遥控状态下：枪口平滑转向手动追踪命中点，并钳制俯仰/偏航范围
	if owner:IsValidPlayer() and owner:GetActiveWeapon():IsValid() and owner:GetActiveWeapon():GetClass() == "weapon_zs_dronecontrol" then
		local ang = self:GetLocalAnglesToPos(self:GetManualTrace().HitPos)
		self.FireYaw = math.Clamp(math.NormalizeAngle(ang.yaw), -80, 80)
		self.FirePitch = math.Clamp(math.NormalizeAngle(ang.pitch), -45, 37.5)
	end
end

-- ==== GetGunAngles - 应用枪口俯仰/偏航后的射击角度 ====
function ENT:GetGunAngles()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), -self.FirePitch)
	ang:RotateAroundAxis(ang:Up(), self.FireYaw)
	return ang
end

-- ==== ScanFilter - 扫描过滤器：排除玩家、其他扫描实体与巢穴 ====
function ENT.ScanFilter(ent)
	return not (ent:IsPlayer() or ent.ScanFilter or ent.GetNestMaxHealth)
end

local trace_cam = {mask = MASK_VISIBLE, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
-- ==== GetCameraPosition - 遥控相机位置：枪口到本体的遮挡追踪结果 ====
function ENT:GetCameraPosition(angles)
	local owner = self:GetObjectOwner()
	if owner:IsValidPlayer() then
		angles = angles or owner:EyeAngles()
		trace_cam.start = self:GetPos()
		trace_cam.endpos = self:GetRedLightPos()
		trace_cam.filter = self.ScanFilter
		local tr = util.TraceHull(trace_cam)

		return tr.HitPos + tr.HitNormal * 3
	end

	return self:GetRedLightPos()
end

-- ==== GetObjectHealth - 读取当前血量（网络字段） ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== GetMaxObjectHealth - 读取最大血量 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== GetNextFire - 读取下次开火时间戳 ====
function ENT:GetNextFire()
	return self:GetDTFloat(2)
end

-- ==== GetAmmo - 读取剩余弹药 ====
function ENT:GetAmmo()
	return self:GetDTInt(0)
end

-- ==== IsFiring - 是否正在开火 ====
function ENT:IsFiring()
	return self:GetDTBool(0)
end

-- ==== GetRedLightPos - 枪口/指示灯的世界位置（本地偏移换算） ====
function ENT:GetRedLightPos()
	return self:LocalToWorld(Vector(3, 0, 13.75))
end
