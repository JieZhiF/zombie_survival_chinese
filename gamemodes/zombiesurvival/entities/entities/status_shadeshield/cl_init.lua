-- ============================================================================
-- status_shadeshield/cl_init.lua - 阴影护盾状态（客户端）
-- 负责：护盾的视觉表现——折射扭曲材质、手部粒子流、半透明着色渲染；
--       拦截拥有者的跳跃输入、本地视角下也渲染拥有者自身
-- ============================================================================
INC_CLIENT()

-- 粒子流发射节流时间戳（限频控制）
ENT.NextEmit = 0

-- 护盾动态折射材质的参数（扭曲量、色调、描边色、模糊与法线贴图）
local materialp = {}
materialp["$refractamount"] = 0.02
materialp["$colortint"] = "[1.0 1.3 1.6]"
materialp["$SilhouetteColor"] = "[2.1 3.5 5.0]"
materialp["$BlurAmount"] = 0.04
materialp["$SilhouetteThickness"] = 0.05
materialp["$normalmap"] = "effects/combineshield/comshieldwall"

-- ==== OnInitialize - 初始化：注册钩子、绑定拥有者引用并创建材质/音效 ====
function ENT:OnInitialize()
	-- 注册移动/跳跃/本地玩家渲染钩子（以自身为标识，OnRemove 自动清理）
	hook.Add("Move", self, self.Move)
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)

	-- 扩大渲染边界，覆盖护盾的高度范围
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	-- 在拥有者身上记录护盾引用，供其他代码查询
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.ShadeShield = self
	end

	-- 展开阶段的高频充能音效
	self:EmitSound("weapons/physcannon/physcannon_charge.wav", 70, 250)

	-- 创建循环环境音与动态折射材质（按实体索引命名避免冲突）
	self.AmbientSound = CreateSound(self, "weapons/physcannon/superphys_hold_loop.wav")
	self.ShieldMaterial = CreateMaterial("shadeshield" .. self:EntIndex(), "Aftershock_dx9", materialp)
end

-- ==== CreateMove - 拦截拥有者的跳跃输入 ====
function ENT:CreateMove(cmd)
	if MySelf ~= self:GetOwner() then return end

	-- 按住跳跃时移除跳跃输入，护盾展开期间禁止跳跃
	if bit.band(cmd:GetButtons(), IN_JUMP) ~= 0 then
		cmd:SetButtons(cmd:GetButtons() - IN_JUMP)
	end
end

-- ==== ShouldDrawLocalPlayer - 本地视角下也渲染拥有者自身 ====
function ENT:ShouldDrawLocalPlayer(pl)
	if pl ~= self:GetOwner() then return end

	return true
end

-- ==== OnRemove - 清理拥有者引用并停止循环音效 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.ShadeShield = nil
	end

	self.AmbientSound:Stop()
end

-- ==== Think - 状态演出：展开阶段播放粒子流，收起阶段停止环境音 ====
function ENT:Think()
	local curtime = CurTime()

	-- 展开阶段（状态 0）：播放环境音并生成从手部飞向护盾的粒子流
	if self:GetStateEndTime() <= curtime and self:GetState() == 0 then
		self.AmbientSound:PlayEx(0.77, 53)

		-- 按 0.05 秒间隔限频生成粒子，避免每帧都发射
		if curtime >= self.NextEmit then
			self.NextEmit = curtime + 0.05

			local pos = self:WorldSpaceCenter()
			pos.z = pos.z + 8
			local owner = self:GetOwner()
			local emitter = ParticleEmitter(pos)
			-- 粒子从拥有者右手附着点飞向护盾中心位置
			local handpos = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH")).Pos
			emitter:SetNearClip(16, 24)

			local particle = emitter:Add("sprites/glow04_noz", handpos)
			local dir = (pos - handpos + (VectorRand() * 2)):GetNormalized()
			particle:SetVelocity(dir * math.Rand(120, 125))
			particle:SetDieTime(math.Rand(0.25, 0.27))
			particle:SetStartAlpha(math.Rand(230, 250))
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(math.Rand(12, 14))
			particle:SetColor(49, 110, 255)

			emitter:Finish() emitter = nil collectgarbage("step", 64)
		end
	elseif self:GetState() == 1 then
		-- 完全展开阶段（状态 1）：停止环境音
		self.AmbientSound:Stop()
	end
end

local matWhite = Material("models/debug/debugwhite")

-- ==== DrawTranslucent - 半透明渲染：随状态缩放淡入淡出并按血量着色 ====
function ENT:DrawTranslucent()
	local curtime = CurTime()
	-- 根据状态与剩余时间计算缩放系数：完全展开后保持全尺寸，收起时缩小消失
	local diff = self:GetStateEndTime() - curtime
	local scalar = self:GetState() == 1 and diff or 0.5 - diff
	local scale = math.Clamp((scalar ^ 2)/0.25, 0, 1)

	-- 血量越低颜色越偏红，作为护盾受击反馈
	local red = 1 - self:GetObjectHealth()/self:GetMaxObjectHealth()
	render.SetColorModulation(red, 0.1, 1 - red)
	-- 呼吸式闪烁的透明度
	local blend = 0.3 + math.abs(math.cos(CurTime())) ^ 2 * 0.1
	render.SetBlend(blend * scale)
	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(matWhite)

	self:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride()
	render.SetBlend(1)

	-- 支持像素着色器 2.0 时再叠加一层折射扭曲材质，形成能量护盾质感
	if render.SupportsPixelShaders_2_0() then
		self.ShieldMaterial:SetFloat("$refractamount", 0.01 * scale)
		self.ShieldMaterial:SetFloat("$BlurAmount", 0.01 * scale)
		render.UpdateRefractTexture()

		-- 覆盖为折射材质二次绘制（nodraw 标记避免折射贴图自采样的循环）
		render.ModelMaterialOverride(self.ShieldMaterial)
		nodraw = true
		self:DrawModel()
		nodraw = false
		render.ModelMaterialOverride(0)
	end
end
