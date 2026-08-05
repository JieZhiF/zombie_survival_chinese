-- ============================================================================
-- status_fastshoot/shared.lua - 急速射击状态（共享）
-- 负责：声明持续时间/起始时间 DT 访问器，客户端注册粒子标记的全局 Draw 钩子
-- ============================================================================
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status__base"

-- （状态基类与访问器定义）
 
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：调用基类初始化，客户端注册每帧粒子绘制钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 客户端通过全局 Draw 钩子在拥有者头顶绘制状态粒子
	if CLIENT then
		hook.Add("Draw", self, self.Draw)
	end
end

-- ==== PlayerSet - 绑定到玩家时记录状态起始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
