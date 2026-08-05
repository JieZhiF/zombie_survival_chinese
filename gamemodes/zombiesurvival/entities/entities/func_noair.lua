-- ============================================================================
-- func_noair - 无空气区域触发实体（brush 触发器）
-- 负责：人类玩家进入该区域后被施加"溺水"状态（drown）持续掉血，
--       用于模拟真空/毒气区域；支持 Hammer 输入控制开关
-- ============================================================================

-- 实体类型：触发器 brush
ENT.Type = "brush"

-- ==== Initialize - 初始化触发器 ====
function ENT:Initialize()
	-- 开启触发器碰撞检测
	self:SetTrigger(true)

	-- 默认开启（Hammer 未指定 enabled 时）
	if self.On == nil then self.On = true end
end

-- ==== Think - 每帧逻辑（无内容，保留空实现占位） ====
function ENT:Think()
end

-- ==== AcceptInput - 处理 Hammer 输入 ====
function ENT:AcceptInput(name, caller, activator, arg)
	name = string.lower(name)
	-- SetOn：按传入数值（1/0）设置开关状态
	if name == "seton" then
		self.On = tonumber(arg) == 1
		return true
	-- Enable：开启无空气区域
	elseif name == "enable" then
		self.On = true
		return true
	-- Disable：关闭无空气区域
	elseif name == "disable" then
		self.On = false
		return true
	end
end

-- ==== KeyValue - 读取 Hammer 实体属性 ====
function ENT:KeyValue(key, value)
	key = string.lower(key)
	-- enabled：按数值（1/0）初始化开关状态
	if key == "enabled" then
		self.On = tonumber(value) == 1
	end
end

-- ==== Enter - 玩家进入无空气区域 ====
-- 记录区域到玩家身上，若玩家尚未拥有溺水状态则立即施加
function ENT:Enter(ent)
	ent.NoAirBrush = self
	if not IsValid(ent.status_drown) then
		ent:GiveStatus("drown")
	end
end

-- ==== Leave - 玩家离开无空气区域 ====
function ENT:Leave(ent)
	ent.NoAirBrush = nil
end

-- ==== Touch - 持续接触检测 ====
-- 区域被关闭时，若玩家仍站在区内且记录的是本区域，则立刻将其移出
function ENT:Touch(ent)
	if not self.On and ent:IsPlayer() and ent.NoAirBrush == self then
		self:Leave(ent)
	end
end

-- ==== StartTouch - 开始接触检测 ====
-- 仅当区域开启、玩家存活且是人类阵营、且尚未处于任何无空气区域时才标记进入
function ENT:StartTouch(ent)
	if self.On and ent:IsPlayer() and ent:Alive() and ent:Team() == TEAM_HUMAN and not ent.NoAirBrush then
		self:Enter(ent)
	end
end

-- ==== EndTouch - 结束接触检测 ====
-- 玩家离开区域时清除记录（溺水状态由状态系统自行移除）
function ENT:EndTouch(ent)
	if ent:IsPlayer() and ent.NoAirBrush == self then
		self:Leave(ent)
	end
end
