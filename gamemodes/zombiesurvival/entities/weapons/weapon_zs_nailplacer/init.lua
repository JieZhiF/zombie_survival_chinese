-- ============================================================================
-- weapon_zs_nailplacer - 服务器端
-- 功能：
--   SecondaryAttack  - 钉钉子（参考 weapon_zs_hammer，距离 2000，冷却 0.2 秒）
--   Reload           - 启动拆钉计时器（实际拆钉在 shared.lua 的 SWEP:Think 中）
--   net "zs_nailplacer_spawn" - 根据客户端选择在准星位置生成 prop_physics
--                                （含缩放/颜色，其余参数与 sv_nailsave.lua 一致）
--   concommand "zs_nailplacer" - 给予本武器
-- ============================================================================
INC_SERVER()

local math_random = math.random
local CurTime = CurTime

-- 拆钉用的独立冷却计时字段
-- self.m_NextUnnail

-- 播放钉钉动画与音效
local function DoNailEffects(self, owner, pos)
	self:SendWeaponAnim(self.Alternate and ACT_VM_HITCENTER or ACT_VM_MISSCENTER)
	self.Alternate = not self.Alternate

	owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetMagnitude(1)
	util.Effect("nailrepaired", effectdata, true, true)
end

-- 检查一个实体是否可作为钉子的一端（参考 hammer 的校验集合）
local function IsValidNailTarget(ent, physbone)
	if not ent:IsValid()
	or not util.IsValidPhysicsObject(ent, physbone)
	or ent:GetMoveType() ~= MOVETYPE_VPHYSICS and not ent:GetNailFrozen()
	or ent.NoNails
	or ent:IsProjectile()
	or ent:IsNailed() and (#ent.Nails >= GAMEMODE.MaxNails or ent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade)
	or ent.PreHoldCollisionGroup and (ent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS or ent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS_TRIGGER or ent.PreHoldCollisionGroup == COLLISION_GROUP_INTERACTIVE_DEBRIS)
	or not ent:IsNailed() and not ent:GetPhysicsObject():IsMoveable() then
		return false
	end

	return true
end

-- 材质检查，返回 true 表示该材质不能钉钉
local function BadNailMaterial(owner, mattype)
	if mattype == MAT_GRATE or mattype == MAT_CLIP then
		owner:PrintTranslatedMessage(HUD_PRINTCENTER, "impossible")
		return true
	end
	if mattype == MAT_GLASS then
		owner:PrintTranslatedMessage(HUD_PRINTCENTER, "trying_to_put_nails_in_glass")
		return true
	end

	return false
end

-- 次要攻击（右键）：钉钉子
function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then return end
	local owner = self:GetOwner()	
	if not self.CanUseNailPlacer(owner) then return end
	if owner:GetBarricadeGhosting() then return end

	-- 长距离射线（sigilplacer 已验证，比 TraceHull 在高距更可靠）
	local tr = owner:TraceLine(self.NailDistance, MASK_SOLID, owner)
	local trent = tr.Entity
	if tr.Fraction == 0 then return end
	if not IsValidNailTarget(trent, tr.PhysicsBone) then return end

	if not gamemode.Call("CanPlaceNail", owner, tr) then return end

	if BadNailMaterial(owner, tr.MatType) then return end

	-- 钉子之间不能离得太近（只检查目标物体上已附着的钉子，避免全图扫描）
	for _, nail in pairs(trent:GetChildren()) do
		if nail:GetClass() == "prop_nail" and nail:GetActualPos():DistToSqr(tr.HitPos) <= 81 then
			owner:PrintTranslatedMessage(HUD_PRINTCENTER, "too_close_to_another_nail")
			return
		end
	end

	if trent:GetBarricadeHealth() <= 0 and trent:GetMaxBarricadeHealth() > 0 then
		owner:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
		return
	end

	-- 特殊情况：不允许钉无人机拖运中的物体
	local ropeconstraint = constraint.FindConstraint(trent, "Rope")
	if ropeconstraint then
		if ropeconstraint.Ent1 and ropeconstraint.Ent1:IsValid() and ropeconstraint.Ent1:GetClass() == "prop_drone" then return end
		if ropeconstraint.Ent2 and ropeconstraint.Ent2:IsValid() and ropeconstraint.Ent2:GetClass() == "prop_drone" then return end
	end

	-- 沿瞄准方向再探测 24 单位，寻找钉子的另一端（地图或另一个实体）
	local aimvec = owner:GetAimVector()
	local trtwo = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + aimvec * 24, filter = table.Add({owner, trent}, GAMEMODE.CachedInvisibleEntities), mask = MASK_SOLID})

	if trtwo.HitSky then return end

	local ent = trtwo.Entity
	if not (trtwo.HitWorld or IsValidNailTarget(ent, trtwo.PhysicsBone)) then return end

	if BadNailMaterial(owner, trtwo.MatType) then return end

	if ent and ent:IsValid() then
		if ent:GetBarricadeHealth() <= 0 and ent:GetMaxBarricadeHealth() > 0 then
			owner:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
			return
		end

		if GAMEMODE:EntityWouldBlockSpawn(ent) then return end
	end

	-- 与 hammer 一致：先焊接再挂钉子
	local cons = constraint.Weld(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone, 0, true)
	if cons ~= nil then
		for _, oldcons in pairs(constraint.FindConstraints(trent, "Weld")) do
			if oldcons.Ent1 == ent or oldcons.Ent2 == ent then
				cons = oldcons.Constraint
				break
			end
		end
	end

	if not cons then return end

	DoNailEffects(self, owner, tr.HitPos)
	self:SetNextPrimaryFire(CurTime() + self.NailCooldown)
	local nail = ents.Create("prop_nail")
	if nail:IsValid() then
		nail:SetActualOffset(tr.HitPos, trent)
		nail:SetPos(tr.HitPos - aimvec * 8)
		nail:SetAngles(aimvec:Angle())
		nail:AttachTo(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone)
		nail:Spawn()
		nail:SetDeployer(owner)

		cons:DeleteOnRemove(nail)

		gamemode.Call("OnNailCreated", trent, ent, nail)

		nail:EmitSound(string.format("weapons/melee/crowbar/crowbar_hit-%d.ogg", math_random(4)))
	end
end

-- 客户端请求生成模型
util.AddNetworkString("zs_nailplacer_spawn")
util.AddNetworkString("zs_nailplacer_menu")
util.AddNetworkString("zs_nailplacer_modelcheck")
util.AddNetworkString("zs_nailplacer_badmodel")

net.Receive("zs_nailplacer_spawn", function(len, ply)
	-- 必须正手持本武器，防止绕过工具直接发包的滥用
	local wep = ply:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_zs_nailplacer" then return end

	-- 与武器统一的权限判定（管理员或白名单）
	if not wep.CanUseNailPlacer(ply) then return end

	-- 生成频率限制
	if CurTime() < (ply.m_NextNailPlacerSpawn or 0) then return end
	ply.m_NextNailPlacerSpawn = CurTime() + 0.1

	local model = net.ReadString()
	local pos = net.ReadVector()
	local ang = net.ReadAngle()
	local scale = net.ReadFloat()
	local col = net.ReadColor()
	local level = math.Clamp(net.ReadUInt(8), 1, 5) -- 防线等级（客户端当前生成等级）

	-- 管理员的本地通常有大量服务器没有的模型：拦截并回包提醒
	if not file.Exists(model, "GAME") or not util.IsValidModel(model) then
		net.Start("zs_nailplacer_badmodel")
			net.WriteString(model)
		net.Send(ply)
		return
	end

	-- 位置合理性：不允许在钉钉距离之外生成
	if pos:DistToSqr(ply:GetShootPos()) > (2000 + 64) ^ 2 then return end

	-- 强制直立生成，保证物理稳定
	ang = Angle(0, ang.y, 0)

	-- 缩放与颜色的合法范围
	scale = math.Clamp(scale or 1, 0.05, 10)
	col = col or Color(255, 255, 255)

	-- 缩放在 Spawn 之前应用，否则物理碰撞盒不会随模型缩放
	local prop = ents.Create("prop_physics")
	if not IsValid(prop) then return end
	prop:SetModel(model)
	if scale ~= 1 then prop:SetModelScale(scale, 0) end
	prop:SetPos(pos)
	prop:SetAngles(ang)
	prop.NoNails = false
	prop.NoVolumeCarryCheck = true
	prop.NailPlacerSpawned = true
	prop.NailPlacerLevel = level
	prop:Spawn()
	prop.ExpertProtection = nil
	prop:Activate()
	prop:SetColor(Color(col.r, col.g, col.b, col.a))
	if col.a < 255 then prop:SetRenderMode(RENDERMODE_TRANSALPHA) end

	-- 基于质量/体积计算合理血量（与 GetDefaultBarricadeHealth 同公式）
	local health = prop:GetDefaultBarricadeHealth()
	prop.PropHealth = health
	prop.TotalHealth = health
end)

-- 模型存在性查询：mode 0 = 目录（返回服务器上该目录的 .mdl 列表），mode 1 = 单个模型
-- 用于客户端把浏览器/预览对齐到服务器真实内容，避免生成服务器没有的模型
net.Receive("zs_nailplacer_modelcheck", function(len, ply)
	-- 与生成相同的闸门：必须正手持本武器且有权限
	local wep = ply:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_zs_nailplacer" then return end
	if not wep.CanUseNailPlacer(ply) then return end

	-- 频率限制
	if CurTime() < (ply.m_NextNailPlacerCheck or 0) then return end
	ply.m_NextNailPlacerCheck = CurTime() + 0.1

	local mode = net.ReadUInt(8)

	if mode == 0 then
		-- 目录查询：限制路径形态，防止遍历
		local folder = net.ReadString()
		if #folder > 200 or folder:find("%.%.") then return end
		folder = string.Trim(folder, "/")
		if folder ~= "models" and not string.StartWith(folder, "models/") then return end

		local files = file.Find(folder.."/*.mdl", "GAME")
		table.sort(files)

		local count = math.min(#files, 600)
		net.Start("zs_nailplacer_modelcheck")
			net.WriteUInt(0, 8)
			net.WriteString(folder)
			net.WriteUInt(count, 16)
			for i = 1, count do
				net.WriteString(files[i])
			end
		net.Send(ply)
	else
		-- 单模型查询
		local model = net.ReadString()
		if #model > 260 then return end

		local exists = file.Exists(model, "GAME") and util.IsValidModel(model)

		net.Start("zs_nailplacer_modelcheck")
			net.WriteUInt(1, 8)
			net.WriteString(model)
			net.WriteBool(exists)
		net.Send(ply)
	end
end)

-- 控制台命令：获取本武器（与武器统一的权限判定）
concommand.Add("zs_nailplacer", function(sender)
	local weptbl = weapons.Get("weapon_zs_nailplacer")
	if sender:IsValid() and weptbl and weptbl.CanUseNailPlacer(sender) then
		sender:Give("weapon_zs_nailplacer")
		sender:SelectWeapon("weapon_zs_nailplacer")
	end
end)

-- 将准星道具设为指定防线等级（等级配置分页的"设置准星道具"按钮）
util.AddNetworkString("zs_nailplacer_setlevel")

net.Receive("zs_nailplacer_setlevel", function(len, ply)
	-- 与生成相同的闸门：必须正手持本武器且有权限
	local wep = ply:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() ~= "weapon_zs_nailplacer" then return end
	if not wep.CanUseNailPlacer(ply) then return end

	local level = math.Clamp(net.ReadUInt(8), 1, 5)

	local tr = ply:TraceLine(2000, MASK_SOLID, ply)
	local ent = tr.Entity
	if not (IsValid(ent) and ent:GetClass() == "prop_physics") then
		ply:PrintTranslatedMessage(HUD_PRINTCENTER, "nailplacer_level_no_target")
		return
	end

	ent.NailPlacerLevel = level
	ply:PrintTranslatedMessage(HUD_PRINTCENTER, "nailplacer_level_applied", level)
end)
