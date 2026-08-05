-- ============================================================================
-- weapon_zs_shade.lua - 阴影僵尸（Shade）专属武器
-- 负责：隔空抓取/投掷物理物体、生成岩石投射物，并调用僵尸类的渲染效果
-- ============================================================================
-- 注册该文件同时发送到客户端（CLIENT/SERVER 双端执行）
AddCSLuaFile()

-- 继承的僵尸武器基类
SWEP.Base = "weapon_zs_zombie"

-- 武器显示名称（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_shade")

-- 视图模型与世界模型文件
SWEP.ViewModel = Model("models/weapons/v_fza.mdl")
SWEP.WorldModel = Model("models/weapons/w_crowbar.mdl")

-- 客户端专属配置块
if CLIENT then
	-- 第一人称视野角度
	SWEP.ViewModelFOV = 70
end

-- 左键/右键均非自动（单次触发）
SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false
-- 变异（投掷）速度倍率
SWEP.MutationMultiplier = 6000
-- 控制实体类名（附着在被控物体上的可见标记）
SWEP.ShadeControl = "env_shadecontrol"
-- 投掷的岩石投射物类名
SWEP.ShadeProjectile = "projectile_shaderock"

-- ==== Initialize - 初始化：隐藏世界模型（纯第一人称外观） ====
function SWEP:Initialize()
	self:HideWorldModel()
end

-- ==== Think - 每帧逻辑（空实现） ====
function SWEP:Think()
end

-- ==== PrimaryAttack - 投掷被控制物体：默认沿瞄准方向抛出，强掷模式下沿视线强力投掷 ====
function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	-- 冷却中或已生成护盾时不可投掷
	if CurTime() <= self:GetNextPrimaryFire() or (owner.ShadeShield and owner.ShadeShield:IsValid()) then return end

	-- 查找属于本玩家的控制实体
	for _, ent in pairs(ents.FindByClass(self.ShadeControl)) do
		if ent:IsValid() and ent:GetOwner() == owner then
			local obj = ent:GetParent()
			if obj:IsValid() then
				-- 限制投掷频率并播发攻击事件
				self:SetNextSecondaryFire(CurTime() + 0.65)

				owner:DoAttackEvent()

				-- 客户端在此返回，实际投掷由服务端执行
				if CLIENT then return end
				

				-- 默认投掷速度：沿玩家瞄准方向
				local vel = owner:GetAimVector() * 1000
				
				-- 强掷模式：沿视线追踪终点方向，用变异倍率加速投掷
				if self.Owner.m_Shade_Force then
					vel = (self.Owner:TraceLine(10240, MASK_SOLID, owner).HitPos - obj:LocalToWorld(obj:OBBCenter())):GetNormalized() * self.MutationMultiplier
				end
				
				-- 唤醒物理对象并赋予速度（仅限可移动、质量 ≤300 的物体）
				local phys = obj:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() and phys:GetMass() <= 300 then
					phys:Wake()
					phys:SetVelocity(vel)
					obj:SetPhysicsAttacker(owner)
					phys:AddGameFlag(FVPHYSICS_WAS_THROWN)

					-- 播放投掷音效并记录投掷时间
					obj:EmitSound(")weapons/physcannon/superphys_launch"..math.random(4)..".wav")
					obj.LastShadeLaunch = CurTime()
				end
			end

			-- 移除控制实体（投掷后解除控制）
			ent:Remove()
		end
	end
end

-- ==== CanGrab - 判断能否抓取：冷却、护盾或已控制物体时禁止，并处理已有控制物 ====
function SWEP:CanGrab()
	local owner = self:GetOwner()
	-- 冷却中或已生成护盾时不可抓取
	if CurTime() <= self:GetNextSecondaryFire() or (owner.ShadeShield and owner.ShadeShield:IsValid()) then return end
	self:SetNextSecondaryFire(CurTime() + 0.1)

	-- 服务端：若已存在控制实体则移除并拒绝新抓取
	if SERVER then
		for _, ent in pairs(ents.FindByClass(self.ShadeControl)) do
			if ent:IsValid() and ent:GetOwner() == owner then
				ent:Remove()
				return
			end
		end
	end

	-- 允许抓取
	return true
end

-- ==== SecondaryAttack - 抓取前方的物理物体并生成控制实体 ====
function SWEP:SecondaryAttack()
	-- 抓取条件不满足则退出
	if not self:CanGrab() then return end

	local owner = self:GetOwner()
	-- 近战射线检测前方的物理物体
	local ent = owner:CompensatedMeleeTrace(400, 4).Entity
	if ent:IsValid() and (ent:IsPhysicsModel() or ent.IsShadeGrabbable or ent.IsPhysbox) then
		-- 设置左右键冷却
		self:SetNextPrimaryFire(CurTime() + 0.25)
		self:SetNextSecondaryFire(CurTime() + 0.4)

		if SERVER then
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() and phys:IsMoveable() and phys:GetMass() <= 300 then
			-- 若物体已被控制，先移除旧控制实体
			for _, ent2 in pairs(ents.FindByClass(self.ShadeControl)) do
				if ent2:IsValid() and ent2:GetParent() == ent then
					ent2:Remove()
					return
				end
			end

			-- 移除物体上的人类"持有"状态（防止冲突）
			for _, status in pairs(ents.FindByClass("status_human_holding")) do
				if status:IsValid() and status:GetObject() == ent then
					status:Remove()
				end
			end

			-- 创建控制实体并附着到目标物体上
			local con = ents.Create(self.ShadeControl)
			if con:IsValid() then
				con:Spawn()
				con:SetOwner(owner)
				con:AttachTo(ent)

				-- 播放抓取音效
				ent:EmitSound(")weapons/physcannon/physcannon_claws_close.wav")
			end
		end
		end
	end
end

-- ==== Reload - 远程攻击：生成一颗受控岩石投射物并向前抛出 ====
function SWEP:Reload()
	-- 抓取条件不满足则退出
	if not self:CanGrab() then return end

	local owner = self:GetOwner()

	-- 从眼睛位置向前做一小段船体检测（判断前方是否有阻挡）
	local vStart = owner:GetShootPos()
	local vEnd = vStart + owner:GetForward() * 40

	local tr = util.TraceHull({start=vStart, endpos=vEnd, filter=owner, mins=owner:OBBMins()/2, maxs=owner:OBBMaxs()/2})
	-- 设置左右键冷却
	self:SetNextPrimaryFire(CurTime() + 0.9)
	self:SetNextSecondaryFire(CurTime() + 0.9)

	if SERVER then
		-- 生成岩石投射物
		local rock = ents.Create(self.ShadeProjectile)
		if rock:IsValid() then
			-- 出生位置：玩家身后 5 单位；前方无阻挡时前移 30 单位
			local pos = owner:GetPos() - owner:GetForward() * 5
			if not tr.Hit then
				pos = pos + owner:GetForward() * 30
			end

			rock:SetPos(pos)
			rock:SetOwner(owner)
			rock:Spawn()
			-- 为岩石附着控制实体
			local con = ents.Create(self.ShadeControl)
			if con:IsValid() then
				con:Spawn()
				con:SetOwner(owner)
				con:AttachTo(rock)
				rock.Control = con

				-- 屏幕震动与生成音效
				util.ScreenShake(owner:GetPos(), 3, 1, 0.75, 400)

				con:EmitSound("physics/concrete/concrete_break3.wav", 85, 60)
				rock:EmitSound(")weapons/physcannon/physcannon_claws_close.wav")

				-- 记录本次远程攻击时间
				owner.LastRangedAttack = CurTime()
			end
		end
	end
end

-- ==== OnRemove - 武器移除时（空实现） ====
function SWEP:OnRemove()
end

-- ==== Holster - 收起武器时（空实现） ====
function SWEP:Holster()
end

-- 服务端到此为止，以下为客户端专属代码
if not CLIENT then return end

-- ==== PreDrawViewModel - 绘制视图模型前调用僵尸类的渲染前效果 ====
function SWEP:PreDrawViewModel(vm)
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:CallZombieFunction1("PreRenderEffects", vm)
	end
end

-- ==== PostDrawViewModel - 绘制视图模型后调用僵尸类的渲染后效果 ====
function SWEP:PostDrawViewModel(vm)
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:CallZombieFunction1("PostRenderEffects", vm)
	end
end
