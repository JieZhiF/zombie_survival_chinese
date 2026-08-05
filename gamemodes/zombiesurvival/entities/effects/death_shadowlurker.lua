-- ============================================================================
-- death_shadowlurker.lua - 阴影潜伏者死亡特效（客户端）
-- 负责：在死亡位置复制尸体模型，随剩余时间逐渐放大、压暗并淡出，
--       表现暗影系僵尸消散融化的死亡过程
-- ============================================================================

-- 特效总寿命（秒），决定残影模型从出现到完全消失的时长
EFFECT.LifeTime = 1

-- ==== Init - 特效初始化：复制尸体模型并启动寿命倒计时 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local normal = data:GetNormal()
	local ent = data:GetEntity()

	-- 将特效实体摆放到死亡位置并对齐到表面朝向
	self.Entity:SetPos(pos)
	self.Entity:SetAngles(normal:Angle())

	-- 实体有效时复制其模型作为消散残影并开始寿命倒计时；无效则立即消亡
	if ent:IsValid() then
		self.DieTime = CurTime() + self.LifeTime
		self.Entity:SetModel(ent:GetModel())
	else
		self.DieTime = 0
	end
end

-- ==== Think - 特效思考：在寿命结束前持续返回 true 保持渲染 ====
function EFFECT:Think()
	return CurTime() < self.DieTime
end

-- ==== Render - 特效渲染：残影模型随时间放大、压暗并淡出 ====
function EFFECT:Render()
	-- delta 为剩余寿命占比（1 → 0），统一驱动缩放与透明度变化
	local delta = (self.DieTime - CurTime()) / self.LifeTime

	-- 模型从原始大小逐渐放大到 2 倍，制造消散前的膨胀感
	self.Entity:SetModelScale(2 - delta ^ 2, 0)

	-- 透明度随剩余寿命线性淡出，同时整体压暗为暗影色调
	render.SetBlend(delta)
	render.SetColorModulation(0.05, 0.05, 0.05)
	self.Entity:DrawModel()
	-- 恢复默认色调与混合，避免污染后续其他渲染
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
end
