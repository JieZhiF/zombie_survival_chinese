-- ============================================================================
-- weapon_zs_nailplacer - 钉子放置器（管理员工具）
-- 功能：
--   左键：打开模型选择界面
--   右键：钉钉子（距离 2000，冷却 0.2 秒）
--   R 键：短按拆一颗，长按 5 秒拆全图
--   中键：拾取准星模型
-- 参考：weapon_zs_sigilplacer（权限/Think 模式）、weapon_zs_hammer（钉钉逻辑）
-- ============================================================================

SWEP.PrintName = ""..translate.Get("weapon_zs_nailplacer")
SWEP.Description = ""..translate.Get("weapon_zs_nailplacer_description")
SWEP.Base = "weapon_zs_basemelee"
SWEP.UseMelee1 = true
SWEP.ViewModel = "models/weapons/v_hammer/c_hammer.mdl"
SWEP.WorldModel = "models/weapons/w_hammer.mdl"
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "dummy"
SWEP.DryFireSound = nil
SWEP.NailDistance = 2000
SWEP.NailCooldown = 0.2

SWEP.NoGlassWeapons = true
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture
SWEP.NoHolsterOnCarry = true
SWEP.NoPropThrowing = true

local placers = {
	["STEAM_0:0:1111"] = true,
	["STEAM_0:0:2222"] = true
}

function SWEP.CanUseNailPlacer(pl)
	return pl:IsValid() and (pl:IsAdmin() or placers[pl:SteamID()])
end

-- 左键：打开模型选择界面
-- 由服务端 PrimaryAttack 经 net 消息通知客户端打开，原因：
--   1. 客户端 PrimaryAttack 依赖预测系统，单人模式预测关闭，永远不会触发；
--   2. 服务端攻击钩子在单人/多人模式都会触发；
--   3. 引擎只在真实攻击输入时调用，切枪确认点击不会传到这里。
function SWEP:PrimaryAttack()
	if CLIENT then return end

	local owner = self:GetOwner()
	if not self.CanUseNailPlacer(owner) then return end

	self:SetNextPrimaryFire(CurTime() + 0.5)

	net.Start("zs_nailplacer_menu")
	net.Send(owner)
end

-- R 键：启动计时器（sigilplacer 同款模式）
function SWEP:Reload()
	local owner = self:GetOwner()
	if not self.CanUseNailPlacer(owner) then return end

	if CLIENT then return end

	if not self.StartReload then
		self.StartReload = CurTime()
		if not self.m_ShownNailTip then
			self.m_ShownNailTip = true
			owner:PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_chatprint")
		end
	end
end
-- 服务端 Think：长按 R 检测（sigilplacer 同款模式）
if SERVER then
function SWEP:Think()
	if not self.StartReload then return end

	local owner = self:GetOwner()

	-- 松开了 R：短按，拆最近一颗
	if not owner:KeyDown(IN_RELOAD) then
		self.StartReload = nil

		local tr = owner:TraceLine(self.NailDistance, MASK_SOLID, owner)
		local trent = tr.Entity
		if trent:IsValid() then
			local ent, best
			for _, e in pairs(ents.FindByClass("prop_nail")) do
				if not e.m_PryingOut and e:GetParent() == trent then
					local edist = e:GetActualPos():DistToSqr(tr.HitPos)
					if not best or edist < best then ent, best = e, edist end
				end
			end
			if ent then
				ent.m_PryingOut = true
				local parent = ent:GetParent()
				parent:RemoveNail(ent, nil, owner)
				parent:SetPhysicsAttacker(owner)
				self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
				self.Alternate = not self.Alternate
				owner:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".ogg")
				-- 无条件强制清理
				parent:SetMaxBarricadeHealth(0)
				parent:SetBarricadeHealth(0)
				parent:SetBarricadeRepairs(0)
				parent:SetNailFrozen(false)
				parent:SetMoveType(MOVETYPE_VPHYSICS)
				parent._BARRICADEBROKEN = nil
				parent._PROPBROKEN = nil
				parent.IsBarricadeObject = nil
				parent:SetHealth(1)
				parent:SetMaxHealth(1)
				local health = parent:GetDefaultBarricadeHealth()
				parent.PropHealth = health
				parent.TotalHealth = health
				local phy = parent:GetPhysicsObject()
				if phy and phy:IsValid() then phy:EnableMotion(true) phy:Wake() end
				parent:CollisionRulesChanged()
			end
		end
		return
	end

	-- 长按 5 秒：拆除全地图所有钉子
	if CurTime() >= self.StartReload + 5 then
		self.StartReload = nil

		local parents = {}
		local total = 0

		for _, nail in ipairs(ents.FindByClass("prop_nail")) do
			total = total + 1

			local parent = nail:GetParent()

			if IsValid(parent) then
				parents[parent:EntIndex()] = parent
			end
		end

		local removed = 0

		local function RestoreParent(parent)
			if not IsValid(parent) then return end

			parent:SetMaxBarricadeHealth(0)
			parent:SetBarricadeHealth(0)
			parent:SetBarricadeRepairs(0)
			parent:SetNailFrozen(false)

			parent:SetMoveType(MOVETYPE_VPHYSICS)

			parent._BARRICADEBROKEN = nil
			parent._PROPBROKEN = nil
			parent.IsBarricadeObject = nil

			parent:SetHealth(1)
			parent:SetMaxHealth(1)

			local health = parent:GetDefaultBarricadeHealth()

			parent.PropHealth = health
			parent.TotalHealth = health


			local phy = parent:GetPhysicsObject()

			if IsValid(phy) then
				phy:EnableMotion(true)
				phy:Wake()
			end

			parent:CollisionRulesChanged()
		end



		local function RemoveNextNail(parent, callback)

			local nail = parent:GetFirstNail()

			if not IsValid(nail) then
				callback()
				return
			end

			nail.m_PryingOut = true

			if parent:RemoveNail(nail, nil, owner) then
				removed = removed + 1
			end

			-- 等待 RemoveNail 完成
			timer.Simple(0.05, function() RemoveNextNail (parent, callback) end)
		end
		local list = {}

		for _, parent in pairs(parents) do
			table.insert(list, parent)
		end

		local index = 1
		local function RemoveNextParent()

			local parent = list[index]

			if not parent then

				owner:PrintTranslatedMessage(HUD_PRINTTALK, "nailplacer_removed_all", total, removed)
				return
			end

			index = index + 1
			if not IsValid(parent) then
				timer.Simple(0.02, RemoveNextParent)
				return
			end

			RemoveNextNail(parent, function()
				-- 等 OnNailRemoved / EvaluatePropFreeze 完成
				timer.Simple(0.08, function()
					-- 清理残留约束
					for _, c in ipairs(constraint.FindConstraints(parent,"Weld")) do
						if IsValid(c.Constraint) then
							c.Constraint:Remove()
						end
					end
					RestoreParent(parent)


					-- 下一个实体
					timer.Simple(0.02, RemoveNextParent)


				end)

			end)

		end



		-- 只启动一次
		timer.Simple(0.02, RemoveNextParent)

	end
end
end -- if SERVER
