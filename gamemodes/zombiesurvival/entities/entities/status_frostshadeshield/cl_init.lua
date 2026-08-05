-- ============================================================================
-- status_frostshadeshield/cl_init.lua - 冰霜护盾状态渲染（客户端）
-- 负责：冰盾的视觉表现：动态折射冰材质、展开时从手部发射冰晶粒子流、
--       按状态/剩余时间/血量着色的半透明绘制
-- ============================================================================
INC_CLIENT()

-- 粒子流发射节流时间戳（限频控制）
ENT.NextEmit = 0

-- 冰盾动态折射材质的参数（折射量、冷色调、剪影色、模糊与法线贴图）
local materialp = {}
materialp["$refractamount"] = 0.02
materialp["$colortint"] = "[1.0 1.3 1.6]"
materialp["$SilhouetteColor"] = "[2.1 3.5 5.0]"
materialp["$BlurAmount"] = 0.04
materialp["$SilhouetteThickness"] = 0.05
materialp["$normalmap"] = "effects/combineshield/comshieldwall"
-- ==== OnInitialize - 初始化：注册钩子、创建环境音效与冰盾材质 ====
function ENT:OnInitialize()
	-- 注册移动/本地玩家渲染钩子（以自身为标识，OnRemove 自动清理）
	hook.Add("Move", self, self.Move)
	hook.Add("CreateMove", self, self.CreateMove)
	hook.Add("ShouldDrawLocalPlayer", self, self.ShouldDrawLocalPlayer)

	-- 扩大渲染边界，覆盖冰盾的高度范围
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))

	-- 在拥有者身上记录护盾引用，供其他代码查询
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.ShadeShield = self
	end

	-- 展开开始时的冰晶凝结音效
	self:EmitSound("physics/glass/glass_impact_bullet4.wav", 70, 75)

	-- 创建循环环境音与动态冰材质（按实体索引命名避免冲突）
	self.AmbientSound = CreateSound(self, "vehicles/fast_windloop1.wav")
	self.ShieldMaterial = CreateMaterial("shadeshield" .. self:EntIndex(), "Aftershock_dx9", materialp)
end

-- ==== Think - 展开阶段播放环境音与冰晶粒子流，结束时停止音效 ====
function ENT:Think()
	local curtime = CurTime()

	-- 展开阶段（状态 0）：播放环境音并生成从手部飞向护盾的冰晶粒子流
	if self:GetStateEndTime() <= curtime and self:GetState() == 0 then
		self.AmbientSound:PlayEx(0.8, 100)

		-- 按 0.05 秒间隔限频生成粒子，避免每帧都发射
		if curtime >= self.NextEmit then
			self.NextEmit = curtime + 0.05

			local pos = self:WorldSpaceCenter()
			pos.z = pos.z + 8
			local owner = self:GetOwner()
			local emitter = ParticleEmitter(pos)
			local handpos = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH")).Pos
			emitter:SetNearClip(16, 24)

			-- 冰晶粒子：从右手位置飞向护盾中心（带随机扰动），渐大渐透明
			local particle = emitter:Add("sprites/glow04_noz", handpos)
			local dir = (pos - handpos + (VectorRand() * 2)):GetNormalized()
			particle:SetVelocity(dir * math.Rand(120, 125))
			particle:SetDieTime(math.Rand(0.25, 0.27))
			particle:SetStartAlpha(math.Rand(230, 250))
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(math.Rand(12, 14))
			particle:SetColor(0, 140, 255)

			-- 结束发射器并主动触发一次 GC，避免粒子对象堆积
			emitter:Finish() emitter = nil collectgarbage("step", 64)
		end
	elseif self:GetState() == 1 then
		-- 完全展开/结束阶段停止环境音
		self.AmbientSound:Stop()
	end
end

local matWhite = Material("models/debug/debugwhite")
-- ==== DrawTranslucent - 半透明绘制冰盾：按阶段缩放、按血量着色并叠加折射 ====
function ENT:DrawTranslucent()
	local curtime = CurTime()
	local diff = self:GetStateEndTime() - curtime
	-- 展开阶段（状态 0）随剩余时间淡入，结束阶段（状态 1）随剩余时间淡出
	local scalar = self:GetState() == 1 and diff or 0.5 - diff
	local scale = math.Clamp((scalar ^ 2)/0.25, 0, 1)

	-- 颜色随护盾血量从蓝（满血）渐变为红（残血）
	local red = 1 - self:GetObjectHealth()/self:GetMaxObjectHealth()
	render.SetColorModulation(red, 0.7 * (1 - red), 1 - red)
	-- 基础透明度叠加周期性闪烁效果，并乘以上述阶段缩放
	local blend = 0.3 + math.abs(math.cos(CurTime())) ^ 2 * 0.1
	render.SetBlend(blend * scale)
	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(matWhite)

	-- 第一遍：纯白模型绘制（作为折射渲染的底色）
	self:DrawModel()

	-- 还原渲染状态
	render.SetColorModulation(1, 1, 1)
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride()
	render.SetBlend(1)

	-- 第二遍：支持像素着色器时以动态冰材质重新绘制（折射扭曲效果）
	if render.SupportsPixelShaders_2_0() then
		self.ShieldMaterial:SetFloat("$refractamount", 0.01 * scale)
		self.ShieldMaterial:SetFloat("$BlurAmount", 0.01 * scale)
		render.UpdateRefractTexture()

		-- 借助全局 nodraw 标记只更新折射纹理而不实际画入场景
		render.ModelMaterialOverride(self.ShieldMaterial)
		nodraw = true
		self:DrawModel()
		nodraw = false
		render.ModelMaterialOverride(0)
	end
end
