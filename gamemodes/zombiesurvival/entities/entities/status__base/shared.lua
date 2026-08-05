-- ============================================================================
-- status__base/shared.lua - 状态实体通用基类（共享）
-- 负责：所有 status_* 状态实体的父类：声明状态标记与可覆盖的空白回调钩子，
--       提供 GetPlayer 访问器别名
-- ============================================================================
-- 动画实体类型（状态实体通常无物理模型，随拥有者移动）
ENT.Type = "anim"

-- 标记：本实体属于状态实体（供状态系统通用逻辑识别）
ENT.IsStatus = true

-- ==== OnInitialize - 派生类初始化钩子（空实现，由子类覆盖） ====
function ENT:OnInitialize()
end

-- ==== PhysicsCollide - 物理碰撞回调（空实现，由子类覆盖） ====
function ENT:PhysicsCollide(data, physobj)
end

-- ==== StartTouch - 接触开始回调（空实现，由子类覆盖） ====
function ENT:StartTouch(ent)
end

-- ==== Touch - 持续接触回调（空实现，由子类覆盖） ====
function ENT:Touch(ent)
end

-- ==== EndTouch - 接触结束回调（空实现，由子类覆盖） ====
function ENT:EndTouch(ent)
end

-- ==== AcceptInput - 实体输入接收（空实现，由子类覆盖） ====
function ENT:AcceptInput(name, activator, caller)
end

-- GetPlayer 别名：状态拥有者即其父实体（绑定到玩家身上）
ENT.GetPlayer = ENT.GetParent
