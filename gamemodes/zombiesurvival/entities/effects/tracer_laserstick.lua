EFFECT.Size = 2
function EFFECT:Init(data)
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	-- 增加有效性检查
	if not IsValid(self.WeaponEnt) then return end

	-- 防止获取无效坐标
	self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment) or Vector(0,0,0)
	self.EndPos = data:GetOrigin() or Vector(0,0,0)

	self.Life = 0

	-- 防止设置无效渲染边界
	if self.StartPos and self.EndPos then
		self:SetRenderBoundsWS(self.StartPos, self.EndPos)
	end
end

function EFFECT:Think()
	-- 关键修复：实体失效时立即停止效果
	if not IsValid(self.WeaponEnt) then
		return false
	end

	self.Life = self.Life + FrameTime() * 6
	
	-- 安全更新坐标
	self.StartPos = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment) or Vector(0,0,0)
	
	return self.Life < 1
end

local beammat = Material("trails/laser")
function EFFECT:Render()
	-- 增加渲染前有效性检查
	if not self.StartPos or not self.EndPos then return end
	
	local texcoord = math.Rand(0, 1)

	-- 安全计算向量长度
	local direction = self.EndPos - self.StartPos
	local nlen = direction:Length()
	
	-- 防止除以零错误
	if nlen <= 0 then return end

	local alpha = math.Clamp(1 - self.Life, 0, 1)  -- 确保透明度在0-1之间

	render.SetMaterial(beammat)

	-- 优化绘制逻辑
	local uvEnd = texcoord + nlen / 128
	local beamColor = Color(0, 255, 255, 255 * alpha)
	
	for i = 1, 2 do
		render.DrawBeam(self.StartPos, self.EndPos, 4, texcoord, uvEnd, beamColor)
	end
	render.DrawBeam(self.StartPos, self.EndPos, 14, texcoord, uvEnd, beamColor)
end