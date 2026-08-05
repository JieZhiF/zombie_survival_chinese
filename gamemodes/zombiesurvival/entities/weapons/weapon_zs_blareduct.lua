-- ============================================================================
-- weapon_zs_blareduct.lua - 管道霰弹枪（Blare Duct）
-- 负责：定义霰弹枪属性（8 弹丸散射）、管道拼装外观（第一/三人称）、自定义开火音效与视角动画
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_blareduct")

-- 武器选择槽内位置 0
SWEP.SlotPos = 0

if CLIENT then
	-- 武器槽位：霰弹枪类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotShotguns")
	-- 武器选择分组：霰弹枪
	SWEP.SlotGroup = WEPSELECT_SHOTGUN
	-- HUD 3D 模型挂点：枪骨骼
	SWEP.HUD3DBone = "ValveBiped.Gun"
	-- HUD 3D 模型偏移位置
	SWEP.HUD3DPos = Vector(1.65, 0, -8)
	-- HUD 3D 模型缩放
	SWEP.HUD3DScale = 0.025

	-- 不翻转第一人称模型
	SWEP.ViewModelFlip = false

	-- 第一人称附加模型：管道枪身组合件
	SWEP.VElements = {
		["pipe++"] = { type = "Model", model = "models/props_vehicles/carparts_axel01a.mdl", bone = "ValveBiped.Gun", rel = "pipe", pos = Vector(0.699, 0, 0), angle = Angle(0, 0, 90), size = Vector(0.15, 0.4, 0.2), color = Color(105, 115, 130, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["pipe+"] = { type = "Model", model = "models/props_vehicles/carparts_muffler01a.mdl", bone = "ValveBiped.Gun", rel = "pipe", pos = Vector(1, -0.201, -15), angle = Angle(90, -90, 0), size = Vector(0.2, 0.3, 0.25), color = Color(105, 115, 130, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["pipe+++"] = { type = "Model", model = "models/props_vehicles/carparts_axel01a.mdl", bone = "ValveBiped.Gun", rel = "pipe", pos = Vector(0, 0, -10), angle = Angle(0, 0, 90), size = Vector(0.25, 0.3, 0.15), color = Color(77, 77, 82, 255), surpresslightning = false, material = "models/props_lab/ravendoor_sheet", skin = 0, bodygroup = {} },
		["pipe"] = { type = "Model", model = "models/props_canal/mattpipe.mdl", bone = "ValveBiped.Gun", rel = "", pos = Vector(0, 0.5, 7), angle = Angle(0, -90, 0), size = Vector(1, 1, 0.899), color = Color(65, 69, 84, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型附加模型：第三人称对应的管道组合件
	SWEP.WElements = {
		["pipe++"] = { type = "Model", model = "models/props_vehicles/carparts_axel01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "pipe", pos = Vector(0.699, 0, 0), angle = Angle(0, 0, 90), size = Vector(0.15, 0.4, 0.2), color = Color(105, 115, 130, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["pipe+"] = { type = "Model", model = "models/props_vehicles/carparts_muffler01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "pipe", pos = Vector(1, -0.201, -15), angle = Angle(90, -90, 0), size = Vector(0.2, 0.3, 0.25), color = Color(105, 115, 130, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["pipe+++"] = { type = "Model", model = "models/props_vehicles/carparts_axel01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "pipe", pos = Vector(0, 0, -10), angle = Angle(0, 0, 90), size = Vector(0.25, 0.3, 0.15), color = Color(77, 77, 82, 255), surpresslightning = false, material = "models/props_lab/ravendoor_sheet", skin = 0, bodygroup = {} },
		["pipe"] = { type = "Model", model = "models/props_canal/mattpipe.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(19, 1, -5), angle = Angle(85.324, 0, 180), size = Vector(1, 1, 0.899), color = Color(65, 69, 84, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 母本：霰弹枪基础
SWEP.Base = "weapon_zs_baseshotgun"
-- 定义母本类引用（供 BaseClass 调用）
DEFINE_BASECLASS("weapon_zs_baseshotgun")

-- 持枪姿势：霰弹枪
SWEP.HoldType = "shotgun"

-- 第一人称模型（CS 霰弹枪，实际隐藏，仅用附加管道件显示）
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 隐藏第一人称模型本体（外观完全由附加模型拼装）
SWEP.ShowViewModel = false
-- 隐藏世界模型本体
SWEP.ShowWorldModel = false

-- 开火音效（双管霰弹枪音）
SWEP.Primary.Sound = Sound("weapons/shotgun/shotgun_dbl_fire.wav")
-- 单颗弹丸伤害
SWEP.Primary.Damage = 7.7625
-- 每次开火射出 8 颗弹丸（霰弹散射）
SWEP.Primary.NumShots = 8
-- 射击间隔 0.75 秒
SWEP.Primary.Delay = 0.75

-- 单发弹匣
SWEP.Primary.ClipSize = 1
-- 自动开火（单发弹匣打完即自动装填）
SWEP.Primary.Automatic = true
-- 消耗鹿弹弹药
SWEP.Primary.Ammo = "buckshot"
-- 换弹音效
SWEP.ReloadSound = Sound("weapons/aug/aug_boltslap.wav")
-- 按游戏模式规则设置默认弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 换弹速度系数（每发装填耗时）
SWEP.ReloadSpeed = 0.45
-- 换弹开始前的延迟
SWEP.ReloadDelay = 0.45

-- 后坐力强度
SWEP.Recoil = 70

-- 开火动画播放速度（慢动作枪口上扬）
SWEP.FireAnimSpeed = 0.5

-- 最大扩散
SWEP.ConeMax = 8
-- 最小扩散
SWEP.ConeMin = 7

-- 移动速度：常规
SWEP.WalkSpeed = SPEED_NORMAL

-- 附加武器强化修改器：换弹速度 +0.19
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.19, 1)
-- 附加武器强化修改器：后坐力 -32.5
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RECOIL, -32.5)
-- 附加武器强化修改器：最小扩散 -1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MIN_SPREAD, -1)

-- ==== EmitFireSound - 播放开火音效 ====
function SWEP:EmitFireSound()
	-- 主音效：随机高音调（187-193）的双管枪声
	self:EmitSound(self.Primary.Sound, 75, math.random(187, 193), 0.7)
	-- 附加音效：随机中音调（102-148）的低沉尾音，叠加在武器声道上
	self:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, math.random(102, 148), 0.6, CHAN_WEAPON + 20)
end

-- ==== SecondaryAttack - 禁用右键开火 ====
function SWEP:SecondaryAttack()
end

-- 以下为客户端专属代码
if not CLIENT then return end

-- 镜头下压插值系数（0 正常视角 - 1 完全下压）
local ghostlerp = 0
-- ==== CalcViewModelView - 计算第一人称视角位置/角度 ====
function SWEP:CalcViewModelView(vm, oldpos, oldang, pos, ang)
	-- 正在放置幽灵或换弹时：视角逐渐下压（枪口朝下）
	if self:GetOwner():GetBarricadeGhosting() or self:IsReloading() then
		ghostlerp = math.min(1, ghostlerp + FrameTime() * 0.5)
	elseif ghostlerp > 0 then
		-- 恢复正常视角（平滑回弹）
		ghostlerp = math.max(0, ghostlerp - FrameTime() * 0.5)
	end

	-- 按插值系数绕右轴下压视角（最多 35 度）
	if ghostlerp > 0 then
		ang:RotateAroundAxis(ang:Right(), -35 * ghostlerp)
	end

	return pos, ang
end
