-- ============================================================================
-- shared.lua - 冻结状态（共享）：持续时长同步与客户端视觉钩子
-- 负责：定义冻结状态的时长网络同步，并在客户端注册模型染色与屏幕特效钩子
-- ============================================================================
-- 客户端与服务端均加载本文件
AddCSLuaFile()

-- 动画实体类型
ENT.Type = "anim"
-- 继承通用状态基类（提供状态叠加/计时框架）
ENT.Base = "status__base"

-- 瞬时状态：死亡/换队等重置时不保留
ENT.Ephemeral = true

-- 冻结持续总时长（秒），经 DT 同步到客户端
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 冻结开始时间（服务器时间戳），用于计算剩余强度
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== Initialize - 初始化：播放冻结音效并注册客户端视觉钩子 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	if SERVER then
		-- 服务端播放玻璃碎裂音效（冻结生效音），音高固定 85
		self:EmitSound("physics/glass/glass_impact_bullet"..math.random(4)..".wav", 70, 85)
	end

	if CLIENT then
		-- 客户端注册模型染色（绘制前/后）与屏幕全屏特效钩子
		hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
		hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)
	end
end

-- ==== PlayerSet - 状态附加到玩家：记录冻结开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
