-- ============================================================================
-- weapon_zs_m82a3.lua - M82A3 重型反器材狙击步枪
-- 负责：定义狙击枪属性、瞄准镜附加模型，以及连续爆头触发"叛徒"状态的机制
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()
-- 定义基类为 weapon_zs_base，供后续 BaseClass 调用基类方法
DEFINE_BASECLASS("weapon_zs_base")

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_m82a3")
-- 武器商店描述
SWEP.Description = "补给箱所获取的特殊武器，非法获取会被封禁."


-- 武器栏内的位置
SWEP.SlotPos = 0

-- 客户端专属配置块
if CLIENT then
	-- 武器栏位：步枪栏
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
-- 武器类型与栏位分组（同一行两个属性，不可拆分）
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	-- 视图模型不镜像翻转
	SWEP.ViewModelFlip = false
	-- 第一人称视野角度
	SWEP.ViewModelFOV = 63.70351758794

	-- HUD 3D 预览（商店/击杀图标）：绑定骨骼、位置、角度与缩放
	SWEP.HUD3DBone = "v_weapon.sg550_Parent"
	SWEP.HUD3DPos = Vector(-2, -5.2, -2)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02

	-- 视图模型附加模型（SCK 元素）：拼接重型枪身、支架、弹匣、枪管与瞄准镜
	SWEP.VElements = {
		["kickstand_hold"] = { type = "Model", model = "models/Mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "canister_front", pos = Vector(-0.242, 0, 4.394), angle = Angle(0, 90, 90), size = Vector(0.254, 0.144, 0.144), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["scopebase"] = { type = "Model", model = "models/Mechanics/roboticslarge/g1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-2.064, 0, -0.262), angle = Angle(0, 0, 90), size = Vector(0.061, 0.037, 0.129), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["kickstand"] = { type = "Model", model = "models/props_c17/metalladder002b.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(-6.031, 0, 25.576), angle = Angle(135, 0, 180), size = Vector(0.164, 0.245, 0.368), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["clip"] = { type = "Model", model = "models/props_c17/consolebox01a.mdl", bone = "v_weapon.sg550_Clip", rel = "", pos = Vector(0.902, 3.177, 0.266), angle = Angle(0, 90, -90), size = Vector(0.104, 0.134, 0.15), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["canister_front"] = { type = "Model", model = "models/props_c17/canister_propane01a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(0.779, 0, -1.066), angle = Angle(-90, 0, 0), size = Vector(0.1, 0.1, 0.15), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["scope"] = { type = "Model", model = "models/props_lab/citizenradio.mdl", bone = "v_weapon.sg550_Parent", rel = "", pos = Vector(0, -6.222, -4.554), angle = Angle(-90, 90, 0), size = Vector(0.731, 0.127, 0.182), color = Color(75, 65, 55, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom_grip"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom", pos = Vector(0, -2.5, -6.072), angle = Angle(0, -90, 0), size = Vector(0.882, 0.865, 0.992), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_rooftop/roof_vent001.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "canister_front", pos = Vector(0, 0, 36.013), angle = Angle(180, 0, 0), size = Vector(0.173, 0.36, 0.727), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["thing_that_moves_back_when_you_shoot"] = { type = "Model", model = "models/props_rooftop/roof_vent001.mdl", bone = "v_weapon.sg550_Chamber", rel = "", pos = Vector(-0.077, 1.86, -2.192), angle = Angle(90, 0, 0), size = Vector(0.18, 0.18, 0.063), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["blackbars"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "canister_front", pos = Vector(0, 0, 4.34), angle = Angle(0, -90, 90), size = Vector(0.179, 0.5, 0.25), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["scope_screen"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scope", pos = Vector(-3.105, 0, 1.746), angle = Angle(0, -90, 0), size = Vector(0.078, 0.116, 0.064), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/props_combine/masterinterface_alert", skin = 0, bodygroup = {} },
		["bottom_back"] = { type = "Model", model = "models/props_c17/furniturefridge001a.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "bottom", pos = Vector(0, -12.132, 0.768), angle = Angle(0, -90, 0), size = Vector(0.057, 0.133, 0.052), color = Color(65, 65, 65, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["bottom"] = { type = "Model", model = "models/props_trainstation/train003.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "barrel", pos = Vector(-1.348, 0, 39.881), angle = Angle(0, 90, 90), size = Vector(0.027, 0.048, 0.019), color = Color(75, 85, 95, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} }
	}

	-- 世界模型附加模型（SCK 元素）：第三人称下的重型枪身组件
	SWEP.WElements = {
		["kickstand_hold"] = { type = "Model", model = "models/Mechanics/robotics/a1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "canister_front", pos = Vector(-0.242, 0, 4.394), angle = Angle(0, 90, 90), size = Vector(0.254, 0.144, 0.144), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["scopebase"] = { type = "Model", model = "models/Mechanics/roboticslarge/g1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-2.064, 0, -0.262), angle = Angle(0, 0, 90), size = Vector(0.061, 0.037, 0.129), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["kickstand"] = { type = "Model", model = "models/props_c17/metalladder002b.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-6.031, 0, 19.576), angle = Angle(135, 0, 180), size = Vector(0.164, 0.245, 0.368), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["clip"] = { type = "Model", model = "models/props_c17/consolebox01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom", pos = Vector(0.758, 4.119, -3.109), angle = Angle(90, 0, 0), size = Vector(0.104, 0.134, 0.15), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["canister_front"] = { type = "Model", model = "models/props_c17/canister_propane01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(0.779, 0, -1.066), angle = Angle(-90, 0, 0), size = Vector(0.1, 0.1, 0.15), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["scope"] = { type = "Model", model = "models/props_lab/citizenradio.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(8.354, 1.194, -6.069), angle = Angle(-171.883, 180, 0), size = Vector(0.731, 0.127, 0.182), color = Color(75, 65, 55, 255), surpresslightning = false, material = "models/props_combine/metal_combinebridge001", skin = 0, bodygroup = {} },
		["bottom_grip"] = { type = "Model", model = "models/weapons/w_pist_elite_single.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom", pos = Vector(0, -2.5, -6.072), angle = Angle(0, -90, 0), size = Vector(0.882, 0.865, 0.992), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["barrel"] = { type = "Model", model = "models/props_rooftop/roof_vent001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "canister_front", pos = Vector(0, 0, 29.892), angle = Angle(180, 0, 0), size = Vector(0.173, 0.36, 0.579), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["thing_that_moves_back_when_you_shoot"] = { type = "Model", model = "models/props_rooftop/roof_vent001.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom", pos = Vector(0.153, 5.056, 0.425), angle = Angle(-90, 0, 0), size = Vector(0.18, 0.18, 0.063), color = Color(75, 75, 75, 255), surpresslightning = false, material = "models/props_c17/metalladder001", skin = 0, bodygroup = {} },
		["bottom"] = { type = "Model", model = "models/props_trainstation/train003.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "barrel", pos = Vector(-1.348, 0, 33.347), angle = Angle(0, 90, 90), size = Vector(0.027, 0.048, 0.019), color = Color(75, 85, 95, 255), surpresslightning = false, material = "models/props_pipes/valve001_skin2", skin = 0, bodygroup = {} },
		["bottom_back"] = { type = "Model", model = "models/props_c17/furniturefridge001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "bottom", pos = Vector(0, -12.132, 0.768), angle = Angle(0, -90, 0), size = Vector(0.057, 0.133, 0.052), color = Color(65, 65, 65, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} },
		["scope_screen"] = { type = "Model", model = "models/props_junk/cardboard_box001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scope", pos = Vector(-3.105, 0, 1.746), angle = Angle(0, -90, 0), size = Vector(0.078, 0.116, 0.064), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/props_combine/masterinterface_alert", skin = 0, bodygroup = {} },
		["blackbars"] = { type = "Model", model = "models/props_c17/playground_teetertoter_stan.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "canister_front", pos = Vector(0, 0, 4.34), angle = Angle(0, -90, 90), size = Vector(0.179, 0.5, 0.25), color = Color(115, 115, 115, 255), surpresslightning = false, material = "models/weapons/v_stunbaton/w_shaft01a", skin = 0, bodygroup = {} }
	}
end

-- 注册音效：重型狙击枪开火声
sound.Add(
{
	name = "Weapon_Renegade.Single",
	channel = CHAN_AUTO,
	volume = 0.7,
	soundlevel = 80,
	pitchstart = 55,
	pitchend = 60,
	sound = {"weapons/zs_scar/scar_fire1.ogg"}
})

-- 不显示视图模型与世界模型（纯附加模型外观）
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

-- 继承的武器基类
SWEP.Base = "weapon_zs_base"

-- 持枪姿势（AR2 步枪）
SWEP.HoldType = "ar2"

-- 视图模型与世界模型文件
SWEP.ViewModel = "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel = "models/weapons/w_snip_sg550.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 开火音效（自定义注册音效）
SWEP.Primary.Sound = Sound("Weapon_Renegade.Single")
-- 单发伤害（重型反器材）
SWEP.Primary.Damage = 255
-- 每次射击的弹丸数
SWEP.Primary.NumShots = 1
-- 射击间隔（慢速栓动）
SWEP.Primary.Delay = 1.8

-- 弹匣容量 5 发
SWEP.Primary.ClipSize = 5
-- 全自动射击
SWEP.Primary.Automatic = true
-- 使用的弹药类型
SWEP.Primary.Ammo = "357"
-- 按幸存模式规则计算初始备弹
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 开火与换弹的动作手势
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN

-- 最大/最小准星扩散（静止时完全精准）
SWEP.ConeMax = 8.0
SWEP.ConeMin = 0
-- 爆头伤害倍率
SWEP.HeadshotMulti = 2.45
-- 换弹速度倍率
SWEP.ReloadSpeed = 0.85

-- 标记为狙击步枪
SWEP.SniperRifle = true
-- 机瞄（开镜）时的位置偏移与角度
SWEP.IronSightsPos = Vector(11, -9, -2.2)
SWEP.IronSightsAng = Vector(0, 0, 0)

-- 移动速度：最缓慢（重型狙击枪）
SWEP.WalkSpeed = SPEED_SLOWEST

-- 武器等级（Tier 5）
SWEP.Tier = 5

-- 开火动画速度倍率
SWEP.FireAnimSpeed = 0.5

-- 强化修饰器：降低射击间隔
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.13, 1)

-- ==== EmitFireSound - 开火音效：枪声 + 狙击回响 + 机械声的三层音效 ====
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound)
	self:EmitSound("npc/sniper/sniper1.wav", 80, 125, 0.85, CHAN_AUTO)
	self:EmitSound("weapons/sg552/sg552-1.wav", 80, 145, 0.75, CHAN_WEAPON + 20)
end

-- ==== IsScoped - 判断是否已完成开镜（机瞄开启且经过 0.25 秒稳定时间） ====
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- ==== OnZombieKilled - 连续爆头击杀 3 只僵尸后，给予"叛徒"强化状态 ====
function SWEP:OnZombieKilled(zombie)
	local killer = self:GetOwner()

	-- 仅统计爆头击杀
	if killer:IsValid() and zombie:WasHitInHead() then
		killer.RenegadeHeadshots = (killer.RenegadeHeadshots or 0) + 1

		-- 累计 3 次爆头后触发状态并清零计数
		if killer.RenegadeHeadshots >= 3 then
			killer:GiveStatus("renegade", 17)
			killer.RenegadeHeadshots = 0
		end
	end
end

-- 客户端专属：开镜时的视图模型与 HUD 处理
if CLIENT then
	-- 机瞄时的灵敏度倍率
	SWEP.IronsightsMultiplier = 0.25

	-- ==== GetViewModelPosition - 开镜时隐藏视图模型，避免遮挡瞄准视野 ====
	function SWEP:GetViewModelPosition(pos, ang)
		-- 若模式禁用瞄准镜则不做处理
		if GAMEMODE.DisableScopes then return end

		-- 开镜状态下隐藏模型（返回空值）
		if self:IsScoped() then return end

		return BaseClass.GetViewModelPosition(self, pos, ang)
	end

	-- ==== DrawHUDBackground - 开镜时在 HUD 背景绘制未来风瞄准镜遮罩 ====
	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end

		if self:IsScoped() then
			-- 绘制未来风瞄准镜效果
			self:DrawFuturisticScope()
		end
	end
end
