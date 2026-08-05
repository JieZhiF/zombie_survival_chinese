-- ============================================================================
-- weapon_zs_blaster.lua - 爆裂散弹枪（Blaster）
-- 负责：霰弹枪母本派生武器，8 粒弹丸近距爆发；带"改装分支"（改造为
--       单发高伤重型弹），开火后播放上膛动画
-- ============================================================================
AddCSLuaFile() -- 将该文件同时发送到客户端

-- 继承霰弹枪武器母本
SWEP.Base = "weapon_zs_baseshotgun"

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_blaster")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_blaster_description")

if CLIENT then -- 客户端专属设置
	SWEP.ViewModelFlip = false -- 不翻转第一人称模型

	-- HUD 3D 武器展示图：绑定骨骼与位置/角度/缩放
	SWEP.HUD3DPos = Vector(4, -3.5, -1.2)
	SWEP.HUD3DAng = Angle(90, 0, -30)
	SWEP.HUD3DScale = 0.02
	SWEP.HUD3DBone = "SS.Grip.Dummy"
end

-- 手持姿势：霰弹枪姿势
SWEP.HoldType = "shotgun"

-- 第一人称模型（超短管霰弹枪）
SWEP.ViewModel = "models/weapons/v_supershorty/v_supershorty.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_supershorty.mdl"
SWEP.UseHands = false -- 不使用玩家手臂模型

SWEP.ReloadDelay = 0.4 -- 换弹间隔

SWEP.Primary.Sound = Sound("Weapon_Shotgun.NPC_Single") -- 开火音效
SWEP.Primary.Damage = 8.325 -- 单粒弹丸伤害
SWEP.Primary.NumShots = 8 -- 一次射击 8 粒弹丸
SWEP.Primary.Delay = 0.8 -- 射击间隔

SWEP.Primary.ClipSize = 5 -- 弹仓容量
SWEP.Primary.Automatic = false -- 半自动（单发）
SWEP.Primary.Ammo = "buckshot" -- 弹药类型：鹿弹
GAMEMODE:SetupDefaultClip(SWEP.Primary) -- 按游戏模式规则设置默认备弹

SWEP.ConeMax = 8.75 -- 最大扩散
SWEP.ConeMin = 5 -- 最小扩散

SWEP.WalkSpeed = SPEED_SLOWER -- 手持时移动速度（较慢）

SWEP.PumpSound = Sound("Weapon_M3.Pump") -- 上膛音效
SWEP.ReloadSound = Sound("Weapon_Shotgun.Reload") -- 换弹音效

SWEP.PumpActivity = ACT_SHOTGUN_PUMP -- 上膛动画

-- 附加武器修正：弹仓容量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 1)
-- 注册改装分支（重型弹改造）：伤害 x5.5、改为单发、大幅降低扩散
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_blaster_r1"), ""..translate.Get("weapon_zs_blaster_r1_description"), function(wept)
	wept.Primary.Damage = wept.Primary.Damage * 5.5
	wept.Primary.NumShots = 1
	wept.ConeMin = wept.ConeMin * 0.15
	wept.ConeMax = wept.ConeMax * 0.3
end)

-- ==== SendWeaponAnimation - 播放开火与上膛动画 ====
-- 先播放射击动画，延迟 0.15 秒后播放泵动上膛动画并附带上膛音效
function SWEP:SendWeaponAnimation()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- 播放射击动画
	self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed) -- 加快动画播放

	timer.Simple(0.15, function() -- 延迟触发上膛动作
		if IsValid(self) then
			self:SendWeaponAnim(ACT_SHOTGUN_PUMP) -- 播放泵动上膛动画
			self:GetOwner():GetViewModel():SetPlaybackRate(self.FireAnimSpeed) -- 加快动画播放

			-- 仅本地玩家听到上膛音效
			if CLIENT and self:GetOwner() == MySelf then
				self:EmitSound("weapons/m3/m3_pump.wav", 65, 100, 0.4, CHAN_AUTO)
			end
		end
	end)
end
