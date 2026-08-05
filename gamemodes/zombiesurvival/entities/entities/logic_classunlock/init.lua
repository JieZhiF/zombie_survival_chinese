-- ============================================================================
-- logic_classunlock/init.lua - 僵尸职业解锁逻辑实体（服务器）
-- 负责：Hammer 地图逻辑实体：通过输入锁定/解锁指定僵尸职业（或全部）、
--       设置默认职业与开关 Boss 职业，并广播解锁状态给客户端
-- ============================================================================
ENT.Type = "point"

-- ==== Initialize - 初始化：默认职业编号与 Boss 开关 ====
function ENT:Initialize()
	self.Class = self.Class or 1
	self.BossesEnabled = GAMEMODE.BossZombies
end

-- ==== Think - 空实现（point 实体无需逐帧逻辑）====
function ENT:Think()
end

-- ==== AcceptInput - 处理输入：锁/解锁职业、设默认职业、开关 Boss ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- On 开头的输出直接透传
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	elseif name == "lockclass" then
		-- 锁定指定职业（或全部）
		local classname = string.lower(args)
		for k, v in ipairs(GAMEMODE.ZombieClasses) do
			if classname == "all" or string.lower(v.Name) == classname then
				v.Locked = true
				v.Unlocked = false

				-- 广播该职业的锁定状态
				net.Start(NET_MSG.CLASSUNLOCKSTATE)
					net.WriteInt(k, 8)
					net.WriteBool(v.Unlocked)
				net.Broadcast()

				-- 锁定单个职业时：把正在使用该职业的玩家死亡职业换到下一个可用职业
				if classname ~= "all" then
					for _, pl in pairs(player.GetAll()) do
						if pl:GetZombieClass() == k then
							for classid, classtab in ipairs(GAMEMODE.ZombieClasses) do
								if GAMEMODE:IsClassUnlocked(k) and not classtab.Hidden then
									pl.DeathClass = classid
									break
								end
							end
						end
					end
				end
			end
		end
	elseif name == "unlockclass" then
		-- 解锁指定职业（或全部）
		local classname = string.lower(args)
		for k, v in ipairs(GAMEMODE.ZombieClasses) do
			if classname == "all" or string.lower(v.Name) == classname then
				v.Unlocked = true
				v.Locked = false

				-- 广播该职业的解锁状态
				net.Start(NET_MSG.CLASSUNLOCKSTATE)
					net.WriteInt(k, 8)
					net.WriteBool(v.Unlocked)
				net.Broadcast()
			end
		end
	elseif name == "defaultclass" then
		-- 设置默认僵尸职业
		local classname = string.lower(args)
		for k, v in ipairs(GAMEMODE.ZombieClasses) do
			if string.lower(v.Name) == classname then
				v.IsDefault = true
				GAMEMODE.DefaultZombieClass = k
			else
				v.IsDefault = nil
			end
		end
	elseif name == "setbossesenabled" then
		-- 开关 Boss 职业
		self:KeyValue("BossesEnabled",args)
	end
end

-- ==== KeyValue - 读取 Hammer 键值：职业编号、Boss 开关与输出绑定 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "class" then
		self.Class = value or self.Class
	elseif key == "bossesenabled" then
		-- 开关状态同时同步到全局 Boss 配置
		local enabled = tonumber(value) == 1
		self.BossesEnabled = enabled
		GAMEMODE.BossZombies = enabled
	elseif string.sub(key, 1, 2) == "on" then
		-- 注册 On 开头的输出
		self:AddOnOutput(key, value)
	end
end
