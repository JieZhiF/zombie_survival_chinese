-- shared.lua

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH -- 支持透明和不透明渲染

-- 关联的武器类名
ENT.SWEP = "weapon_zs_gunturret"

-- 炮塔属性配置
ENT.AmmoType = "smg1"             -- 使用的弹药类型
ENT.FireDelay = 0.1               -- 射击间隔
ENT.NumShots = 1                  -- 每次射击子弹数
ENT.Damage = 9.6                  -- 每发子弹伤害值
ENT.PlayLoopingShootSound = true  -- 是否循环播放射击音效
ENT.Spread = 2                    -- 扩散/精准度
ENT.SearchDistance = 768          -- 自动扫描距离
ENT.MinimumAimDot = 0.5           -- 最小瞄准点（视野范围控制，约60度）
ENT.DefaultAmmo = 0               -- 默认初始弹药
ENT.MaxAmmo = 1919                -- 最大弹药量
ENT.MaxHealth = 150               -- 最大生命值
ENT.ModelScale = 1                -- 模型缩放比例

ENT.NoReviveFromKills = true      -- 杀敌不会触发复活

-- 姿态角度（用于动画）
ENT.PosePitch = 0
ENT.PoseYaw = 0

-- 物理与钉子设置
ENT.m_NoNailUnfreeze = true       -- 防止被钉子解冻
ENT.NoNails = true                -- 不允许被钉子钉住
ENT.IgnoreBullets = true          -- 忽略子弹碰撞（防止挡住自己子弹）

ENT.CanPackUp = true              -- 是否可以被打包收回
ENT.AlwaysGhostable = true        -- 始终可以进入透明摆放模式

local HITGROUP_HEAD = HITGROUP_HEAD
local MASK_SOLID = MASK_SOLID

----------------------------------------
-- 角度与位置计算函数
----------------------------------------

-- 获取目标相对于炮塔的局部角度
function ENT:GetLocalAnglesToTarget(target)
	return self:WorldToLocalAngles(self:GetAnglesToTarget(target))
end

-- 获取指向目标的世界角度
function ENT:GetAnglesToTarget(target)
	return self:GetAnglesToPos(self:GetTargetPos(target))
end

-- 获取指向某个坐标的局部角度
function ENT:GetLocalAnglesToPos(pos)
	return self:WorldToLocalAngles(self:GetAnglesToPos(pos))
end

-- 获取当前位置到指定坐标的角度
function ENT:GetAnglesToPos(pos)
	return (pos - self:ShootPos()):Angle()
end

-- 验证目标是否合法（是否是活着的僵尸、是否在视野内、是否可见）
function ENT:IsValidTarget(target)
	return target:IsPlayer() and target:Team() == TEAM_UNDEAD and target:Alive() 
	and not target:GetZombieClassTable().NoTurretTarget -- 排除不可被锁定的僵尸
	and not target:GetStatus("zombiespawnbuff")        -- 排除有出生Buff的目标
	and self:GetForward():Dot(self:GetAnglesToTarget(target):Forward()) >= self.MinimumAimDot -- 视野检查
	and TrueVisibleFiltered(self:ShootPos(), self:GetTargetPos(target), self, self.Hitbox)      -- 视线阻挡检查
end

----------------------------------------
-- 手动控制逻辑
----------------------------------------

local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team
local temp_attacker
local temp_hb

-- 手动控制时的射线过滤
local function ManualTraceFilter(ent)
	if ent == temp_attacker or ent == temp_hb or (getmetatable(ent) == M_Player and P_Team(ent) == TEAM_HUMAN) then
		return false -- 忽略自己、自己的碰撞箱和队友
	end
	return true
end

local trace_manual = {mask = MASK_SHOT, filter = ManualTraceFilter}

-- 获取手动控制时的准星射线
function ENT:GetManualTrace()
	local owner = self:GetObjectOwner()
	local start = self:ShootPos()

	trace_manual.start = start
	-- 计算射程：基础射程 * 玩家属性加成
	trace_manual.endpos = start + owner:GetAimVector() * self.SearchDistance * (owner.TurretRangeMul or 1)

	temp_attacker = self
	temp_hb = self:GetTurretHitbox()

	return util.TraceLine(trace_manual)
end

----------------------------------------
-- 动画姿态计算（控制炮塔旋转）
----------------------------------------

function ENT:CalculatePoseAngles()
	local deltatime = FrameTime()
	local owner = self:GetObjectOwner()

	-- 如果没有主人、没弹药或正在搬运中，炮塔回归默认位置
	if not owner:IsValid() or self:GetAmmo() <= 0 or self:GetMaterial() ~= "" then
		self.PoseYaw = math.Approach(self.PoseYaw, 0, deltatime * 60)
		self.PosePitch = math.Approach(self.PosePitch, 15, deltatime * 30)
		return
	end

	if self:GetManualControl() then
		-- 手动控制模式：炮塔转向玩家准星指向的位置
		local ang = self:GetLocalAnglesToPos(self:GetManualTrace().HitPos)
		self.PoseYaw = math.Approach(self.PoseYaw, math.Clamp(math.NormalizeAngle(ang.yaw), -60, 60), deltatime * 140)
		self.PosePitch = math.Approach(self.PosePitch, math.Clamp(math.NormalizeAngle(ang.pitch), -15, 15), deltatime * 140)
	else
		-- 自动模式
		local target = self:GetTarget()
		local angm = self:GetScanMaxAngle()
		if target:IsValid() then
			-- 有目标时：追踪目标
			local ang = self:GetLocalAnglesToTarget(target)
			self.PoseYaw = math.Approach(self.PoseYaw, math.Clamp(math.NormalizeAngle(ang.yaw), -60 * angm, 60 * angm), deltatime * 140)
			self.PosePitch = math.Approach(self.PosePitch, math.Clamp(math.NormalizeAngle(ang.pitch), -15 * angm, 15 * angm), deltatime * 100)
		else
			-- 无目标时：左右扫描寻敌
			local ct = CurTime() * self:GetScanSpeed()
			self.PoseYaw = math.Approach(self.PoseYaw, math.sin(ct) * 45 * angm, deltatime * 60)
			self.PosePitch = math.Approach(self.PosePitch, math.cos(ct * 1.4) * 15 * angm, deltatime * 30)
		end
	end
end

----------------------------------------
-- 扫描过滤与目标获取
----------------------------------------

-- 获取扫描时应忽略的实体列表
function ENT:GetScanFilter()
	local filter = team.GetPlayers(TEAM_HUMAN) -- 忽略所有人类
	filter[#filter + 1] = self
	filter[#filter + 1] = self:GetTurretHitbox()
	-- 忽略特定僵尸类（比如隐身类）
	for _, pl in pairs(team.GetPlayers(TEAM_UNDEAD)) do
		if pl:GetZombieClassTable().NoTurretTarget then
			filter[#filter + 1] = pl
		end
	end
	table.Add(filter, ents.FindByClass("prop_ffemitterfield")) -- 忽略力场墙
	return filter
end

-- 缓存过滤器以提高性能（每秒更新一次）
local NextCache = 0
function ENT:GetCachedScanFilter()
	if CurTime() < NextCache and self.CachedFilter then return self.CachedFilter end

	self.CachedFilter = self:GetScanFilter()
	NextCache = CurTime() + 1

	return self.CachedFilter
end

-- 获取目标的射击位置（优先打头）
function ENT:GetTargetPos(target)
	if not (target:IsPlayer() and target:GetZombieClassTable().NoHead) then
		local boneid = target:GetHitBoxBone(HITGROUP_HEAD, 0)
		if boneid and boneid > 0 then
			local bp = target:GetBonePositionMatrixed(boneid)
			if bp then return bp end
		end
	end
	return target:WorldSpaceCenter() -- 如果没头，瞄准中心
end

-- 玩家是否可以拿起
function ENT:HumanHoldable() return true end

-- 坐标获取
function ENT:DefaultPos() return self:GetPos() + self:GetUp() * 55 end

-- 获取枪口位置
function ENT:ShootPos()
	local attachid = self:LookupAttachment("eyes")
	if attachid then
		local attach = self:GetAttachment(attachid)
		if attach then return attach.Pos end
	end
	return self:DefaultPos()
end

-- 获取激光/灯光位置
function ENT:LaserPos()
	local attachid = self:LookupAttachment("light")
	if attachid then
		local attach = self:GetAttachment(attachid)
		if attach then return attach.Pos end
	end
	return self:DefaultPos()
end
ENT.LightPos = ENT.LaserPos

-- 获取当前枪管的旋转角度
function ENT:GetGunAngles()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), -self.PosePitch)
	ang:RotateAroundAxis(ang:Up(), self.PoseYaw)
	return ang
end

----------------------------------------
-- DataTables 读取器 (与服务器状态同步)
----------------------------------------
function ENT:GetAmmo() return self:GetDTInt(0) end
function ENT:GetObjectHealth() return self:GetDTFloat(3) end
function ENT:GetMaxObjectHealth() return self:GetDTInt(1) end
function ENT:GetChannel() return self:GetDTInt(2) end
function ENT:GetTarget() return self:GetDTEntity(0) end
function ENT:GetObjectOwner() return self:GetDTEntity(1) end
function ENT:GetTurretHitbox() return self:GetDTEntity(2) end
function ENT:GetTargetReceived() return self:GetDTFloat(0) end
function ENT:GetTargetLost() return self:GetDTFloat(1) end
function ENT:GetNextFire() return self:GetDTFloat(2) end
function ENT:GetScanSpeed() return self:GetDTFloat(4) end
function ENT:GetScanMaxAngle() return self:GetDTFloat(5) end
function ENT:IsFiring() return self:GetDTBool(0) end

-- 判断是否处于玩家手动控制状态
function ENT:GetManualControl()
	local owner = self:GetObjectOwner()
	if owner:IsValid() and owner:Alive() and owner:Team() == TEAM_HUMAN then
		local wep = owner:GetActiveWeapon()
		-- 必须拿着控制武器并处于激活状态
		if wep:IsValid() and wep:GetClass() == "weapon_zs_gunturretcontrol" and wep.GetTurret and wep:GetTurret() == self and wep:GetDTBool(0) then
			return true
		end
	end
	return false
end

-- 预载入音效
util.PrecacheSound("npc/turret_floor/die.wav")
util.PrecacheSound("npc/turret_floor/active.wav")
util.PrecacheSound("npc/turret_floor/deploy.wav")
util.PrecacheSound("npc/turret_floor/shoot1.wav")
util.PrecacheSound("npc/turret_floor/shoot2.wav")
util.PrecacheSound("npc/turret_floor/shoot3.wav")