-- ============================================================================
-- status_disorientation.lua - 迷失方向状态（共享）
-- 负责：3 秒内使携带者视角正弦摆动、画面动态模糊并叠加迷失音效
--       （DSP 35），效果强度随剩余时间衰减
-- ============================================================================
AddCSLuaFile()

-- 实体类型：动画实体，基于状态基类 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- 状态持续时间（秒）
ENT.LifeTime = 3

-- 短暂状态标记（Ephemeral：死亡/重生即清除，不做持久化）
ENT.Ephemeral = true

-- ==== Initialize - 初始化：注册客户端视角/滤镜 hook 并叠加迷失音效 ====
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	-- 客户端：注册视角摆动与屏幕滤镜 hook，并生成随机种子（错开摆动相位）
	if CLIENT then
		hook.Add("CreateMove", self, self.CreateMove)
		hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects)

		self.Seed = math.Rand(0, 10)
	end

	-- 为父实体（携带者）叠加 DSP 35 迷失音效（本地玩家可见时播放）
	local parent = self:GetParent()
	if parent:IsValid() and (SERVER or CLIENT and MySelf == parent) then
		parent:SetDSP(35)
	end

	-- 记录状态结束时间
	self.DieTime = CurTime() + self.LifeTime
end

-- 服务器端逻辑至此结束（本状态仅影响客户端视角表现）
if SERVER then return end

-- ==== GetPower - 计算剩余效果强度：随剩余时间从 1 线性衰减到 0 ====
function ENT:GetPower()
	return math.Clamp(self.DieTime - CurTime(), 0, 1)
end

-- ==== CreateMove - 视角修正：让携带者视角正弦摆动（越临近结束越弱） ====
function ENT:CreateMove(cmd)
	-- 只处理本状态携带者的输入
	if MySelf ~= self:GetOwner() then return end

	local curtime = CurTime()
	local frametime = FrameTime()
	local power = self:GetPower()

	-- 俯仰角正弦摆动 40°/秒，偏航角余弦摆动 50°/秒（相位由种子错开）
	local ang = cmd:GetViewAngles()
	ang.pitch = math.Clamp(ang.pitch + math.sin(curtime) * 40 * frametime * power, -89, 89)
	ang.yaw = math.NormalizeAngle(ang.yaw + math.cos(curtime + self.Seed) * 50 * frametime * power)

	cmd:SetViewAngles(ang)
end

-- ==== RenderScreenspaceEffects - 屏幕滤镜：按剩余强度叠加动态模糊 ====
function ENT:RenderScreenspaceEffects()
	-- 只对携带者生效
	if MySelf ~= self:GetOwner() then return end

	local power = self:GetPower()

	-- 动态模糊强度随剩余时间衰减（模糊量、强度、偏移）
	DrawMotionBlur(0.1, power, 0.05)
end
