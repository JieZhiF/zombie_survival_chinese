-- ============================================================================
-- weapon_zs_crossbow/cl_init.lua - 十字弓（客户端表现）
-- 负责：HUD3D 挂载信息、武器栏位配置、狙击镜（开镜）HUD 渲染
-- ============================================================================
INC_CLIENT()

-- HUD3D：绑定到十字弓骨骼的显示位置与缩放
SWEP.HUD3DBone = "ValveBiped.Crossbow_base"
SWEP.HUD3DPos = Vector(1.5, 0.5, 11)
SWEP.HUD3DScale = 0.025

-- 第一人称视角视野大小与模型翻转
SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false

-- 武器栏位：归类到螺栓（弹药）选择栏
SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotBolt")
SWEP.SlotGroup = WEPSELECT_BOLT
SWEP.SlotPos = 0

-- 机瞄缩放倍率（配合狙击镜使用）
SWEP.IronsightsMultiplier = 0.25
-- 标记为狙击步枪，启用开镜判定逻辑
SWEP.SniperRifle = true

-- ==== GetViewModelPosition - 开镜时隐藏第一人称模型，避免遮挡瞄准画面 ====
function SWEP:GetViewModelPosition(pos, ang)
	-- 游戏模式禁用了瞄准镜则不处理
	if GAMEMODE.DisableScopes then return end

	-- 已开镜时不返回位置（即隐藏模型）
	if self:IsScoped() then return end

	return self.BaseClass.GetViewModelPosition(self, pos, ang)
end

-- 开镜时的瞄准镜圆形贴图
local texScope = surface.GetTextureID("zombiesurvival/scope")

-- ==== DrawHUDBackground - 绘制狙击镜画面：红色十字刻线 + 圆形镜片遮罩 ====
function SWEP:DrawHUDBackground()
	-- 游戏模式禁用了瞄准镜则不绘制
	if GAMEMODE.DisableScopes then return end
	-- 未开镜时不绘制
	if not self:IsScoped() then return end

	local scrw, scrh = ScrW(), ScrH()
	-- 取屏幕短边作为镜片直径，保证圆形完整
	local size = math.min(scrw, scrh)

	local hw = scrw * 0.5
	local hh = scrh * 0.5

	-- 绘制红色十字准线（横线、竖线及右下刻度线）
	surface.SetDrawColor(255, 0, 0, 180)
	surface.DrawLine(0, hh, scrw, hh)
	surface.DrawLine(hw, 0, hw, scrh)
	for i=1, 10 do
		surface.DrawLine(hw, hh + i * 7, hw + (50 - i * 5), hh + i * 7)
	end

	-- 在屏幕中央绘制圆形瞄准镜贴图
	surface.SetTexture(texScope)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect((scrw - size) * 0.5, (scrh - size) * 0.5, size, size)
	-- 用黑色矩形遮挡屏幕四周，仅保留圆形镜片区域
	surface.SetDrawColor(0, 0, 0, 255)
	if scrw > size then
		local extra = (scrw - size) * 0.5
		surface.DrawRect(0, 0, extra, scrh)
		surface.DrawRect(scrw - extra, 0, extra, scrh)
	end
	if scrh > size then
		local extra = (scrh - size) * 0.5
		surface.DrawRect(0, 0, scrw, extra)
		surface.DrawRect(0, scrh - extra, scrw, extra)
	end
end
