-- ============================================================================
-- prop_ffemitterfield - 力场区域实体（客户端）
-- 负责：渲染半透明折射力场（含受损红色脉冲与低弹药告警），并播放持续的环境音效
-- ============================================================================
INC_CLIENT()

-- 渲染组：透明实体
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== Initialize - 生成随机种子、关闭阴影并创建力场循环音效 ====
function ENT:Initialize()
	self.Seed = math.Rand(0, 10)

	self:DrawShadow(false)

	self.AmbientSound = CreateSound(self, "ambient/machines/combine_shield_loop3.wav")
	self.AmbientSound:PlayEx(0.3, 150)
end

-- ==== Think - 发射器弹药充足时以起伏音调持续播放力场音效，弹药不足或耗尽时静音 ====
function ENT:Think()
	local emitter = self:GetEmitter()
	if emitter:IsValid() and emitter.GetAmmo and emitter:GetAmmo() > 1 then
		self.AmbientSound:PlayEx(0.3, 150 + RealTime() % 1)
	else
		self.AmbientSound:Stop()
	end
end

-- ==== OnRemove - 停止力场音效 ====
function ENT:OnRemove()
	self.AmbientSound:Stop()
end
 
-- 折射材质参数：折射量/颜色色调/轮廓色/模糊/轮廓厚度/法线贴图
local materialp = {}
materialp["$refractamount"] = 0.01
materialp["$colortint"] = "[1.0 1.3 1.9]"
materialp["$SilhouetteColor"] = "[2.1 3.5 5.0]"
materialp["$BlurAmount"] = 0.001
materialp["$SilhouetteThickness"] = 0.5
materialp["$normalmap"] = "effects/combineshield/comshieldwall"
-- 创建折射力场材质（Aftershock_dx9 着色器，运行时动态调整折射量）
local matRefract = CreateMaterial("forcefieldxd","Aftershock_dx9", materialp)
-- 高光材质：用于第一层模型的着色调制绘制
local matGlow = Material("models/shiny")
-- ==== DrawTranslucent - 双层绘制力场：先以受损/低弹药调制的半透明色绘制模型，再叠加折射材质层 ====
function ENT:DrawTranslucent()
	local emitter = self:GetEmitter()
	if not (emitter and emitter:IsValid() and emitter.GetAmmo) then return end
	-- 发射器弹药耗尽时力场不可见
	if emitter:GetAmmo() < 1 then return end

	-- 低弹药告警：弹药低于 30 发时力场持续泛红
	local lowammo = emitter:GetAmmo() < 30

	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(matGlow)

	-- 受损红调：受击后 1/3 秒内红色脉冲逐渐消退，低弹药时维持红色
	local red = 1 - math.Clamp((CurTime() - self:GetLastDamaged()) * 3, 0, 1)
	local redadj = math.min(1, red + (lowammo and 1 or 0))

	-- 调制颜色（红调越高整体越红）与闪烁透明度，绘制第一层
	render.SetColorModulation(redadj, 0.6 - redadj, 1 - redadj)
	render.SetBlend(0.007 + redadj * 0.05 + math.max(0, math.cos(CurTime())) ^ 4 * 0.007)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)

	-- 第二层：支持像素着色器 2.0 时更新折射纹理并以折射材质叠加绘制
	if render.SupportsPixelShaders_2_0() then
		render.UpdateRefractTexture()

		matRefract:SetFloat("$refractamount", 0.005 + (0.01 * red))

		render.SetBlend(1)

		render.ModelMaterialOverride(matRefract)
		self:DrawModel()
	else
		render.SetBlend(1)
	end

	render.SetColorModulation(1, 1, 1)

	render.ModelMaterialOverride(0)
	render.SuppressEngineLighting(false)
end
