-- ============================================================================
-- cl_init.lua - 投掷物武器基类客户端脚本
-- 负责：设置镜头与武器栏位；播放投掷动画；绘制右下角弹药计数框；
--       在手部绘制 3D2D 浮动剩余弹药标签（视图模型绘制后）
-- ============================================================================
INC_CLIENT()

-- 第一人称镜头视野与模型方向
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

-- 武器栏位（4 号槽）与槽内位置
SWEP.Slot = 4
SWEP.SlotPos = 0

-- ==== ShootBullets - 客户端投掷表现 ====
-- 播放投掷动画与攻击事件（与服务器同步的视觉效果）
function SWEP:ShootBullets()
	local owner = self:GetOwner()
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()
end

-- ==== DrawWeaponSelection - 绘制武器选择界面 ====
-- 复用父类的基础绘制逻辑
function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
	self:BaseDrawWeaponSelection(x, y, w, h, alpha)
end

-- HUD 圆角框背景与文字颜色
local colBG = Color(16, 16, 16, 90)
local colWhite = Color(220, 220, 220, 230)

-- ==== DrawHUD - 绘制屏幕右下角弹药计数 ====
-- 绘制准星；2D 武器 HUD 模式下显示剩余弹药数量的圆角框
function SWEP:DrawHUD()
	self:DrawWeaponCrosshair()

	if not GAMEMODE:ShouldDraw2DWeaponHUD() then return end

	local screenscale = BetterScreenScale()

	-- 计算 HUD 框位置（右下角，随屏幕缩放）
	local wid, hei = 180 * screenscale, 64 * screenscale
	local x, y = ScrW() - wid - screenscale * 128, ScrH() - hei - screenscale * 72
	local clip = self:GetPrimaryAmmoCount()

	-- 绘制半透明圆角背景与居中弹药数字（数字大时用小字体）
	draw.RoundedBox(16, x, y, wid, hei, colBG)
	draw.SimpleTextBlurry(clip, clip >= 100 and "ZSHUDFont" or "ZSHUDFontBig", x + wid * 0.5, y + hei * 0.5, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- ==== PostDrawViewModel - 视图模型绘制后在手部叠加 3D2D 弹药标签 ====
-- 在右手位置绘制旋转摆动的剩余弹药数字，模拟"投掷物上的计数器"
function SWEP:PostDrawViewModel(vm)
	-- 特定 HUD 模式下不绘制
	if GAMEMODE.WeaponHUDMode == 1 then return end

	-- 获取右手骨骼矩阵作为锚点
	local bone = vm:LookupBone("ValveBiped.Bip01_R_Hand")
	if not bone then return end

	local m = vm:GetBoneMatrix(bone)
	if not m then return end

	local pos, ang = m:GetTranslation(), m:GetAngles()

	-- 沿骨骼上方向微调位置
	pos = pos + ang:Up() * -3

	-- 摆动与旋转动画（随时间正弦摆动 + 持续旋转）
	local time = CurTime()
	ang:RotateAroundAxis(ang:Right(), math.sin(time * math.pi) * 20)
	ang:RotateAroundAxis(ang:Up(), time * 180)

	pos = pos + ang:Forward() * 5

	ang:RotateAroundAxis(ang:Right(), 270)
	ang:RotateAroundAxis(ang:Up(), 270)

	-- 在标签位置绘制圆角背景与剩余弹药数字
	local wid, hei = 144, 144
	local x, y = wid * -0.5, hei * -0.5
	local clip = self:GetPrimaryAmmoCount()

	cam.Start3D2D(pos, ang, 0.01)
		draw.RoundedBox(16, x, y, wid, hei, colBG)
		draw.SimpleText(clip, "ZS3D2DFontBig", x + wid * 0.5, y + hei * 0.5, colWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
