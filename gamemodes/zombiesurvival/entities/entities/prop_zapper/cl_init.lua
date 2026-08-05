-- ============================================================================
-- prop_zapper/cl_init.lua - 电击陷阱（客户端）
-- 负责：渲染电击器本体（拉长变形 + 装饰模型）与耐久/弹药信息，
--       播放充能环境音；有弹药且冷却中时在电击口发射蓝色充能粒子
-- ============================================================================
INC_CLIENT()

-- 充能时发光脉动（预留给绘制逻辑的标记）
ENT.Pulsed = true

-- ==== Initialize - 客户端初始化：模型变形、环境音与装饰模型 ====
function ENT:Initialize()
	-- 本体模型纵向拉长（渲染变形）
	local matrix = Matrix()
	matrix:Scale(Vector(0.6, 0.6, 1.2))
	self:EnableMatrix( "RenderMultiply", matrix )

	-- 充能环境音
	self.AmbientSound = CreateSound(self, "ambient/machines/combine_shield_touch_loop1.wav")
	self.AmbientSound:SetSoundLevel(55)

	-- 生成底部装饰模型（淡青色），压扁放大并绑定本体
	local cmodel = ClientsideModel("models/props_trainstation/trainstation_ornament002.mdl")
	if cmodel:IsValid() then
		cmodel:SetPos(self:LocalToWorld(Vector(0, 0, -25.6)))
		cmodel:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 0)))
		cmodel:SetSolid(SOLID_NONE)
		cmodel:SetMoveType(MOVETYPE_NONE)
		cmodel:SetColor(Color(190, 255, 255))
		cmodel:SetParent(self)
		cmodel:SetOwner(self)

		matrix = Matrix()
		matrix:Scale(Vector(2, 2, 0.25))
		cmodel:EnableMatrix( "RenderMultiply", matrix )

		cmodel:Spawn()

		self.CModel = cmodel
	end
end

-- 渲染材质缓存（金属光泽）
local material = Material("models/shiny")
-- ==== DrawZapper - 以金属光泽材质绘制本体（半灰染色） ====
function ENT:DrawZapper()
	render.ModelMaterialOverride(material)
	render.SetColorModulation(0.5, 0.5, 0.5)
	self:DrawModel()
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end

-- ==== DrawTranslucent - 绘制本体、耐久血条与弹药信息 ====
function ENT:DrawTranslucent()
	self:DrawZapper()

	local owner = self:GetObjectOwner()
	local ammo = self:GetAmmo()

	-- 仅人类玩家可见信息面板
	if MySelf:IsValid() and MySelf:Team() == TEAM_HUMAN then
		local ang = self:LocalToWorldAngles(Angle(0, 90, 0))
		cam.Start3D2D(self:LocalToWorld(Vector(-10, 0, -19)), ang, 0.05)
			local name = ""
			if owner:IsValid() and owner:IsPlayer() then
				name = owner:ClippedName()
			end
			-- 耐久血条（含放置者名牌）
			self:Draw3DHealthBar(math.Clamp(self:GetObjectHealth() / self:GetMaxObjectHealth(), 0, 1), name, 0, 0.8)

			-- 弹药显示：有余弹显示数量，否则显示"已空"
			if ammo > 0 then
				draw.SimpleTextBlurry("["..ammo.." / "..self.MaxAmmo.."]", "ZS3D2DFont", 0, 450, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleTextBlurry(translate.Get("empty"), "ZS3D2DFont", 0, 450, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		cam.End3D2D()
	end
end

ENT.NextEmit = 0
-- ==== Think - 充能音效与电击口蓝色粒子（充电越高粒子越靠上） ====
function ENT:Think()
	-- 有所有者且弹药充足时播放充能音
	if self:GetObjectOwner():IsValid() and self:GetAmmo() > 1 then
		self.AmbientSound:PlayEx(0.5, 90)

		-- 每 0.2 秒发射一轮粒子
		if CurTime() >= self.NextEmit then
			self.NextEmit = CurTime() + 0.2

			-- 电击口顶部的蓝色火花
			local pos = self:LocalToWorld(Vector(0, 0, 23))
			local emitter = ParticleEmitter(pos)
			emitter:SetNearClip(24, 32)

			for i=1, 2 do
				local particle = emitter:Add("effects/blueflare1", pos)
				particle:SetDieTime(0.3)
				particle:SetColor(190,210,255)
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(0)
				particle:SetStartSize(1)
				particle:SetEndSize(0)
				particle:SetVelocity(VectorRand():GetNormal() * 20)
			end

			-- 充电杆位置：随电击冷却进度上升（即将发射时升到最高）
			local charge = math.Clamp(29 - ((self:GetNextZap() - CurTime())/3)*40, -20, 22)
			local chargepos = self:LocalToWorld(Vector(0, 0, charge))

			for i=1, 6 do
				local particle = emitter:Add("effects/blueflare1", chargepos)
				particle:SetDieTime(0.4)
				particle:SetColor(150,230,215)
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(0)
				particle:SetStartSize(2)
				particle:SetEndSize(0)
				particle:SetVelocity(VectorRand():GetNormal() * 20)
			end

			-- 结束粒子发射并立即触发一次垃圾回收以降低粒子开销
			emitter:Finish() emitter = nil collectgarbage("step", 64)
		end
	else
		-- 无弹药时停止充能音
		self.AmbientSound:Stop()
	end

	self:NextThink(CurTime() + 0.05)
	return true
end

-- ==== OnRemove - 停止音效并移除装饰模型 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()

	if self.CModel and self.CModel:IsValid() then
		self.CModel:Remove()
	end
end
