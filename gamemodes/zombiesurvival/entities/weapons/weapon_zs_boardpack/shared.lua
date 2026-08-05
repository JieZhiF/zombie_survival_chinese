-- ============================================================================
-- shared.lua - 木板背包武器共享定义
-- 负责：定义"便携木板"属性——左键在面前放置随机废料木板实体并消耗储备，
--       携带木板时降低移动速度；通过 DT 变量向客户端同步剩余木板数
-- ============================================================================
-- 继承自近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 武器显示名称与描述（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_boardpack")
SWEP.Description = ""..translate.Get("weapon_zs_boardpack_description")

-- 第一人称/第三人称模型（借用护盾套件与木板模型）
SWEP.ViewModel = "models/weapons/c_aegiskit.mdl"
SWEP.WorldModel = "models/props_debris/wood_board06a.mdl"
-- 使用玩家手部模型
SWEP.UseHands = true

-- 持有该武器时获得相应弹药；允许空弹药持有
SWEP.AmmoIfHas = true
SWEP.AllowEmpty = true

-- 主攻击：弹匣 1 发、半自动、消耗狙击弹药（代表木板储备）
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "SniperRound"
SWEP.Primary.Delay = 1
SWEP.Primary.DefaultClip = 4

-- 副攻击：占位配置（实际无功能）
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Ammo = "dummy"
SWEP.Secondary.Automatic = true
SWEP.Secondary.Delay = 0.15

-- 持枪移动速度（正常速度）；携带木板时降至最慢速度
SWEP.WalkSpeed = SPEED_NORMAL
SWEP.FullWalkSpeed = SPEED_SLOWEST
-- 场上最大持有数量
SWEP.MaxStock = 8
-- 可随机放置的废料木板/家具模型列表
SWEP.JunkModels = {
	Model("models/props_debris/wood_board04a.mdl"),
	Model("models/props_debris/wood_board06a.mdl"),
	Model("models/props_debris/wood_board02a.mdl"),
	Model("models/props_debris/wood_board01a.mdl"),
	Model("models/props_debris/wood_board07a.mdl"),
	Model("models/props_c17/furnituredrawer002a.mdl"),
	Model("models/props_c17/furnituredrawer003a.mdl"),
	Model("models/props_c17/furnituredrawer001a_chunk01.mdl"),
	Model("models/props_c17/furniturechair001a_chunk01.mdl"),
	Model("models/props_c17/furnituredrawer001a_chunk02.mdl"),
	Model("models/props_c17/furnituretable003a.mdl"),
	Model("models/props_c17/furniturechair001a.mdl")
}

-- 持枪姿势（物理枪式）
SWEP.HoldType = "physgun"

-- ==== SetReplicatedAmmo - 将木板数写入网络同步变量（DT 0 号位） ====
function SWEP:SetReplicatedAmmo(count)
	self:SetDTInt(0, count)
end

-- ==== GetReplicatedAmmo - 读取网络同步的木板数 ====
function SWEP:GetReplicatedAmmo()
	return self:GetDTInt(0)
end

-- ==== GetWalkSpeed - 根据剩余木板数返回移动速度 ====
-- 仍有木板储备时移动速度降为最慢（负重效果）
function SWEP:GetWalkSpeed()
	if self:GetPrimaryAmmoCount() > 0 then
		return self.FullWalkSpeed
	end
end

-- ==== PrimaryAttack - 左键放置一块废料木板 ====
-- 朝面前 32 单位处放置随机木板/家具实体（生命 350、限时归属），并消耗 1 块储备
function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	-- 从射击位置沿视线方向做 32 单位射线，取放置点
	local aimvec = self:GetOwner():GetAimVector()
	local shootpos = self:GetOwner():GetShootPos()
	local tr = util.TraceLine({start = shootpos, endpos = shootpos + aimvec * 32, filter = self:GetOwner()})

	self:SetNextPrimaryAttack(CurTime() + self.Primary.Delay)

	-- 播放挥舞音效与攻击动画
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(75, 80))

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.IdleAnimation = CurTime() + math.min(self.Primary.Delay, self:SequenceDuration())

	if SERVER then
		-- 播放近战手势并生成物理木板实体
		self:GetOwner():RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			-- 随机选一种废料模型，放置在射线命中点并竖直朝向
			local ang = aimvec:Angle()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ent:SetPos(tr.HitPos)
			ent:SetAngles(ang)
			ent:SetModel(self.JunkModels[math.random(#self.JunkModels)])
			ent:Spawn()
			-- 木板生命 350；限时禁止搬运归属（15 秒内仅本人可搬运）
			ent:SetHealth(350)
			ent.NoVolumeCarryCheck = true
			ent.NoDisTime = CurTime() + 15
			ent.NoDisOwner = self:GetOwner()
			-- 限制质量并继承玩家速度
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMass(math.min(phys:GetMass(), 50))
				phys:SetVelocityInstantaneous(self:GetOwner():GetVelocity())
			end
			ent:SetPhysicsAttacker(self:GetOwner())
			-- 消耗 1 块木板储备
			self:TakePrimaryAmmo(1)
		end
	end
end

-- ==== SecondaryAttack - 右键（无功能占位） ====
function SWEP:SecondaryAttack()
end

-- ==== Reload - 换弹（无功能占位，木板由商店补充） ====
function SWEP:Reload()
end

-- ==== CanPrimaryAttack - 检查放置木板是否可用 ====
-- 手持道具、建造预览中、垂直下落过快（防止空中放置）或木板耗尽时禁止
function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsHolding() or self:GetOwner():GetBarricadeGhosting() then return false end

	-- 垂直速度过快（下落/腾空）时禁止放置
	if math.abs(self:GetOwner():GetVelocity().z) >= 256 then return false end

	-- 木板耗尽：进入冷却并拒绝本次放置
	if self:GetPrimaryAmmoCount() <= 0 then
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		return false
	end

	return true
end

-- ==== Think - 每帧逻辑：闲置动画与木板数网络同步 ====
function SWEP:Think()
	-- 攻击动画结束后回到闲置动画
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	if SERVER then
		-- 木板数变化时同步到客户端并重算移动速度
		local count = self:GetPrimaryAmmoCount()
		if count ~= self:GetReplicatedAmmo() then
			self:SetReplicatedAmmo(count)
			self:GetOwner():ResetSpeed()
		end
	end
end
