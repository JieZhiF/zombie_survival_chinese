-- ============================================================================
-- weapon_zs_tropyer.lua - 特罗皮尔（加兰德风格）半自动步枪
-- 负责：定义步枪属性、瞄准镜附加模型、开火/换弹音效、近战枪托与右键开镜逻辑
-- ============================================================================
-- 定义基类为 weapon_zs_base，供后续 BaseClass 调用基类方法
DEFINE_BASECLASS("weapon_zs_base")
-- 引用近战武器基类（本武器支持枪托近战）
local BaseClassMelee = baseclass.Get("weapon_zs_basemelee")

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_tropyer")
-- 武器在商店/控制台中的分类
SWEP.Category = "ZS Guns unofficial"

-- 客户端专属配置块
if CLIENT then

	-- 第一人称视野角度
	SWEP.ViewModelFOV = 75
	-- 视图模型不镜像翻转
	SWEP.ViewModelFlip = false

	-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置、角度与缩放
	SWEP.HUD3DBone = "ValveBiped.garand_base"
	SWEP.HUD3DPos = Vector(-2.79, -1.361, 8.834)
	SWEP.HUD3DAng = Angle(180, 90, 0)
	SWEP.HUD3DScale = 0.022

	-- 视图模型握持位置偏移与角度
    SWEP.VMPos = Vector(0, -1, 1)
    SWEP.VMAng = Angle(0, 0, 0)

-- 视图模型骨骼调整：修正右手食指姿态以贴合扳机护圈
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -40.755, 0) }
}

-- 视图模型附加模型（SCK 元素）：在加兰德模型上拼接瞄准镜底座、导轨、前后瞄具与镜片
SWEP.VElements = {
	["base"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope+", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped", rel = "base_scope+", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base_scope"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped", rel = "rail", pos = Vector(-0.015, 1.758, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["base_scope+"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped", rel = "rail", pos = Vector(-0.015, -1.37, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["rail"] = { type = "Model", model = "models/props_phx/gears/rack18.mdl", bone = "ValveBiped.garand_base", rel = "", pos = Vector(-3.409, 0.504, 15.094), angle = Angle(0, -90, 89.767), size = Vector(0.207, 0.079, 0.053), color = Color(161, 161, 161, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_blur"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.garand_base", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = true, nocull = false, material = "pp/dof", skin = 0, bodygroup = {} },
	["scope_back_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, 1.5, 1.3), angle = Angle(-135.69901, 0, 90), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_back_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.garand_base", rel = "scope_back_sight", pos = Vector(0, 0, -4.161), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(182, 182, 182, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/screenspace", skin = 0, bodygroup = {} },
	["scope_back_lens+"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.garand_base", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_lens++"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.garand_base", rel = "scope_front_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, 0.418, 1.3), angle = Angle(0, 0, -90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, -1.7, 1.3), angle = Angle(-135.69901, 0, 87.641), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.garand_base", rel = "scope_front_sight", pos = Vector(0, 0, -4.15), angle = Angle(90, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_front_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, -0.418, 1.3), angle = Angle(0, 0, 90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_middle"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.garand_base", rel = "rail", pos = Vector(0, -1.725, 1.28), angle = Angle(0, 0, 90), size = Vector(0.02, 0.02, 0.078), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} }
}

-- 世界模型附加模型（SCK 元素）：第三人称下同样拼接瞄准镜结构
SWEP.WElements = {
	["base"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope+", pos = Vector(0, 0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base+++"] = { type = "Model", model = "models/hunter/plates/plate1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base_scope+", pos = Vector(0, -0.6, -0.002), angle = Angle(90, 90, 0), size = Vector(0.013, -0.01, -0.013), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["base_scope"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(-0.015, 1.758, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["base_scope+"] = { type = "Model", model = "models/mechanics/solid_steel/box_beam_4.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(-0.015, -1.37, 0.558), angle = Angle(0, 90, 0), size = Vector(0.052, 0.026, 0.052), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["rail"] = { type = "Model", model = "models/props_phx/gears/rack18.mdl", bone = "ValveBiped.Anim_Attachment_RH", rel = "", pos = Vector(-0.371, -6.851, 13.073), angle = Angle(-180, -4.528, -81.509), size = Vector(0.207, 0.079, 0.053), color = Color(161, 161, 161, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_blur"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = true, nocull = false, material = "pp/dof", skin = 0, bodygroup = {} },
	["scope_back_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, 1.5, 1.3), angle = Angle(-135.69901, 0, 90), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_back_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_back_sight", pos = Vector(0, 0, -4.161), angle = Angle(90, -90, 0), size = Vector(0.025, 0.025, 0.025), color = Color(182, 182, 182, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "models/screenspace", skin = 0, bodygroup = {} },
	["scope_back_lens+"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_back_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_lens++"] = { type = "Model", model = "models/props_phx/construct/glass/glass_angle360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_front_sight", pos = Vector(0, 0, -4.2), angle = Angle(0, -90, 0), size = Vector(0.015, 0.015, 0.015), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_back_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, 0.418, 1.3), angle = Angle(0, 0, -90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_joint"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, -1.7, 1.3), angle = Angle(-135.69901, 0, 87.641), size = Vector(0.022, 0.022, 0.01), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_front_lens"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope_front_sight", pos = Vector(0, 0, -4.15), angle = Angle(90, 0, 0), size = Vector(0.025, 0.025, 0.025), color = Color(255, 255, 255, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "", skin = 0, bodygroup = {} },
	["scope_front_sight"] = { type = "Model", model = "models/hunter/tubes/tube4x4x1to2x2.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, -0.418, 1.3), angle = Angle(0, 0, 90), size = Vector(0.007, 0.007, 0.088), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} },
	["scope_middle"] = { type = "Model", model = "models/hunter/tubes/tube1x1x1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "rail", pos = Vector(0, -1.725, 1.28), angle = Angle(0, 0, 90), size = Vector(0.02, 0.02, 0.078), color = Color(112, 112, 112, 255), surpresslightning = false, bonemerge = false, highrender = false, nocull = false, material = "phoenix_storms/concrete1", skin = 0, bodygroup = {} }
}

-- 结束客户端专属配置块
end

-- 武器栏位：3 号栏（步枪），栏内位置 0
SWEP.Slot = 3
SWEP.SlotPos = 0

-- 继承的武器基类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（AR2 步枪）
SWEP.HoldType = "ar2"
-- 武器类型：步枪
SWEP.WeaponType = "rifle"

-- 视图模型与世界模型文件
SWEP.ViewModel = "models/weapons/tfa_dods/c_garand.mdl"
SWEP.WorldModel = "models/weapons/w_garand.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 单发伤害
SWEP.Primary.Damage = 65
-- 每次射击的弹丸数
SWEP.Primary.NumShots = 1
-- 射击间隔（半自动单发）
SWEP.Primary.Delay = 0.36

-- 弹匣容量 8 发（加兰德弹夹）
SWEP.Primary.ClipSize = 8
-- 半自动：每发需手动扣扳机
SWEP.Primary.Automatic = false
-- 使用的弹药类型
SWEP.Primary.Ammo = "357"
-- 初始备用弹药
SWEP.Primary.DefaultClip = 25

-- 换弹速度倍率
SWEP.ReloadSpeed = 0.64

-- 近战（枪托）伤害
SWEP.MeleeDamage = 45
-- 近战攻击距离
SWEP.MeleeRange = 72
-- 近战判定体积大小
SWEP.MeleeSize = 0.95
-- 近战击退力度
SWEP.MeleeKnockBack = 0

-- 近战挥击动画时长
SWEP.SwingTime = 0.35
-- 挥击动画旋转与偏移
SWEP.SwingRotation = Angle(-8, -20, 0)
SWEP.SwingOffset = Vector(0, -30, 0)

-- 右键可连续按住（开镜判定用）
SWEP.Secondary.Automatic = true
-- 右键开镜的最小间隔
SWEP.Secondary.Delay = 1.3

-- 最大/最小准星扩散（移动中/静止时）
SWEP.ConeMax = 2.75
SWEP.ConeMin = 1.25

-- 后坐力强度
SWEP.Recoil = 1.4

-- 移动速度：缓慢（重型步枪）
SWEP.WalkSpeed = SPEED_SLOW

-- 注册音效：拉栓（抛壳）声
sound.Add( {
	name = "Weapon_Garand.BoltForward",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {100},
	sound = "weapons/weapon_zs_garand/garand_boltforward.wav"
} )

-- 注册音效：弹夹装入（随机音调 1）
sound.Add( {
	name = "Weapon_Garand.ClipIn1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "weapons/weapon_zs_garand/garand_clipin1.wav"
} )

-- 注册音效：弹夹装入（随机音调 2）
sound.Add( {
	name = "Weapon_Garand.ClipIn2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {95, 110},
	sound = "weapons/weapon_zs_garand/garand_clipin2.wav"
} )

-- 注册音效：拔出武器声
sound.Add( {
	name = "Weapon_Garand.Draw",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {100},
	sound = "weapons/draw_rifle.wav"
} )

-- ==== SecondaryAttack - 右键开镜：未在装填、未持物时进入机瞄 ====
function SWEP:SecondaryAttack()
	if self:GetNextSecondaryFire() <= CurTime() and not self:GetOwner():IsHolding() and self:GetReloadFinish() == 0 then
		-- 进入机瞄（开镜）状态
		self:SetIronsights(true)
	end
end

-- ==== IsScoped - 判断是否已完成开镜（机瞄开启且经过 0.25 秒稳定时间） ====
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- 客户端专属：开镜时的视图模型与 HUD 处理
if CLIENT then

-- ==== GetViewModelPosition - 开镜时隐藏视图模型，避免遮挡瞄准视野 ====
function SWEP:GetViewModelPosition(pos, ang)
		-- 若模式禁用瞄准镜则不做处理
		if GAMEMODE.DisableScopes then return end

		-- 开镜状态下隐藏模型（返回空值）
		if self:IsScoped() then return end

		return BaseClass.GetViewModelPosition(self, pos, ang)
end

-- ==== DrawHUDBackground - 开镜时在 HUD 背景绘制瞄准镜遮罩 ====
function SWEP:DrawHUDBackground()
		-- 若模式禁用瞄准镜则不做处理
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			-- 绘制常规瞄准镜效果
			self:DrawRegularScope()
		end
end

end

-- 标记为近战可用武器（支持枪托打击）
SWEP.MeleeFlagged = true

-- ==== EmitFireSound - 开火音效：枪声 + 高音点缀的双层音效 ====
function SWEP:EmitFireSound()
	self:EmitSound("weapons/ak47/ak47-1.wav", 75, 76, 0.53)
	self:EmitSound("weapons/scout/scout_fire-1.wav", 75, 86, 0.67, CHAN_AUTO+20)
end

-- ==== PlayHitSound - 近战击中硬物音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/golf club/golf_hit-0"..math.random(4)..".ogg")
end

-- ==== PlayHitFleshSound - 近战击中血肉（僵尸）音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("weapons/knife/knife_stab.wav", 70, math.random(95, 105), 1, CHAN_AUTO+20)
end

-- ==== ShootBullets - 空仓射击时播放弹夹余弹"叮"声，再调用基类发射 ====
function SWEP:ShootBullets(dmg, numbul, cone)
	-- 弹匣为空：播放空仓"叮当"提示音
	if self:Clip1() == 0 then
		self:EmitSound("npc/roller/blade_out.wav", 70, math.random(80, 84), 0.5)
		self:EmitSound("weapons/weapon_zs_garand/garand_clipding.wav", 70, 100, 0.5, CHAN_AUTO+21)
	end

	-- 交由基类完成实际弹道发射
	BaseClass.ShootBullets(self, dmg, numbul, cone)
end