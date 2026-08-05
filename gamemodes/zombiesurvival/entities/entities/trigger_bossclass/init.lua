-- ============================================================================
-- trigger_bossclass - Boss 转换触发实体（刷子实体）
-- 负责：亡灵玩家进入区域时转换为 Boss 僵尸，支持自定义 Boss 职业、静默生成与即时转换配置
-- ============================================================================

-- 实体类型：刷子（触发器）实体
ENT.Type = "brush"

-- ==== Initialize - 设置为触发器并补全各 Hammer 键值默认值 ====
function ENT:Initialize()
	self:SetTrigger(true)

	-- 键值缺省时采用默认值：默认开启、不静默、转换瞬间完成
	if self.On == nil then self.On = true end
	if self.Silent == nil then self.Silent = false end
	if self.InstantChange == nil then self.InstantChange = true end
end

-- ==== Think - 空实现（核心逻辑由触碰事件驱动） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理 on* 输出转发与 spawnboss/seton/enable/disable/键值修改等输入 ====
function ENT:AcceptInput(name, activator, caller, args)
	name = string.lower(name)
	-- 以 on 开头的输入作为触发输出原样转发
	if string.sub(name, 1, 2) == "on" then
		self:FireOutput(name, activator, caller, args)
	elseif name == "spawnboss" then
		-- 立即生成一只 Boss 僵尸（是否静默/指定职业由键值决定）
		GAMEMODE:SpawnBossZombie(false, self.Silent, self.BossIndex, true)
	elseif name == "seton" then
		self.On = tonumber(args) == 1
		return true
	elseif name == "enable" then
		self.On = true
		return true
	elseif name == "disable" then
		self.On = false
		return true
	elseif name == "setsilent" or name == "setinstantchange" or name == "setclass" then
		-- 动态修改对应键值属性（silent/instantchange/class）
		self:KeyValue(string.sub(name, 4), args)
	end
end

-- ==== KeyValue - 解析 Hammer 键值：on* 输出注册与 enabled/silent/instantchange/class ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	if string.sub(key, 1, 2) == "on" then
		self:AddOnOutput(key, value)
	elseif key == "enabled" then
		self.On = tonumber(value) == 1
	elseif key == "silent" then
		self.Silent = tonumber(value) == 1
	elseif key == "instantchange" then
		self.InstantChange = tonumber(value) == 1
	elseif key == "class" then
		-- 按名称在 Boss 职业表中查找对应职业索引，找不到则保持 nil（使用默认 Boss）
		self.BossIndex = nil
		for _, classtable in ipairs(GAMEMODE.ZombieClasses) do
			if classtable.Boss then
				local classname=GAMEMODE.ZombieClasses[classtable.Index].Name
				if string.lower(classname) == string.lower(value or "") then
					self.BossIndex = classtable.Index
					break
				end
			end
		end
	end
end

-- ==== StartTouch - 亡灵玩家进入区域时：Boss 玩家触发输出，普通亡灵转换为 Boss 僵尸 ====
function ENT:StartTouch(ent)
	if self.On and ent:IsPlayer() and ent:Alive() and ent:Team() == TEAM_UNDEAD then
		-- 已是 Boss：触发 onbosstouched 输出并携带其职业名
		if ent:GetZombieClassTable().Boss then
			self:Input("onbosstouched",ent,self,string.lower(ent:GetZombieClassTable().Name))
		else
			-- 记录转换前的位置与视角，供即时转换模式恢复
			local prevpos = ent:GetPos()
			local prevang = ent:EyeAngles()
			GAMEMODE:SpawnBossZombie(ent, self.Silent, self.BossIndex, true)
			-- 即时转换：转换后立即恢复玩家原位置与视角（瞬移感最小化）
			if self.InstantChange then
				ent:SetPos(prevpos)
				ent:SetEyeAngles(prevang)
			end
		end
	end
end
