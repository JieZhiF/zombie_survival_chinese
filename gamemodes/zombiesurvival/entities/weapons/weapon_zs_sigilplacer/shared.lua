-- 定义武器的基本属性
SWEP.PrintName = ""..translate.Get("weapon_zs_sigilplacer") -- 武器在游戏中的显示名称。此处使用了翻译函数，以便支持多语言。

-- 武器模型设置
SWEP.ViewModel = "models/weapons/c_pistol.mdl" -- 玩家第一人称视角下看到的武器模型。
SWEP.WorldModel = "models/weapons/w_pistol.mdl" -- 玩家或其他玩家在第三人称视角下看到的武器模型。
SWEP.UseHands = true -- 武器是否使用玩家的手部模型。

-- 主要攻击（Primary Attack）设置
SWEP.Primary.ClipSize = -1 -- 主弹匣容量，-1 表示无限弹药或不使用弹药。
SWEP.Primary.DefaultClip = -1 -- 默认弹匣容量，-1 表示无限弹药。
SWEP.Primary.Automatic = false -- 主攻击是否为自动模式（按住不放持续射击），此处为非自动。
SWEP.Primary.Ammo = "none" -- 主攻击消耗的弹药类型，"none" 表示不消耗弹药。

-- 次要攻击（Secondary Attack）设置
SWEP.Secondary.ClipSize = -1 -- 副弹匣容量，-1 表示无限弹药或不使用弹药。
SWEP.Secondary.DefaultClip = -1 -- 默认副弹匣容量，-1 表示无限弹药。
SWEP.Secondary.Automatic = false -- 副攻击是否为自动模式，此处为非自动。
SWEP.Secondary.Ammo = "none" -- 副攻击消耗的弹药类型，"none" 表示不消耗弹药。

-- 这是一个用于存储允许放置 sigil 的玩家 SteamID 的表。
-- 只有在 `placers` 表中为 true 的 SteamID 或 SuperAdmin 才能使用此武器的功能。
local placers = {
	["STEAM_0:0:1111"] = true, -- 示例 SteamID
	["STEAM_0:0:2222"] = true  -- 示例 SteamID
}

-- 辅助函数：检查玩家是否可以放置 sigil
-- pl: 玩家对象
local function CanPlace(pl)
	-- 玩家有效（存在且未被删除）并且是 SuperAdmin 或其 SteamID 在 `placers` 表中。
	return pl:IsValid() and (pl:IsSuperAdmin() or placers[pl:SteamID()])
end

-- 武器初始化函数 (服务器和客户端都会调用，但这里有服务器端检查)
function SWEP:Initialize()
	if SERVER then -- 确保只在服务器端执行
		self:RefreshSigils() -- 刷新并显示已保存的 sigil 点
	end
end

-- 武器部署（切换到此武器）函数
function SWEP:Deploy()
	if SERVER then -- 确保只在服务器端执行
		self:RefreshSigils() -- 刷新并显示已保存的 sigil 点
	end

	return true -- 返回 true 表示部署成功
end

-- 武器收起（切换到其他武器）函数
function SWEP:Holster()
	if SERVER then -- 确保只在服务器端执行
		-- 遍历所有 "point_fakesigil" 类型的实体并将其移除。
		-- 这是为了在武器收起时清理屏幕上的视觉标记。
		for _, ent in pairs(ents.FindByClass("point_fakesigil")) do
			ent:Remove()
		end
	end

	return true -- 返回 true 表示收起成功
end

-- 主要攻击函数（左键点击）
function SWEP:PrimaryAttack()
	local owner = self:GetOwner() -- 获取武器的持有者
	if not CanPlace(owner) then return end -- 如果持有者没有权限，则停止执行

	owner:DoAttackEvent() -- 触发攻击事件（例如播放手臂动画）

	if CLIENT then return end -- 确保只在服务器端执行以下逻辑

	-- 从玩家视角发射一条射线（追踪线），最远距离 10240 单位
	local tr = owner:TraceLine(10240)
	-- 如果射线击中世界（地面、墙壁等），并且击中点的法线 Z 分量大于等于 0.8（表示接近平面，通常是地面或屋顶）
	if tr.HitWorld and tr.HitNormal.z >= 0.8 then
		-- 将击中点的位置添加到游戏模式的 ProfilerNodes 表中。
		-- GAMEMODE.ProfilerNodes 似乎存储了用于某种路径生成或区域分析的点。
		table.insert(GAMEMODE.ProfilerNodes, tr.HitPos)

		self:RefreshSigils() -- 刷新并显示新的 sigil 点
		GAMEMODE.ProfilerIsPreMade = true -- 设置一个标志，表示这些点是预设的（手动放置的）

		GAMEMODE:SaveProfilerPreMade() -- 保存预设的 sigil 点到文件或数据库
	end
end

-- 次要攻击函数（右键点击）
function SWEP:SecondaryAttack()
	local owner = self:GetOwner() -- 获取武器的持有者
	if not CanPlace(owner) then return end -- 如果持有者没有权限，则停止执行

	owner:DoAttackEvent() -- 触发攻击事件

	if CLIENT then return end -- 确保只在服务器端执行以下逻辑

	-- 从玩家视角发射一条射线
	local tr = owner:TraceLine(10240)

	local newpoints = {} -- 创建一个新表来存储过滤后的点
	-- 遍历 GAMEMODE.ProfilerNodes 中的所有现有 sigil 点
	for _, point in pairs(GAMEMODE.ProfilerNodes) do
		-- 如果当前点与射线击中点的距离平方大于 4096 (即距离大于 64 单位，64*64=4096)
		-- 这意味着移除离玩家右键点击位置较远的点。
		if point:DistToSqr(tr.HitPos) > 4096 then
			table.insert(newpoints, point) -- 将该点添加到新表中（保留该点）
		end
	end
	GAMEMODE.ProfilerNodes = newpoints -- 用过滤后的点替换旧的点表

	self:RefreshSigils() -- 刷新并显示更新后的 sigil 点
	GAMEMODE.ProfilerIsPreMade = true -- 再次设置标志，表示点是预设的

	GAMEMODE:SaveProfilerPreMade() -- 保存更新后的预设 sigil 点
end

-- 重新装填函数（R键）
function SWEP:Reload()
	local owner = self:GetOwner() -- 获取武器持有者
	if not CanPlace(owner) then return end -- 如果持有者没有权限，则停止执行

	owner:DoAttackEvent() -- 触发攻击事件

	if CLIENT then return end -- 确保只在服务器端执行以下逻辑

	-- 如果既没有开始第一次重载计时，也没有开始第二次重载计时
	if not self.StartReload and not self.StartReload2 then
		self.StartReload = CurTime() -- 记录第一次重载开始的时间
		owner:ChatPrint("Keep holding reload to clear all pre-made sigil points.") -- 提示玩家持续按住 R 键
	end
end

-- 只有在服务器端才定义的 Think 函数和控制台命令
if SERVER then
-- 武器的 Think 函数，每帧都会被调用 (在服务器端)
function SWEP:Think()
	-- 处理第二次长按重载键（清除所有点，包括生成的点）
	if self.StartReload2 then
		-- 如果玩家松开了重载键，则取消第二次重载操作
		if not self:GetOwner():KeyDown(IN_RELOAD) then
			self.StartReload2 = nil
			return
		end

		-- 如果持续按住重载键超过 3 秒
		if CurTime() >= self.StartReload2 + 3 then
			self.StartReload2 = nil -- 重置计时器

			self:GetOwner():ChatPrint("Deleted everything including generated nodes. Turned off generated mode.") -- 提示玩家所有点已被删除

			GAMEMODE.ProfilerIsPreMade = true -- 设置为预设模式 (虽然清空了，但可以理解为回到手动管理状态)
			GAMEMODE:DeleteProfilerPreMade() -- 删除预设 sigil 点的保存数据
			GAMEMODE.ProfilerNodes = {} -- 清空所有 sigil 点
			GAMEMODE:SaveProfiler() -- 保存当前的 Profiler 状态 (可能重置为默认或空状态)

			self:RefreshSigils() -- 刷新显示 (移除所有假 sigil 实体)
		end
	-- 处理第一次长按重载键（清除预设点，恢复到生成模式）
	elseif self.StartReload then
		-- 如果玩家松开了重载键，则取消第一次重载操作
		if not self:GetOwner():KeyDown(IN_RELOAD) then
			self.StartReload = nil
			return
		end

		-- 如果持续按住重载键超过 3 秒
		if CurTime() >= self.StartReload + 3 then
			self.StartReload = nil -- 重置计时器

			self:GetOwner():ChatPrint("Deleted all pre-made sigil points and reverted to generated mode. Keep holding reload to delete ALL nodes.") -- 提示玩家预设点已删除，并提示可以继续按住 R 键删除所有点

			GAMEMODE.ProfilerIsPreMade = false -- 将模式设置为非预设（可能意味着启用自动生成模式）
			GAMEMODE:DeleteProfilerPreMade() -- 删除预设 sigil 点的保存数据
			GAMEMODE:LoadProfiler() -- 加载自动生成的 sigil 点（或默认点）

			self:RefreshSigils() -- 刷新并显示当前（可能是自动生成的）sigil 点

			self.StartReload2 = CurTime() -- 启动第二次重载计时器，以便进行后续的全部删除操作
		end
	end
end

-- 注册一个控制台命令 "zs_sigilplacer"
concommand.Add("zs_sigilplacer", function(sender)
	-- 如果执行命令的玩家有权限
	if CanPlace(sender) then
		sender:Give("weapon_zs_sigilplacer") -- 给玩家这把武器
	end
end)
end -- if SERVER 结束

-- 刷新并显示 sigil 点的函数
function SWEP:RefreshSigils()
	-- 首先移除所有现有的 "point_fakesigil" 实体，以避免重复
	for _, ent in pairs(ents.FindByClass("point_fakesigil")) do
		ent:Remove()
	end

	-- 遍历 GAMEMODE.ProfilerNodes 中存储的所有点
	for _, point in pairs(GAMEMODE.ProfilerNodes) do
		local ent = ents.Create("point_fakesigil") -- 创建一个 "point_fakesigil" 类型的实体
		if ent:IsValid() then -- 确保实体创建成功且有效
			ent:SetPos(point) -- 设置实体的位置为 sigil 点的位置
			ent:Spawn() -- 刷新实体（使其出现在游戏中）
		end
	end
end

-- 定义一个名为 "point_fakesigil" 的实体
local ENT = {}

ENT.Type = "anim" -- 实体类型为动画实体（用于显示模型）

-- 实体初始化函数 (服务器和客户端都会调用)
function ENT:Initialize()
	self:DrawShadow(false) -- 不绘制实体的阴影
	self:SetModelScale(1.1, 0) -- 设置模型的大小比例 (1.1 倍，第二个参数通常是动画速度或未使用)
	self:SetModel("models/props_wasteland/medbridge_post01.mdl") -- 设置实体使用的模型文件
	self:SetMoveType(MOVETYPE_NONE) -- 设置移动类型为不可移动（固定在世界中）
	self:SetSolid(SOLID_NONE) -- 设置碰撞类型为无碰撞（玩家可以穿过）
end

-- 只有在客户端才执行的渲染逻辑
if CLIENT then
-- 实体渲染组，设置为透明组，以便进行半透明渲染
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-- 绘制半透明实体函数
function ENT:DrawTranslucent()
	-- 检查本地玩家是否有效
	if MySelf:IsValid() then
		local wep = MySelf:GetActiveWeapon() -- 获取本地玩家当前持有的武器
		-- 如果武器有效并且是 "weapon_zs_sigilplacer" 类型
		if wep:IsValid() and wep:GetClass() == "weapon_zs_sigilplacer" then
			cam.IgnoreZ(true) -- 忽略 Z 缓冲（深度测试），使物体始终显示在其他物体之上
			render.SetBlend(0.5) -- 设置渲染混合（透明度）为 0.5（半透明）
			render.SetColorModulation(1, 0, 0) -- 设置模型颜色为红色 (R=1, G=0, B=0)
			render.SuppressEngineLighting(true) -- 禁用引擎光照，使模型不受场景光照影响

			self:DrawModel() -- 绘制实体模型

			render.SuppressEngineLighting(false) -- 重新启用引擎光照
			render.SetColorModulation(1, 1, 1) -- 恢复模型颜色为白色 (正常颜色)
			render.SetBlend(1) -- 恢复混合（透明度）为 1（不透明）
			cam.IgnoreZ(false) -- 重新启用 Z 缓冲

			-- 这段客户端渲染逻辑的目的是：只有当玩家拿着 "sigilplacer" 武器时，
			-- 才会以半透明红色显示这些 "point_fakesigil" 实体，
			-- 这样玩家就能看到他们放置或要移除的 sigil 点。
		end
	end
end
end -- if CLIENT 结束

-- 注册实体，使其可以在游戏中使用
scripted_ents.Register(ENT, "point_fakesigil")