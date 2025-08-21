-- 本文件为客户端脚本，主要通过扩展Player元表(meta)来为玩家对象添加或修改功能，并处理从服务器接收的相关网络消息，用于更新玩家状态、物理属性和触发客户端效果。

-- meta:FloatingScore 当本地玩家触发时，调用游戏模式的 "FloatingScore" 钩子来显示浮动分数。
-- meta:FixModelAngles 根据玩家的移动速度和朝向，修正其模型角度，使其看起来更自然。
-- meta:RemoveAllStatus 移除玩家所有状态效果的存根函数（无具体实现）。
-- meta:RemoveStatus 移除玩家特定状态效果的存根函数（无具体实现）。
-- meta:HasWon 判断玩家是否已作为人类获胜（处于漫游观察模式）。
-- meta:GetStatus 获取与玩家关联的特定状态实体。
-- meta:GiveStatus 给予玩家特定状态的存根函数（无具体实现）。
-- meta:KnockDown 将玩家击倒的存根函数（无具体实现）。
-- meta:GetThirdPersonCameraPos 计算第三人称摄像机的理想位置，进行碰撞检测以防穿墙。
-- meta:IsFriend 检查目标玩家是否为好友（使用缓存数据以提高性能）。
-- timer.Create("checkfriend") 定时器，周期性地检查并缓存所有玩家的好友状态。
-- meta:SetGroundEntity 如果不存在，则定义一个空的 SetGroundEntity 函数，以保证兼容性。
-- meta:Kill 如果不存在，则定义一个空的 Kill 函数，以保证兼容性。
-- meta:HasWeapon 如果不存在，则定义 HasWeapon 函数，用于检查玩家是否拥有特定武器。
-- meta:SetMaxHealth 设置玩家的最大生命值。
-- meta:GetMaxHealth 获取玩家的最大生命值。
-- meta:DoHulls 根据玩家的队伍和僵尸职业，动态调整其碰撞箱、模型大小、重力、跳跃力等物理属性。
-- meta:GivePenalty 当玩家受到惩罚时，播放警报声。
-- meta:SetZombieClass 设置玩家的僵尸职业，并调用相应的职业切换钩子。
-- meta:GetRateOfPalsy 根据玩家的生命值、恐惧状态和武器晃动，计算准星的晃动幅度。
-- GM.CachedResupplyAmmoType 用于缓存当前补给所用的弹药类型。
-- timer.Create("CacheResupplyAmmoType") 定时器，周期性地更新缓存的补给弹药类型。
-- net.Receive("zs_penalty") 接收服务器消息，对本地玩家执行惩罚效果。
-- net.Receive("zs_dohulls") 接收服务器消息，更新指定玩家的物理属性（DoHulls）。
-- net.Receive("zs_zclass") 接收服务器消息，设置指定玩家的僵尸职业。
-- net.Receive("zs_floatscore") 接收服务器消息，在目标实体位置显示浮动分数。
-- net.Receive("zs_floatscore_vec") 接收服务器消息，在指定三维坐标位置显示浮动分数。
local meta = FindMetaTable("Player")

function meta:FloatingScore(victim, effectname, frags, flags)
	if MySelf == self then
		gamemode.Call("FloatingScore", victim, effectname, frags, flags)
	end
end

function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetRenderAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

function meta:RemoveAllStatus(bSilent, bInstant)
end

function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
end

function meta:HasWon()
	return self:Team() == TEAM_HUMAN and self:GetObserverMode() == OBS_MODE_ROAMING
end

function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent:GetOwner() == self then return ent end
end

function meta:GiveStatus(sType, fDie)
end

function meta:KnockDown(time)
end

local ViewHullMins = Vector(-8, -8, -8)
local ViewHullMaxs = Vector(8, 8, 8)
function meta:GetThirdPersonCameraPos(origin, angles)
	local allplayers = player.GetAll()
	local tr = util.TraceHull({start = origin, endpos = origin + angles:Forward() * -math.max(36, self:Team() == TEAM_UNDEAD and self:GetZombieClassTable().CameraDistance or self:BoundingRadius()), mask = MASK_SHOT, filter = allplayers, mins = ViewHullMins, maxs = ViewHullMaxs})
	return tr.HitPos + tr.HitNormal * 3
end

function meta:IsFriend()
	return self.m_IsFriend
end

timer.Create("checkfriend", 5, 0, function()
	-- This probably isn't the fastest function in the world so I cache it.
	for _, pl in pairs(player.GetAll()) do
		pl.m_IsFriend = pl:GetFriendStatus() == "friend"
	end
end)

if not meta.SetGroundEntity then
	function meta:SetGroundEntity(ent) end
end

if not meta.Kill then
	function meta:Kill() end
end

if not meta.HasWeapon then
	function meta:HasWeapon(class)
		for _, wep in pairs(self:GetWeapons()) do
			if wep:GetClass() == class then return true end
		end

		return false
	end
end

function meta:SetMaxHealth(num)
	self:SetDTInt(0, math.ceil(num))
end

meta.OldGetMaxHealth = FindMetaTable("Entity").GetMaxHealth
function meta:GetMaxHealth()
	return self:GetDTInt(0)
end

function meta:DoHulls(classid, teamid)
	teamid = teamid or self:Team()
	classid = classid or self:GetZombieClass()

	if teamid == TEAM_UNDEAD then
		self:SetIK(false)

		local classtab = GAMEMODE.ZombieClasses[classid]
		if classtab then
			if classtab.ModelScale then
				self:SetModelScale(classtab.ModelScale, 0)
			elseif self:GetModelScale() ~= DEFAULT_MODELSCALE then
				self:SetModelScale(DEFAULT_MODELSCALE, 0)
			end

			if not classtab.Hull or not classtab.HullDuck then
				self:ResetHull()
			end
			if classtab.ViewOffset then
				self:SetViewOffset(classtab.ViewOffset)
			elseif self:GetViewOffset() ~= DEFAULT_VIEW_OFFSET then
				self:SetViewOffset(DEFAULT_VIEW_OFFSET)
			end
			if classtab.ViewOffsetDucked then
				self:SetViewOffsetDucked(classtab.ViewOffsetDucked)
			elseif self:GetViewOffsetDucked() ~= DEFAULT_VIEW_OFFSET_DUCKED then
				self:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
			end
			if classtab.HullDuck then
				self:SetHullDuck(classtab.HullDuck[1], classtab.HullDuck[2])
			end
			if classtab.Hull then
				self:SetHull(classtab.Hull[1], classtab.Hull[2])
			end
			if classtab.StepSize then
				self:SetStepSize(classtab.StepSize)
			elseif self:GetStepSize() ~= DEFAULT_STEP_SIZE then
				self:SetStepSize(DEFAULT_STEP_SIZE)
			end
			if classtab.JumpPower then
				self:SetJumpPower(classtab.JumpPower)
			elseif self:GetJumpPower() ~= DEFAULT_JUMP_POWER then
				self:SetJumpPower(DEFAULT_JUMP_POWER)
			end
			if classtab.Gravity then
				self:SetGravity(classtab.Gravity)
			elseif self:GetGravity() ~= 1 then
				self:SetGravity(1)
			end

			if classtab.ClientsideModelScale then
				self.ClientsideModelScale = Vector(1, 1, 1) * classtab.ClientsideModelScale
				local m = Matrix()
				m:Scale(self.ClientsideModelScale)
				self:EnableMatrix("RenderMultiply", m)
			end
			self.NoCollideAll = classtab.NoCollideAll or (classtab.ModelScale or 1) ~= DEFAULT_MODELSCALE
			--self.NoCollideInside = classtab.NoCollideInside or (classtab.ModelScale or 1) ~= DEFAULT_MODELSCALE
			self.AllowTeamDamage = classtab.AllowTeamDamage
			self.NeverAlive = classtab.NeverAlive
			self.KnockbackScale = classtab.KnockbackScale
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMass(classtab.Mass or DEFAULT_MASS)
			end
		end
	else
		self:SetIK(true)

		self:SetModelScale(DEFAULT_MODELSCALE, 0)
		self:ResetHull()
		self:SetViewOffset(DEFAULT_VIEW_OFFSET)
		self:SetViewOffsetDucked(DEFAULT_VIEW_OFFSET_DUCKED)
		self:SetStepSize(DEFAULT_STEP_SIZE)
		self:SetJumpPower(DEFAULT_JUMP_POWER)
		self:SetGravity(1)

		if self.ClientsideModelScale then
			self.ClientsideModelScale = nil
			self:DisableMatrix("RenderMultiply")
		end
		self.NoCollideAll = nil
		--self.NoCollideInside = nil
		self.AllowTeamDamage = nil
		self.NeverAlive = nil
		self.KnockbackScale = nil
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(DEFAULT_MASS)
		end
	end
end

function meta:GivePenalty(amount)
	surface.PlaySound("ambient/alarms/klaxon1.wav")
end

function meta:SetZombieClass(cl)
	self:CallZombieFunction0("SwitchedAway")

	local classtab = GAMEMODE.ZombieClasses[cl]
	if classtab then
		self.Class = classtab.Index or cl
		self:CallZombieFunction0("SwitchedTo")
	end
end

function meta:GetRateOfPalsy(ft, frightened, health, threshold, gunsway)
	local healthth = health <= threshold and (((threshold - health) / threshold) * 7) or 0

	return ft * (
					(frightened and 14 or healthth) * (MySelf.AimShakeMul or 1) +
					(gunsway and (4 * (MySelf.AimSpreadMul or 1)) or 0)
				)
end

GM.CachedResupplyAmmoType = "scrap"
timer.Create("CacheResupplyAmmoType", 0.3333, 0, function()
	if not GAMEMODE or not MySelf or not MySelf.GetResupplyAmmoType then return end

	GAMEMODE.CachedResupplyAmmoType = MySelf:GetResupplyAmmoType()
end)

net.Receive("zs_penalty", function(length)
	local penalty = net.ReadUInt(16)

	MySelf:GivePenalty(penalty)
end)

net.Receive("zs_dohulls", function(length)
	local ent = net.ReadEntity()
	local classid = net.ReadUInt(8)
	local is_zombie = net.ReadBool()

	if ent:IsValid() then
		ent:DoHulls(classid, is_zombie and TEAM_UNDEAD or TEAM_HUMAN)
	end
end)

net.Receive("zs_zclass", function(length)
	local ent = net.ReadEntity()
	local id = net.ReadUInt(8)

	if ent:IsValidPlayer() then
		ent:SetZombieClass(id)
	end
end)

net.Receive("zs_floatscore", function(length)
	local victim = net.ReadEntity()
	local effectname = net.ReadString()
	local frags = net.ReadInt(24)
	local flags = net.ReadUInt(8)

	if victim and victim:IsValid() then
		MySelf:FloatingScore(victim, effectname, frags, flags)
	end
end)

net.Receive("zs_floatscore_vec", function(length)
	local pos = net.ReadVector()
	local effectname = net.ReadString()
	local frags = net.ReadInt(24)
	local flags = net.ReadUInt(8)

	MySelf:FloatingScore(pos, effectname, frags, flags)
end)
