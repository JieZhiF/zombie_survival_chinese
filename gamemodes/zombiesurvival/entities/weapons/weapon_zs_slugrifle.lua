-- ============================================================================
-- weapon_zs_slugrifle.lua - 独头弹狙击步枪（Slug Rifle）
-- 负责：霰弹枪母本改造的狙击武器：单发高伤独头弹、2.5 倍爆头倍率、
--       可机瞄开镜（狙击镜 HUD），爆头对普通僵尸附带额外最大生命值伤害
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端
DEFINE_BASECLASS("weapon_zs_baseshotgun") -- 定义 BaseClass 引用

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_slugrifle")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_slugrifle_description")

-- 武器在栏位中的位置序号
SWEP.SlotPos = 0

if CLIENT then -- 客户端专属设置
	-- 武器栏位：放入"步枪"分类
	SWEP.Slot = GAMEMODE:GetWeaponSlot("WeaponSelectSlotRifles")
-- 武器类型标记：步枪；栏位组：步枪栏
SWEP.WeaponType = "rifle"	SWEP.SlotGroup = WEPSELECT_RIFLE
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型
	SWEP.ViewModelFOV = 60 -- 第一人称视野大小

	-- HUD 3D 武器展示图：绑定骨骼与位置/角度/缩放
	SWEP.HUD3DBone = "v_weapon.xm1014_Bolt"
	SWEP.HUD3DPos = Vector(-1, 0, 0)
	SWEP.HUD3DAng = Angle(0, 0, 0)
	SWEP.HUD3DScale = 0.02

	-- 第一人称手持元素：用零件拼装出狙击镜（镜筒、旋钮、支架、镜片）
	SWEP.VElements = {
		["scopemid"] = { type = "Model", model = "models/xqm/rails/funnel.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(4.645, 0, 0), angle = Angle(90, 0, 0), size = Vector(0.02, 0.02, 0.075), color = Color(95, 95, 95, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "v_weapon.xm1014_Parent", rel = "", pos = Vector(0.079, -6.515, -0.695), angle = Angle(-90, 0, 0), size = Vector(0.019, 0.041, 0.041), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["knobs+"] = { type = "Model", model = "models/XQM/cylinderx1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(5.763, -0.769, 0), angle = Angle(180, 90, 98.054), size = Vector(0.079, 0.079, 0.079), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["mount"] = { type = "Model", model = "models/XQM/CoasterTrack/track_guide.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(6.022, 1.996, 0), angle = Angle(90, -90, 0), size = Vector(0.037, 0.041, 0.056), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopemid+"] = { type = "Model", model = "models/xqm/rails/funnel.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(8.166, 0, 0), angle = Angle(-90, 0, 0), size = Vector(0.02, 0.02, 0.014), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning+++"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "v_weapon.xm1014_Parent", rel = "scopebeginning", pos = Vector(9.295, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.014, 0.041, 0.041), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["midsection"] = { type = "Model", model = "models/props_phx/misc/smallcannonball.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(5.747, -0.026, -0.81), angle = Angle(-90, 0, 0), size = Vector(0.114, 0.114, 0.114), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning++"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "v_weapon.xm1014_Parent", rel = "scopebeginning", pos = Vector(7.31, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.043, 0.019, 0.017), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning+"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "v_weapon.xm1014_Parent", rel = "scopebeginning", pos = Vector(4.828, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.028, 0.019, 0.014), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["glass"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(-0.238, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.039, 0.039, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/dome_side", skin = 0, bodygroup = {} },
		["knobs"] = { type = "Model", model = "models/XQM/cylinderx1.mdl", bone = "ValveBiped.Bip01_Spine4", rel = "scopebeginning", pos = Vector(5.763, 0, 0), angle = Angle(90, 0, 0), size = Vector(0.159, 0.079, 0.079), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
	}

	-- 第三人称世界元素：同样的狙击镜拼装，绑在玩家右手骨骼上
	SWEP.WElements = {
		["scopemid"] = { type = "Model", model = "models/xqm/rails/funnel.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(4.645, 0, -0.04), angle = Angle(90, 0, 0), size = Vector(0.02, 0.02, 0.075), color = Color(95, 95, 95, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.928, 0.908, -5.581), angle = Angle(-10, 0, -90), size = Vector(0.019, 0.041, 0.041), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["knobs+"] = { type = "Model", model = "models/XQM/cylinderx1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(5.763, -0.769, 0), angle = Angle(180, 90, 98.054), size = Vector(0.079, 0.079, 0.079), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["glass+"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(9.529, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.039, 0.039, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/dome_side", skin = 0, bodygroup = {} },
		["mount"] = { type = "Model", model = "models/XQM/CoasterTrack/track_guide.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(6.022, 1.996, 0), angle = Angle(90, -90, 0), size = Vector(0.037, 0.041, 0.056), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["glass"] = { type = "Model", model = "models/XQM/panel360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(-0.238, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.039, 0.039, 0.039), color = Color(255, 255, 255, 255), surpresslightning = false, material = "phoenix_storms/dome_side", skin = 0, bodygroup = {} },
		["scopebeginning+++"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(9.274, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.014, 0.041, 0.041), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning++"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(7.31, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.043, 0.019, 0.017), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopemid+"] = { type = "Model", model = "models/xqm/rails/funnel.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(8.166, 0, 0.05), angle = Angle(-90, 0, 0), size = Vector(0.02, 0.02, 0.014), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["scopebeginning+"] = { type = "Model", model = "models/XQM/deg360.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(4.828, 0, 0), angle = Angle(0, 0, 0), size = Vector(0.028, 0.019, 0.014), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["midsection"] = { type = "Model", model = "models/props_phx/misc/smallcannonball.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(5.747, -0.026, -0.81), angle = Angle(-90, 0, 0), size = Vector(0.114, 0.114, 0.114), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} },
		["knobs"] = { type = "Model", model = "models/XQM/cylinderx1.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "scopebeginning", pos = Vector(5.763, 0, 0), angle = Angle(90, 0, 0), size = Vector(0.159, 0.079, 0.079), color = Color(105, 105, 105, 255), surpresslightning = false, material = "models/props_pipes/pipemetal001a", skin = 0, bodygroup = {} }
	}
end

-- 继承霰弹枪武器母本
SWEP.Base = "weapon_zs_baseshotgun"

-- 手持姿势：AR2 步枪姿势
SWEP.HoldType = "ar2"

-- 第一人称模型（XM1014 霰弹枪骨架）
SWEP.ViewModel = "models/weapons/cstrike/c_shot_xm1014.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_shot_xm1014.mdl"
SWEP.UseHands = true -- 使用玩家手臂模型握持

SWEP.Primary.Sound = Sound("Weapon_AWP.Single") -- 开火音效（AWP 枪声）
SWEP.Primary.Damage = 118 -- 单发伤害
SWEP.Primary.NumShots = 1 -- 单发独头弹
SWEP.Primary.Delay = 1.3 -- 射击间隔
SWEP.ReloadDelay = 0.6 -- 单发装填间隔

SWEP.Primary.ClipSize = 4 -- 弹仓容量
SWEP.Primary.Automatic = false -- 半自动（单发）
SWEP.Primary.Ammo = "357" -- 弹药类型：马格南子弹
SWEP.Primary.DefaultClip = 10 -- 默认备弹数

SWEP.HeadshotMulti = 2.5 -- 爆头伤害倍率
SWEP.TracerName = "tracer_sniper_big" -- 粗狙击曳光弹特效
SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW -- 开火手势
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN -- 换弹手势

SWEP.ConeMax = 6 -- 最大扩散（未开镜）
SWEP.ConeMin = 0.25 -- 最小扩散（开镜后极精准）

SWEP.Tier = 4 -- 武器等级（4 级武器）
SWEP.MaxStock = 3 -- 商店最大库存量

SWEP.IronSightsPos = Vector(0, 0, 0) -- 机瞄视角位置
SWEP.IronSightsAng = Vector(0, -1, 0) -- 机瞄视角角度

SWEP.WalkSpeed = SPEED_SLOWER -- 手持时移动速度（较慢）

-- 附加武器修正：换弹速度 +0.135/级；开火间隔 -0.09 秒
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.135)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.09, 1)

-- ==== IsScoped - 判断是否已开镜 ====
-- 处于机瞄状态且开镜动画已完成 0.25 秒以上才算开镜
function SWEP:IsScoped()
	return self:GetIronsights() and self.fIronTime and self.fIronTime + 0.25 <= CurTime()
end

-- ==== SecondaryAttack - 右键：开镜 ====
-- 直接调用霰弹枪母本（再往上一级）的副攻击逻辑
function SWEP:SecondaryAttack()
	return BaseClass.BaseClass.SecondaryAttack(self)
end

-- ==== Think - 思考帧 ====
-- 松开右键后自动关闭机瞄（防止一直开镜）
function SWEP:Think()
	if self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	BaseClass.Think(self)
end
SWEP.SniperRifle = true -- 标记为狙击步枪（启用狙击相关机制）
if CLIENT then -- 客户端专属设置
	SWEP.IronsightsMultiplier = 0.25 -- 开镜视野缩放倍率

	-- ==== GetViewModelPosition - 开镜时隐藏第一人称模型 ====
	function SWEP:GetViewModelPosition(pos, ang)
		if GAMEMODE.DisableScopes then return end -- 禁用狙击镜时保持默认

		if self:IsScoped() then return end -- 开镜时不绘制枪模

		return BaseClass.GetViewModelPosition(self, pos, ang)
	end

	-- ==== DrawHUDBackground - 绘制狙击镜 HUD ====
	function SWEP:DrawHUDBackground()
		if GAMEMODE.DisableScopes then return end -- 禁用狙击镜时保持默认

		if self:IsScoped() then
			self:DrawRegularScope() -- 绘制常规狙击镜画面
		end
	end
end

-- ==== BulletCallback - 子弹命中回调：爆头额外伤害 ====
-- 命中头部时，对非 BOSS 僵尸追加其最大生命值 55% 的额外伤害
function SWEP.BulletCallback(attacker, tr, dmginfo)
	if tr.HitGroup == HITGROUP_HEAD then
		local ent = tr.Entity
		-- BOSS 僵尸免疫该爆头斩杀效果
		if ent:IsValidLivingZombie() and ent:GetZombieClassTable().Boss then
			return
		end

		-- 通过伤害门检查后，追加最大生命值 55% 的直接伤害
		if gamemode.Call("PlayerShouldTakeDamage", ent, attacker) then
			dmginfo:SetDamageType(DMG_DIRECT)
			dmginfo:SetDamage(dmginfo:GetDamage() + ent:GetMaxHealthEx() * 0.55)
		end
	end
end
