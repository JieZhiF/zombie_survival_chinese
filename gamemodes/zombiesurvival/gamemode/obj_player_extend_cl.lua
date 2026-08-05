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

-- 获取玩家（Player）的元表，用于在客户端扩展功能
local meta = FindMetaTable("Player")

-- 在本地玩家的目标上调用FloatingScore钩子，显示浮动分数
function meta:FloatingScore(victim, effectname, frags, flags)
	if MySelf == self then
		gamemode.Call("FloatingScore", victim, effectname, frags, flags)
	end
end

-- 根据玩家的移动速度和朝向，修正其模型角度
-- 计算move_yaw姿势参数使模型朝向看起来更自然
function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetRenderAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

-- 移除玩家所有状态效果的客户端占位函数（无具体实现）
function meta:RemoveAllStatus(bSilent, bInstant)
end

-- 移除玩家特定状态效果的客户端占位函数（无具体实现）
function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
end

-- 判断玩家是否已作为人类获胜（处于漫游观察模式）
function meta:HasWon()
	return self:Team() == TEAM_HUMAN and self:GetObserverMode() == OBS_MODE_ROAMING
end

-- 获取与玩家关联的特定状态实体
function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent:GetOwner() == self then return ent end
end

-- 给予玩家特定状态的客户端占位函数（无具体实现）
function meta:GiveStatus(sType, fDie)
end

-- 将玩家击倒的客户端占位函数（无具体实现）
function meta:KnockDown(time)
end

-- 第三人称摄像机碰撞检测的包围盒大小
local ViewHullMins = Vector(-8, -8, -8)
local ViewHullMaxs = Vector(8, 8, 8)

-- 计算第三人称摄像机的理想位置
-- 进行碰撞检测以防止摄像机穿墙
function meta:GetThirdPersonCameraPos(origin, angles)
	local allplayers = player.GetAll()
	-- 从摄像机位置向后发射包围盒检测，寻找无障碍位置
	local tr = util.TraceHull({start = origin, endpos = origin + angles:Forward() * -math.max(36, self:Team() == TEAM_UNDEAD and self:GetZombieClassTable().CameraDistance or self:BoundingRadius()), mask = MASK_SHOT, filter = allplayers, mins = ViewHullMins, maxs = ViewHullMaxs})
	return tr.HitPos + tr.HitNormal * 3
end

-- 检查目标玩家是否为好友（使用缓存的m_IsFriend值）
function meta:IsFriend()
	return self.m_IsFriend
end

-- 定时器：每5秒检查并缓存所有玩家的好友状态
timer.Create("checkfriend", 5, 0, function()
	for _, pl in pairs(player.GetAll()) do
		pl.m_IsFriend = pl:GetFriendStatus() == "friend"
	end
end)

-- 如果不存在SetGroundEntity函数，定义一个空函数以保证兼容性
if not meta.SetGroundEntity then
	function meta:SetGroundEntity(ent) end
end

-- 如果不存在Kill函数，定义一个空函数以保证兼容性
if not meta.Kill then
	function meta:Kill() end
end

-- 如果不存在HasWeapon函数，定义一个实现以检查玩家是否拥有特定武器
if not meta.HasWeapon then
	function meta:HasWeapon(class)
		for _, wep in pairs(self:GetWeapons()) do
			if wep:GetClass() == class then return true end
		end

		return false
	end
end

-- 设置玩家的最大生命值（同步到网络数据表）
function meta:SetMaxHealth(num)
	self:SetDTInt(0, math.ceil(num))
end

-- 保存原始GetMaxHealth方法并重写为从网络数据表读取
meta.OldGetMaxHealth = FindMetaTable("Entity").GetMaxHealth
function meta:GetMaxHealth()
	return self:GetDTInt(0)
end

-- 根据玩家的队伍和僵尸职业，动态调整其碰撞箱、模型大小、重力、跳跃力等物理属性
-- 在客户端执行视觉和物理相关的调整
function meta:DoHulls(classid, teamid)
	teamid = teamid or self:Team()
	classid = classid or self:GetZombieClass()

	if teamid == TEAM_UNDEAD then
		-- 僵尸模式：禁用IK，应用职业配置
		self:SetIK(false)

		local classtab = GAMEMODE.ZombieClasses[classid]
		if classtab then
			-- 设置模型缩放
			if classtab.ModelScale then
				self:SetModelScale(classtab.ModelScale, 0)
			elseif self:GetModelScale() ~= DEFAULT_MODELSCALE then
				self:SetModelScale(DEFAULT_MODELSCALE, 0)
			end

			-- 设置碰撞箱
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
			-- 设置步高
			if classtab.StepSize then
				self:SetStepSize(classtab.StepSize)
			elseif self:GetStepSize() ~= DEFAULT_STEP_SIZE then
				self:SetStepSize(DEFAULT_STEP_SIZE)
			end
			-- 设置跳跃力
			if classtab.JumpPower then
				self:SetJumpPower(classtab.JumpPower)
			elseif self:GetJumpPower() ~= DEFAULT_JUMP_POWER then
				self:SetJumpPower(DEFAULT_JUMP_POWER)
			end
			-- 设置重力
			if classtab.Gravity then
				self:SetGravity(classtab.Gravity)
			elseif self:GetGravity() ~= 1 then
				self:SetGravity(1)
			end

			-- 客户端模型缩放（使用矩阵实现非均匀缩放）
			if classtab.ClientsideModelScale then
				self.ClientsideModelScale = Vector(1, 1, 1) * classtab.ClientsideModelScale
				local m = Matrix()
				m:Scale(self.ClientsideModelScale)
				self:EnableMatrix("RenderMultiply", m)
			end
			-- 设置各种碰撞和物理属性
			self.NoCollideAll = classtab.NoCollideAll or (classtab.ModelScale or 1) ~= DEFAULT_MODELSCALE
			self.AllowTeamDamage = classtab.AllowTeamDamage
			self.NeverAlive = classtab.NeverAlive
			self.KnockbackScale = classtab.KnockbackScale
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMass(classtab.Mass or DEFAULT_MASS)
			end
		end
	else
		-- 人类模式：重置所有属性为默认值
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
		self.AllowTeamDamage = nil
		self.NeverAlive = nil
		self.KnockbackScale = nil
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(DEFAULT_MASS)
		end
	end
end

-- 当玩家受到惩罚时，播放警报声
function meta:GivePenalty(amount)
	surface.PlaySound("ambient/alarms/klaxon1.wav")
end

-- 设置玩家的僵尸职业
-- 调用职业切换的钩子函数并更新职业数据
function meta:SetZombieClass(cl)
	self:CallZombieFunction0("SwitchedAway")

	local classtab = GAMEMODE.ZombieClasses[cl]
	if classtab then
		self.Class = classtab.Index or cl
		self:CallZombieFunction0("SwitchedTo")
	end
end

-- 根据玩家的生命值、恐惧状态和武器晃动，计算准星的晃动幅度
-- 用于增加低生命值或恐惧状态下的瞄准难度
function meta:GetRateOfPalsy(ft, frightened, health, threshold, gunsway)
	local healthth = health <= threshold and (((threshold - health) / threshold) * 7) or 0

	return ft * (
					(frightened and 14 or healthth) * (MySelf.AimShakeMul or 1) +
					(gunsway and (4 * (MySelf.AimSpreadMul or 1)) or 0)
				)
end

-- 缓存的当前补给弹药类型，默认为"scrap"
GM.CachedResupplyAmmoType = "scrap"
-- 定时器：每0.3333秒更新缓存的补给弹药类型
timer.Create("CacheResupplyAmmoType", 0.3333, 0, function()
	if not GAMEMODE or not MySelf or not MySelf.GetResupplyAmmoType then return end

	GAMEMODE.CachedResupplyAmmoType = MySelf:GetResupplyAmmoType()
end)

-- 接收服务器消息：对本地玩家执行惩罚效果
net.Receive(NET_MSG.PENALTY, function(length)
	local penalty = net.ReadUInt(16)

	MySelf:GivePenalty(penalty)
end)

-- 接收服务器消息：更新指定玩家的物理属性（DoHulls）
net.Receive(NET_MSG.DOHULLS, function(length)
	local ent = net.ReadEntity()
	local classid = net.ReadUInt(8)
	local is_zombie = net.ReadBool()

	if ent:IsValid() then
		ent:DoHulls(classid, is_zombie and TEAM_UNDEAD or TEAM_HUMAN)
	end
end)

-- 接收服务器消息：设置指定玩家的僵尸职业
net.Receive(NET_MSG.ZCLASS, function(length)
	local ent = net.ReadEntity()
	local id = net.ReadUInt(8)

	if ent:IsValidPlayer() then
		ent:SetZombieClass(id)
	end
end)

-- 接收服务器消息：在目标实体位置显示浮动分数
net.Receive(NET_MSG.FLOATSCORE, function(length)
	local victim = net.ReadEntity()
	local effectname = net.ReadString()
	local frags = net.ReadInt(24)
	local flags = net.ReadUInt(8)

	if victim and victim:IsValid() then
		MySelf:FloatingScore(victim, effectname, frags, flags)
	end
end)

-- 接收服务器消息：在指定三维坐标位置显示浮动分数
net.Receive(NET_MSG.FLOATSCORE_VEC, function(length)
	local pos = net.ReadVector()
	local effectname = net.ReadString()
	local frags = net.ReadInt(24)
	local flags = net.ReadUInt(8)

	MySelf:FloatingScore(pos, effectname, frags, flags)
end)
