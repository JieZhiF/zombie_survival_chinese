-- ============================================================================
-- projectile_bomb_sticky/cl_init.lua - 粘性炸弹投射物（客户端）
-- 负责：绘制蓄力状态：颜色随蓄力进度由绿转红（或常亮青色模式），
--       满蓄力时叠加脉动光晕提示即将爆炸
-- ============================================================================
INC_CLIENT()

-- 预留的粒子发射节流字段（当前未使用）
ENT.NextEmit = 0

-- ==== Initialize - 初始化：缩小模型、应用材质并关闭阴影 ====
function ENT:Initialize()
	self:SetModelScale(0.2, 0)
	self:SetMaterial("models/props_combine/masterinterface01c")
	self:DrawShadow(false)
end

local matGlow = Material("sprites/glow04_noz")
-- ==== Draw - 绘制本体：颜色反映蓄力/模式，满蓄力时显示脉动光晕 ====
function ENT:Draw()
	local alt = self:GetDTBool(0)
	local charge = self:GetCharge()
	-- 普通模式：颜色由绿（低蓄力）渐变为红（满蓄力）；替代模式：恒定青色
	local c = Color(alt and 100 or 255 * charge, alt and 205 or 0 * charge, alt and 205 or 0 * charge)
	self:SetColor(c)
	self:DrawModel()

	local pos = self:GetPos()
	-- 满蓄力时以 12Hz 正弦脉冲绘制光晕（尺寸随脉冲缩放）
	local size = math.abs((self:GetCharge() == 1 and 1 or 0) * 34 * math.sin(CurTime() * 12))

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size, size, c)
end
