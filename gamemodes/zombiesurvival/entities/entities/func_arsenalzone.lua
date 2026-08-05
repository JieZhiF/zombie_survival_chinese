-- ============================================================================
-- func_arsenalzone - 补给区触发实体（brush 触发器）
-- 负责：标记人类玩家进入/离开补给区，供商店系统判断玩家是否处于
--       可购买武器的区域；支持 Hammer 输入（Enable/Disable/SetOn）
--       和 KeyValue（Enabled）控制开关
-- ============================================================================

-- 实体类型：触发器 brush（与 Hammer 中 func_brush 触发器配合）
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
	-- Enable：开启补给区
	elseif name == "enable" then
		self.On = true
		return true
	-- Disable：关闭补给区
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

-- ==== Enter - 玩家进入补给区 ====
-- 将补给区实体记录到玩家身上，供商店购买逻辑查询
function ENT:Enter(ent)
	ent.ArsenalZone = self
end

-- ==== Leave - 玩家离开补给区 ====
function ENT:Leave(ent)
	ent.ArsenalZone = nil
end

-- ==== Touch - 持续接触检测 ====
-- 区域被关闭时，若玩家仍站在区内且记录的是本区域，则立刻将其移出
function ENT:Touch(ent)
	if not self.On and ent:IsPlayer() and ent.ArsenalZone == self then
		self:Leave(ent)
	end
end

-- ==== StartTouch - 开始接触检测 ====
-- 仅当区域开启、玩家存活且是人类阵营、且尚未处于任何补给区时才标记进入
function ENT:StartTouch(ent)
	if self.On and ent:IsPlayer() and ent:Alive() and ent:Team() == TEAM_HUMAN and not ent.ArsenalZone then
		self:Enter(ent)
	end
end

-- ==== EndTouch - 结束接触检测 ====
-- 玩家离开区域时清除记录
function ENT:EndTouch(ent)
	if ent:IsPlayer() and ent.ArsenalZone == self then
		self:Leave(ent)
	end
end
