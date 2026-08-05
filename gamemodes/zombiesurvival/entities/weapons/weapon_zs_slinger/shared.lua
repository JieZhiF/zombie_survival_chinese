-- ============================================================================
-- weapon_zs_slinger/shared.lua - 弹弓（共享端）
-- 负责：定义弹弓的投射物属性（单发装填弩箭）、两个改造分支与自定义音效
-- ============================================================================

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_slinger")
-- 武器描述
SWEP.Description = ""..translate.Get("weapon_zs_slinger_description")

-- 母本：投射物武器基础
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势：左轮手枪
SWEP.HoldType = "revolver"

-- 第一人称模型（P228 手枪模型）
SWEP.ViewModel = "models/weapons/cstrike/c_pist_p228.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 显示第一人称模型
SWEP.ShowViewModel = true
-- 显示世界模型
SWEP.ShowWorldModel = true
-- 无骨骼调整
SWEP.ViewModelBoneMods = {}

-- 不使用 CS 风格枪口闪光（投射物武器无枪口火光）
SWEP.CSMuzzleFlashes = false

-- 开火音效（十字弩音）
SWEP.Primary.Sound = Sound("Weapon_Crossbow.Single")
-- 射击间隔 1 秒
SWEP.Primary.Delay = 1
-- 自动开火
SWEP.Primary.Automatic = true
-- 单发伤害
SWEP.Primary.Damage = 59

-- 单发弹匣（每次装填一根弩箭）
SWEP.Primary.ClipSize = 1
-- 消耗十字弩箭弹药
SWEP.Primary.Ammo = "XBowBolt"
-- 弹匣倍数 2（默认携带 2 根箭）
SWEP.Primary.ClipMultiplier = 2
-- 按游戏模式规则设置默认弹匣
GAMEMODE:SetupDefaultClip(SWEP.Primary)

-- 最大扩散
SWEP.ConeMax = 2.5
-- 最小扩散
SWEP.ConeMin = 1.2

-- 下次缩放时间戳（机瞄缩放冷却）
SWEP.NextZoom = 0

-- 换弹速度系数
SWEP.ReloadSpeed = 0.59

-- 附加武器强化修改器：换弹速度 +0.07
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_RELOAD_SPEED, 0.07)
-- 改造分支 1：蓝色箭矢——伤害略降、箭速提升至 2300，箭头标记为分支 1 类型（蓝色外观）
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_slinger_r1"), ""..translate.Get("weapon_zs_slinger_r1_description")	, function(wept)
	-- 伤害降至 90%
	wept.Primary.Damage = wept.Primary.Damage * 0.9
	-- 箭矢飞行速度 2300
	wept.Primary.ProjVelocity = 2300
	if SERVER then
		-- 投射物生成后设置分支 1 标记（蓝色箭矢外观）
		wept.EntModify = function(self, ent)
			ent:SetDTBool(0, true)
		end
	end
end)
-- 改造分支 2：蓄力箭——伤害略降、准度极高，箭矢伤害随飞行时间增长（最多 1.6 倍）
local branch = GAMEMODE:AddNewRemantleBranch(SWEP, 2, ""..translate.Get("weapon_zs_slinger_r2"), ""..translate.Get("weapon_zs_slinger_r2_description"), function(wept)
	-- 伤害降至 75%
	wept.Primary.Damage = wept.Primary.Damage * 0.75
	-- 最小扩散降至 0.3（几乎百发百中）
	wept.ConeMin = 0.3
	if SERVER then
		-- 投射物生成后设置分支 2 标记（蓄力箭：伤害随飞行时间增长）
		wept.EntModify = function(self, ent)
			ent:SetDTBool(1, true)
		end
	end
end)
-- 分支 2 强化等级颜色（粉红色系）
branch.Colors = {Color(255, 160, 150), Color(215, 120, 150), Color(175, 100, 140)}
-- 分支 2 各强化等级显示名称
branch.NewNames = {""..translate.Get("weapon_zs_slinger_r2_l1"), ""..translate.Get("weapon_zs_slinger_r2_l2"), ""..translate.Get("weapon_zs_slinger_r2_l3")}

-- ==== SendReloadAnimation - 播放换弹动画 ====
function SWEP:SendReloadAnimation()
	-- 以出枪动画代替换弹动画（拉弓动作）
	self:SendWeaponAnim(ACT_VM_DRAW)
end

-- ==== EmitReloadFinishSound - 换弹完成音效 ====
function SWEP:EmitReloadFinishSound()
	-- 仅首次预测时播放（避免重复音效）
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/galil/galil_boltpull.wav", 70, 190)
	end
end

-- ==== EmitReloadSound - 换弹开始音效 ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound("weapons/g3sg1/g3sg1_clipout.wav", 70, 135, 0.9, CHAN_AUTO)
	end
end

-- ==== EmitFireSound - 开火音效 ====
function SWEP:EmitFireSound()
	-- 高音调（230）的弩发射音
	self:EmitSound("weapons/crossbow/fire1.wav", 70, 230, 0.9, CHAN_WEAPON)
end

-- 预缓存弩箭装填音效
util.PrecacheSound("weapons/crossbow/bolt_load1.wav")
util.PrecacheSound("weapons/crossbow/bolt_load2.wav")
