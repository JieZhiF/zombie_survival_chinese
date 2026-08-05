-- ============================================================================
-- weapon_zs_minelayer/shared.lua - 冲击地雷发射器（共享端定义）
-- 负责：武器基础属性、左键发射冲击地雷、右键回收已放置的地雷、强化分支
-- ============================================================================
-- 武器名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_minelayer")
-- 武器描述（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_minelayer_description")


-- 武器在武器选择栏中的位置
SWEP.SlotPos = 0

-- 继承基础投射物武器（提供发射投射物逻辑）
SWEP.Base = "weapon_zs_baseproj"

-- 持枪姿势（霰弹枪姿势）
SWEP.HoldType = "shotgun"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

-- 第一人称视野大小
SWEP.ViewModelFOV = 60

-- 左键开火音效
SWEP.Primary.Sound = Sound("weapons/grenade_launcher1.wav")
-- 射击间隔（秒）
SWEP.Primary.Delay = 1

-- 地雷直接命中伤害
SWEP.Primary.Damage = 26.67
-- 弹匣容量（每次装填一颗地雷）
SWEP.Primary.ClipSize = 1
-- 非全自动，需逐发点击
SWEP.Primary.Automatic = false
-- 消耗的弹药类型
SWEP.Primary.Ammo = "impactmine"
-- 初始弹药数
SWEP.Primary.DefaultClip = 7

-- 换弹音效
SWEP.ReloadSound = Sound("weapons/ar2/ar2_reload.wav")

-- 扩散为 0：发射完全精准
SWEP.ConeMax = 0
SWEP.ConeMin = 0

-- 持枪移动速度（最慢速度的 90%）
SWEP.WalkSpeed = SPEED_SLOWEST * 0.9

-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 场上同时存在的最大地雷数量
SWEP.MaxMines = 6

-- 强化词条：最大地雷数量 +1
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MAXIMUM_MINES, 1)
-- 强化分支（焚毁强化）：伤害降低为 22%，但地雷改为范围引爆
GAMEMODE:AddNewRemantleBranch(SWEP, 1, ""..translate.Get("weapon_zs_minelayer_r1"), ""..translate.Get("weapon_zs_minelayer_r1_description"), function(wept)
	-- 直接命中伤害降为原来的 22%
	wept.Primary.Damage = wept.Primary.Damage * 0.22
	if SERVER then
		-- 服务器端：为生成的地雷实体附加分支标记与爆炸范围
		wept.EntModify = function(self, ent)
			ent:SetDTBool(0, true)
			ent.Branch = true
			ent.Range = 64
		end
	end
end)

-- ==== CanPrimaryAttack - 判断是否允许发射地雷 ====
function SWEP:CanPrimaryAttack()
	if self.BaseClass.CanPrimaryAttack(self) then
		-- 统计场上属于自己且未过期的地雷数量
		local c = 0
		for _, ent in pairs(ents.FindByClass("projectile_impactmine")) do
			if (CLIENT or ent.CreateTime + 300 > CurTime()) and ent:GetOwner() == self:GetOwner() then
				c = c + 1
			end
		end

		-- 地雷数量达到上限时禁止继续放置
		if c >= self.MaxMines then return false end

		return true
	end

	return false
end

-- ==== CanSecondaryAttack - 判断是否允许回收地雷 ====
-- 正在搬运/放置路障或换弹时禁止右键
function SWEP:CanSecondaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() or self:GetReloadFinish() > 0 then return false end

	return self:GetNextSecondaryFire() <= CurTime()
end

-- ==== SecondaryAttack - 右键回收准星指向的地雷 ====
function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	-- 设置右键冷却
	self:SetNextSecondaryFire(CurTime() + 0.1)

	local owner = self:GetOwner()
	-- 沿准星做长距离射线检测，得到回收目标位置
	local hitpos = owner:CompensatedMeleeTrace(2048, 1, nil, nil, false).HitPos

	if SERVER then
		-- 查找目标位置附近属于主人的地雷
		for _, ent in pairs(ents.FindInSphere(hitpos, 24)) do
			if ent:GetClass() == "projectile_impactmine" and ent:GetOwner() == owner then
				-- 生成一个弹药箱来装回地雷
				local mine = ents.Create("prop_ammo")
				if mine:IsValid() then
					mine:SetAmmo(1)
					mine:SetAmmoType("impactmine")
					-- 弹药箱生成在地雷原始放置位置
					mine:SetPos(ent:GetStartPos())
					mine:SetAngles(ent:GetAngles())
					mine:Spawn()
				end

				-- 幸存者玩家：15 秒内只有自己能捡起该弹药箱
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

-- ==== EmitFireSound - 播放开火音效（随机高音调） ====
function SWEP:EmitFireSound()
	self:EmitSound(self.Primary.Sound, 60, math.random(137, 143), 0.5)
end

-- ==== EmitReloadSound - 播放换弹音效 ====
function SWEP:EmitReloadSound()
	if IsFirstTimePredicted() then
		self:EmitSound(self.ReloadSound, 60, 110, 0.5, CHAN_WEAPON + 21)
	end
end
