-- ============================================================================
-- prop_drone_hauler/shared.lua - 搬运无人机（共享）
-- 负责：可部署的悬浮搬运机器人：可被玩家遥控飞行、用绳索拖拽可搬运道具，
--       拥有独立的血量/加速度/悬停等属性；共享端定义属性、控制判定
--       与射线过滤器，并同步所有者/血量/索具状态到客户端
-- ============================================================================
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 不可被钉子解除冻结/加固，可被打包收起（耗时 0.25 秒）
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true
ENT.CanPackUp = true
ENT.PackUpTime = 0.25

-- 扳手修复效率倍率（耐久回复 2/3 效率）
ENT.WrenchRepairMultiplier = 0.666

-- 机身朝向的偏航/俯仰偏移（初始为 0）
ENT.FirePitch = 0
ENT.FireYaw = 0

-- 飞行物理参数：加速度、最大速度、悬停阈值速度与高度、悬停修正力、转向速度、怠速阻力
ENT.Acceleration = 350
ENT.MaxSpeed = 400
ENT.HoverSpeed = 40
ENT.HoverHeight = 92
ENT.HoverForce = 128
ENT.TurnSpeed = 90
ENT.IdleDrag = 0.25

-- 耐久上限与可拖拽道具的最大质量
ENT.MaxHealth = 190
ENT.CarryMass = 150

-- 免疫子弹伤害
ENT.IgnoreBullets = true

-- 扑咬伤害弱点倍率；可被暗影爪钩抓取；可被控制飞行；不阻挡爆炸
ENT.PounceWeakness = 2
ENT.IsShadeGrabbable = true
ENT.FlyingControllable = true
ENT.NoBlockExplosions = true

-- 打包后返回的弹药类型与对应武器
ENT.DeployableAmmo = "drone_hauler"
ENT.SWEP = "weapon_zs_drone_hauler"

-- DT 访问器：无人机的所有者（玩家）
AccessorFuncDT(ENT, "ObjectOwner", "Entity", 0)

-- ==== ShouldNotCollide - 碰撞豁免判定：人类玩家的投射物与人类本体不碰撞 ====
function ENT:ShouldNotCollide(ent)
	-- 非蓄力类的投射物且发射者为人类时穿过无人机
	if not ent.ChargeTime and ent:IsProjectile() then
		local owner = ent:GetOwner()
		if owner:IsValidHuman() then
			return true
		end
	end

	-- 人类玩家本体不碰撞（防止挡路）
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- ==== BeingControlled - 是否正被所有者用无人机遥控器操控 ====
function ENT:BeingControlled()
	local owner = self:GetObjectOwner()
	if owner:IsValid() then
		-- 所有者手持无人机遥控器且处于激活状态时视为被操控
		local wep = owner:GetActiveWeapon()
		return wep:IsValid() and wep:GetClass() == "weapon_zs_dronecontrol" and wep:GetDTBool(0)
	end

	return false
end

-- 缓存 Player 元表与 Team 方法（热路径性能优化）
local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team
-- 当前追踪的投射物发射者（供过滤器比较）
local temp_attacker
-- ==== ManualTraceFilter - 手动射线过滤器：排除无人机自身与人类玩家 ====
local function ManualTraceFilter(ent)
	if ent == temp_attacker or getmetatable(ent) == M_Player and P_Team(ent) == TEAM_HUMAN or ent.FHB or ent.IsCreeperNest then
		return false
	end

	return true
end

-- ==== GetTraceFilter - 返回索具射线过滤器（排除无人机自身/人类/出生点/巢穴） ====
function ENT:GetTraceFilter()
	temp_attacker = self
	return ManualTraceFilter
end

-- ==== ScanFilter - 摄像头扫描过滤器：排除玩家与无人机/巢穴类实体 ====
function ENT.ScanFilter(ent)
	return not (ent:IsPlayer() or ent.ScanFilter or ent.GetNestMaxHealth)
end

-- 摄像头射线追踪参数：可见性遮罩 + 4 单位盒体
local trace_cam = {mask = MASK_VISIBLE, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4)}
-- ==== GetCameraPosition - 计算控制者第一人称视角位置（视线被遮挡时紧贴障碍物） ====
function ENT:GetCameraPosition(angles)
	local owner = self:GetObjectOwner()
	if owner:IsValidPlayer() then
		angles = angles or owner:EyeAngles()
		trace_cam.start = self:GetPos()
		trace_cam.endpos = self:GetRedLightPos()
		trace_cam.filter = self.ScanFilter
		local tr = util.TraceHull(trace_cam)

		-- 命中点沿法线外推 3 单位，避免摄像机陷入墙体
		return tr.HitPos + tr.HitNormal * 3
	end

	return self:GetRedLightPos()
end

-- ==== GetObjectHealth - 读取无人机当前耐久 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== GetMaxObjectHealth - 读取无人机耐久上限 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== GetNextFire - 读取下一次索具发射时间 ====
function ENT:GetNextFire()
	return self:GetDTFloat(2)
end

-- ==== IsGrappling - 是否正拖拽着道具 ====
function ENT:IsGrappling()
	return self:GetDTBool(1)
end

-- ==== GetRedLightPos - 获取机身红灯光源位置（局部坐标偏移换算到世界） ====
function ENT:GetRedLightPos()
	return self:LocalToWorld(Vector(2, -6, 2))
end
