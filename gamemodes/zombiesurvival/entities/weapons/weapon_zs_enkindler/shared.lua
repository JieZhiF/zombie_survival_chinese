-- ============================================================================
-- shared.lua - 点燃者（Enkindler）武器共享定义
-- 负责：定义武器基础属性（发射动能冲击地雷投射物），实现左键地雷数量上限检查、
--       右键回收已放置地雷的机制，以及开火/换弹音效播放
-- ============================================================================
-- 武器显示名称（本地化文本）
SWEP.PrintName = "'"..translate.Get("weapon_zs_enkindler")
-- 武器描述（本地化文本）
SWEP.Description = ""..translate.Get("weapon_zs_enkindler_description")


-- 武器在槽位内的位置
SWEP.SlotPos = 0

-- 继承自投射物发射武器基类
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势（霰弹枪式）
SWEP.HoldType = "shotgun"

-- 第一人称/第三人称模型（借用 RPG 与火箭筒模型）
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

-- 第一人称镜头视野大小
SWEP.ViewModelFOV = 60

-- 主攻击开火音效
SWEP.Primary.Sound = Sound("weapons/grenade_launcher1.wav")
-- 主攻击间隔（秒）
SWEP.Primary.Delay = 1

-- 主攻击伤害
SWEP.Primary.Damage = 36.5
-- 弹匣容量（每次装填 1 发）
SWEP.Primary.ClipSize = 1
-- 半自动（单发）
SWEP.Primary.Automatic = false
-- 消耗的弹药类型
SWEP.Primary.Ammo = "impactmine"
-- 默认赠送弹药量
SWEP.Primary.DefaultClip = 7

-- 换弹音效
SWEP.ReloadSound = Sound("weapons/ar2/ar2_reload.wav")

-- 精准度：完全固定，无扩散（地雷无需精确瞄准）
SWEP.ConeMax = 0
SWEP.ConeMin = 0

-- 持枪移动速度（最慢速度的 90%）
SWEP.WalkSpeed = SPEED_SLOWEST * 0.9

-- 使用玩家手部模型
SWEP.UseHands = true

-- 场上同时存在的地雷数量上限
SWEP.MaxMines = 6

-- 武器等级
SWEP.Tier = 2

-- 附加武器强化修饰符：提升地雷数量上限 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAXIMUM_MINES, 1)

-- ==== CanPrimaryAttack - 检查左键攻击是否可用 ====
-- 在父类判定基础上，统计场内本人放置的存活地雷数，达到上限则禁止再发射
function SWEP:CanPrimaryAttack()
	if self.BaseClass.CanPrimaryAttack(self) then
		-- 统计当前存活（或刚放置 300 秒内）且属于本玩家的动能地雷
		local c = 0
		for _, ent in pairs(ents.FindByClass("projectile_impactmine_kin")) do
			if (CLIENT or ent.CreateTime + 300 > CurTime()) and ent:GetOwner() == self:GetOwner() then
				c = c + 1
			end
		end

		-- 已放置数量达到上限则禁止继续埋雷
		if c >= self.MaxMines then return false end

		return true
	end

	return false
end

-- ==== CanSecondaryAttack - 检查右键攻击是否可用 ====
-- 手持道具、建造预览中或正在换弹时禁止回收地雷
function SWEP:CanSecondaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then return false end

	return self:GetNextSecondaryFire() <= CurTime()
end

-- ==== SecondaryAttack - 右键回收已放置的地雷 ====
-- 瞄准线前方一定半径内的动能地雷被拆除，原地生成可拾取的弹药道具归还弹药
function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	-- 设置右键攻击冷却
	self:SetNextSecondaryFire(CurTime() + 0.1)

	local owner = self:GetOwner()
	-- 沿准星方向做近战补偿射线，取命中点作为拆除搜索中心
	local hitpos = owner:CompensatedMeleeTrace(2048, 1, nil, nil, false).HitPos

	if SERVER then
		-- 在命中点附近寻找属于本玩家的地雷并拆除
		for _, ent in pairs(ents.FindInSphere(hitpos, 24)) do
			if ent:GetClass() == "projectile_impactmine_kin" and ent:GetOwner() == owner then
				-- 在地雷原位生成弹药道具（1 发冲击地雷弹药）
				local mine = ents.Create("prop_ammo")
				if mine:IsValid() then
					mine:SetAmmo(1)
					mine:SetAmmoType("impactmine")
					mine:SetPos(ent:GetStartPos())
					mine:SetAngles(ent:GetAngles())
					mine:Spawn()
				end

				-- 存活人类玩家拆除后，弹药短暂只允许本人拾取
				if owner:IsValidLivingHuman() then
					mine.NoPickupsTime = CurTime() + 15
					mine.NoPickupsOwner = owner
				end

				-- 移除已回收的地雷实体
				ent:Remove()
			end
		end
	end
end


-- ==== EmitFireSound - 播放开火音效 ====
-- 以 65% 音量、随机 107~113 音调播放主攻击音效
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 65, math.random(107, 113), 0.6)
end

-- ==== EmitReloadSound - 播放换弹音效 ====
-- 仅首次预测时播放，音量 60、音调 110，使用独立音道避免覆盖开火音效
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound(self.ReloadSound, 60, 110, 0.5, CHAN_WEAPON + 21)
	end
end
