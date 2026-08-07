-- 本文件为共享脚本(shared)，定义了在服务器和客户端之间通用的Player（玩家）扩展功能。它包含了玩家动画事件、状态获取、伤害计算（如腿部/手臂伤害）、移动速度控制、碰撞规则、自定义追踪函数以及与游戏特定机制（如僵尸职业、补给、传送）相关的核心逻辑。

-- meta:LogID 返回一个包含玩家SteamID和名字的格式化字符串，用于日志记录。
-- meta:GetMaxHealthEx 获取玩家的最大生命值，会根据玩家是人类还是僵尸返回不同的值。
-- meta:Dismember 触发一个肢解的视觉效果。
-- meta:DoRandomEvent 触发一个带有随机参数的自定义玩家动画事件。
-- meta:DoZombieEvent 触发一个随机的僵尸主攻击动画事件。
-- meta:DoFlinchEvent 根据被击中的部位触发一个特定的 움찔(flinch) 动画事件。
-- meta:DoRandomFlinchEvent 触发一个完全随机的 움찔(flinch) 动画事件。
-- meta:SetTokens 设置玩家的代币数量（网络同步变量）。
-- meta:GetTokens 获取玩家的代币数量（网络同步变量）。
-- meta:DoFlinchAnim 根据索引播放一个预定义的 움찔(flinch) 动画序列。
-- meta:DoZombieAttackAnim 根据索引播放一个预定义的僵尸攻击动画序列。
-- meta:IsSpectator 检查玩家是否为观察者。
-- meta:GetAuraRange 获取玩家当前武器的光环效果范围。
-- meta:GetAuraRangeSqr 获取玩家光环效果范围的平方值，用于距离比较。
-- meta:GetPoisonDamage 获取玩家当前中毒状态造成的伤害值。
-- meta:GetBleedDamage 获取玩家当前流血状态造成的伤害值。
-- meta:CallWeaponFunction 调用玩家当前持有武器上的一个指定函数。
-- meta:ClippedName 返回一个被截断（最长16个字符）的玩家名字。
-- meta:SigilTeleportDestination 决定玩家在使用印记传送时的最佳目标位置。
-- meta:DispatchAltUse 处理玩家的"交替使用"输入，通常用于与环境物体交互。
-- meta:MeleeViewPunch 根据近战伤害对玩家视角产生一个晃动效果。
-- meta:NearArsenalCrate 检查玩家是否在军火箱或印记附近。
-- meta:IsNearArsenalCrate meta:NearArsenalCrate 的别名。
-- meta:NearRemantler 检查玩家是否在"拆解台"(Remantler)附近。
-- meta:GetResupplyAmmoType 获取玩家当前应该从补给中获得的弹药类型。
-- meta:SetZombieClassName 通过职业名称字符串来设置玩家的僵尸职业。
-- meta:GetPoints 获取玩家的点数。
-- meta:GetBloodArmor 获取玩家的血甲值。
-- meta:AddLegDamage 增加玩家的腿部伤害，这通常会影响移动速度。
-- meta:AddLegDamageExt 根据特定类型（如脉冲、冰冻）增加额外的腿部伤害，并可能触发特殊效果。
-- meta:SetLegDamage 设置一个原始的腿部伤害值。
-- meta:RawSetLegDamage 直接设置腿部伤害的到期时间。
-- meta:RawCapLegDamage 设置腿部伤害到期时间，但不低于当前值。
-- meta:GetLegDamage 获取当前腿部伤害的剩余时间。
-- meta:GetFlatLegDamage 将腿部伤害的剩余时间转换为一个固定的数值。
-- meta:AddArmDamage 增加玩家的手臂伤害，这通常会影响攻击速度。
-- meta:SetArmDamage 设置一个原始的手臂伤害值。
-- meta:RawSetArmDamage 直接设置手臂伤害的到期时间。
-- meta:RawCapArmDamage 设置手臂伤害到期时间，但不低于当前值。
-- meta:GetArmDamage 获取当前手臂伤害的剩余时间。
-- meta:GetFlatArmDamage 将手臂伤害的剩余时间转换为一个固定的数值。
-- meta:Flinch 在冷却时间结束后，触发一次 움찔(flinch) 动画。
-- meta:GetZombieClass 获取玩家当前的僵尸职业索引。
-- meta:GetZombieClassTable 获取玩家当前僵尸职业的属性表。
-- meta:CallZombieFunction0-5 一系列经过优化的函数，用于调用当前僵尸职业属性表中的函数，并传递0到5个参数。
-- meta:TraceLine 从玩家的射击位置发出一条射线检测。
-- meta:TraceHull 从玩家的射击位置发出一个带有体积的射线检测。
-- meta:SetSpeed 设置玩家的行走、奔跑和最大速度。
-- meta:SetHumanSpeed 如果玩家是人类，则设置其速度。
-- meta:ResetSpeed 根据玩家的队伍、武器、技能和生命值等状态，重新计算并设置其移动速度。
-- meta:ResetJumpPower 根据玩家状态重新计算并设置其跳跃力。
-- meta:SetBarricadeGhosting 设置玩家是否可以穿透障碍物（"幽灵"状态）。
-- meta:GetBarricadeGhosting 获取玩家是否处于穿透障碍物的状态。
-- meta:IsBarricadeGhosting meta:GetBarricadeGhosting 的别名。
-- meta:ShouldBarricadeGhostWith 判断玩家是否应该穿透给定的实体。
-- meta:BarricadeGhostingThink 处理"幽灵"状态下的逻辑，例如在特定条件下自动取消该状态。
-- meta:ShouldNotCollide 决定本玩家是否应该与另一个实体发生碰撞的核心函数。
-- meta:SetHealth 重写设置生命值的函数，以便在生命值改变时更新移动速度。
-- meta:IsHeadcrab 检查玩家是否为头蟹类型的僵尸。
-- meta:IsTorso 检查玩家是否为躯干类型的僵尸。
-- meta:AirBrake 在空中急剧减速。
-- meta:MeleeTrace 执行一次近战攻击的射线检测。
-- meta:CompensatedMeleeTrace 执行一次经过延迟补偿的近战攻击射线检测。
-- meta:CompensatedPenetratingMeleeTrace 执行一次可穿透多个目标的、经过延迟补偿的近战射线检测。
-- meta:CompensatedZombieMeleeTrace 专为僵尸设计的、经过延迟补偿的组合近战射线检测。
-- meta:PenetratingMeleeTrace 执行一次可穿透多个目标的近战射线检测。
-- meta:ActiveBarricadeGhosting 检查玩家当前是否正处于障碍物内部并且启用了"幽灵"状态。
-- meta:IsHolding 检查玩家是否正持有（搬运）一个物体。
-- meta:IsCarrying meta:IsHolding 的别名。
-- meta:GetHolding 获取玩家当前持有（搬运）的物体。
-- meta:NearestRemantler 寻找离玩家最近的"拆解台"(Remantler)。
-- meta:GetMaxZombieHealth 获取玩家作为僵尸时的最大生命值。
-- meta:GetMaxHealth 重写获取最大生命值的函数，以区分人类和僵尸状态。
-- meta:Alive 重写存活判断函数，加入观察者模式和自定义状态的检查。
-- meta:SyncAngles 同步并返回玩家的水平朝向角度。
-- meta:GetAngles meta:SyncAngles 的别名。
-- meta:GetForward 获取玩家的水平前向向量。
-- meta:GetUp 获取玩家的水平上向向量。
-- meta:GetRight 获取玩家的水平右向向量。
-- meta:GetZombieMeleeSpeedMul 获取僵尸的近战攻击速度加成。
-- meta:GetMeleeSpeedMul 获取玩家（人类或僵尸）的近战攻击速度加成。
-- meta:GetPhantomHealth 获取玩家的幻影生命值。

-- 获取玩家（Player）的元表，用于扩展玩家共享功能
local meta = FindMetaTable("Player")

-- 缓存常用的全局变量和函数，以提高性能
local util_SharedRandom = util.SharedRandom
local PLAYERANIMEVENT_FLINCH_HEAD = PLAYERANIMEVENT_FLINCH_HEAD
local PLAYERANIMEVENT_ATTACK_PRIMARY = PLAYERANIMEVENT_ATTACK_PRIMARY
local GESTURE_SLOT_FLINCH = GESTURE_SLOT_FLINCH
local GESTURE_SLOT_ATTACK_AND_RELOAD = GESTURE_SLOT_ATTACK_AND_RELOAD
local HITGROUP_HEAD = HITGROUP_HEAD
local HITGROUP_CHEST = HITGROUP_CHEST
local HITGROUP_STOMACH = HITGROUP_STOMACH
local HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
local HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
local HITGROUP_LEFTARM = HITGROUP_LEFTARM
local HITGROUP_RIGHTARM = HITGROUP_RIGHTARM
local TEAM_UNDEAD = TEAM_UNDEAD
local TEAM_SPECTATOR = TEAM_SPECTATOR
local TEAM_HUMAN = TEAM_HUMAN
local IN_ZOOM = IN_ZOOM
local MASK_SOLID = MASK_SOLID
local MASK_SOLID_BRUSHONLY = MASK_SOLID_BRUSHONLY
local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull

local getmetatable = getmetatable

-- 缓存Entity元表的方法
local M_Entity = FindMetaTable("Entity")

-- 缓存Player元表的Team方法
local P_Team = meta.Team

-- 缓存Entity元表的方法以提高性能
local E_IsValid = M_Entity.IsValid
local E_GetDTBool = M_Entity.GetDTBool
local E_GetTable = M_Entity.GetTable

-- 返回包含玩家SteamID和名字的格式化字符串，用于日志记录
function meta:LogID()
	return "<"..self:SteamID().."> "..self:Name()
end

-- 获取玩家的最大生命值
-- 根据队伍（僵尸/人类）返回不同的值
function meta:GetMaxHealthEx()
	if P_Team(self) == TEAM_UNDEAD then
		return self:GetMaxZombieHealth()
	end

	return self:GetMaxHealth()
end

-- 触发一个肢解的视觉效果
-- dismembermenttype参数指定肢解类型
function meta:Dismember(dismembermenttype)
	local effectdata = EffectData()
		effectdata:SetOrigin(self:EyePos())
		effectdata:SetEntity(self)
		effectdata:SetScale(dismembermenttype)
	util.Effect("dismemberment", effectdata, true, true)
end

-- 触发一个带有随机参数的自定义玩家动画事件
-- maxrandom_s1指定随机范围
function meta:DoRandomEvent(event, maxrandom_s1)
	self:DoCustomAnimEvent(event, math.ceil(util_SharedRandom("anim", 0, maxrandom_s1, self:EntIndex())))
end

-- 触发一个随机的僵尸主攻击动画事件
function meta:DoZombieEvent()
	self:DoRandomEvent(PLAYERANIMEVENT_ATTACK_PRIMARY, 7)
end

-- 根据被击中的部位触发特定的flinching动画事件
-- 不同部位对应不同的动画序列
function meta:DoFlinchEvent(hitgroup)
	local base = util_SharedRandom("flinch", 1, self:EntIndex())
	if hitgroup == HITGROUP_HEAD then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base * 2 + 4)
	elseif hitgroup == HITGROUP_CHEST  then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base * 2 + 1)
	elseif hitgroup == HITGROUP_STOMACH then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base * 2 + 10)
	elseif hitgroup == HITGROUP_LEFTARM then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base + 8)
	elseif hitgroup == HITGROUP_RIGHTARM then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base + 9)
	elseif hitgroup == HITGROUP_LEFTLEG then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base + 6)
	elseif hitgroup == HITGROUP_RIGHTLEG then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base + 7)
	elseif hitgroup == HITGROUP_BELT then
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base + 3)
	else
		self:DoCustomAnimEvent(PLAYERANIMEVENT_FLINCH_HEAD, base * 2)
	end
end

-- 触发一个完全随机的flinching动画事件
function meta:DoRandomFlinchEvent()
	self:DoRandomEvent(PLAYERANIMEVENT_FLINCH_HEAD, 12)
end

-- 设置玩家的代币数量
function meta:SetTokens(pts)
	self:SetNWInt('btokens', pts)	
end	

-- 获取玩家的代币数量
function meta:GetTokens()
	return self:GetNWInt('btokens', 0)
end

-- 预定义的flinching动画序列名称表
local FlinchSequences = {
	"flinch_01",
	"flinch_02",
	"flinch_back_01",
	"flinch_head_01",
	"flinch_head_02",
	"flinch_phys_01",
	"flinch_phys_02",
	"flinch_shoulder_l",
	"flinch_shoulder_r",
	"flinch_stomach_01",
	"flinch_stomach_02",
}

-- 根据索引播放一个预定义的flinching动画序列
function meta:DoFlinchAnim(data)
	local seq = FlinchSequences[data] or FlinchSequences[1]
	if seq then
		local seqid = self:LookupSequence(seq)
		if seqid > 0 then
			self:AddVCDSequenceToGestureSlot(GESTURE_SLOT_FLINCH, seqid, 0, true)
		end
	end
end

-- 预定义的僵尸攻击动画序列名称表
local ZombieAttackSequences = {
	"zombie_attack_01",
	"zombie_attack_02",
	"zombie_attack_03",
	"zombie_attack_04",
	"zombie_attack_05",
	"zombie_attack_06"
}

-- 根据索引播放一个预定义的僵尸攻击动画序列
function meta:DoZombieAttackAnim(data)
	local seq = ZombieAttackSequences[data] or ZombieAttackSequences[1]
	if seq then
		local seqid = self:LookupSequence(seq)
		if seqid > 0 then
			self:AddVCDSequenceToGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD, seqid, 0, true)
		end
	end
end

-- 检查玩家是否为观察者
function meta:IsSpectator()
	return P_Team(self) == TEAM_SPECTATOR
end

-- 获取玩家当前武器的光环效果范围
-- 在僵尸逃生模式下返回一个很大的值（8192）
function meta:GetAuraRange()
	if GAMEMODE.ZombieEscape then
		return 8192
	end

	local wep = self:GetActiveWeapon()
	return wep:IsValid() and wep.GetAuraRange and wep:GetAuraRange() or 2048
end

-- 获取玩家光环效果范围的平方值，用于距离比较（避免开平方）
function meta:GetAuraRangeSqr()
	local r = self:GetAuraRange()
	return r * r
end

-- 获取玩家当前中毒状态造成的伤害值
function meta:GetPoisonDamage()
	return self.Poison and self.Poison:IsValid() and self.Poison:GetDamage() or 0
end

-- 获取玩家当前流血状态造成的伤害值
function meta:GetBleedDamage()
	return self.Bleed and self.Bleed:IsValid() and self.Bleed:GetDamage() or 0
end

-- 调用玩家当前持有武器上的指定函数，并传递参数
function meta:CallWeaponFunction(funcname, ...)
	local wep = self:GetActiveWeapon()
	if wep:IsValid() and wep[funcname] then
		return wep[funcname](wep, self, ...)
	end
end

-- 返回一个被截断（最长16个字符）的玩家名字
-- 超过16个字符的名字会被截断并添加".."
function meta:ClippedName()
	local name = self:Name()
	if #name > 16 then
		name = string.sub(name, 1, 14)..".."
	end

	return name
end

-- 决定玩家在使用印记传送时的最佳目标位置
-- 查找距离玩家当前视线方向最近的印记
function meta:SigilTeleportDestination(not_from_sigil, corrupted)
	local sigils = corrupted and GAMEMODE:GetCorruptedSigils() or GAMEMODE:GetUncorruptedSigils()

	-- 如果非印记触发时没有可用印记，或印记少于2个时，返回nil
	if not_from_sigil then
		if #sigils == 0 then return end
	elseif #sigils <= 1 then return end

	local mypos = self:GetPos()
	local eyevector = self:GetAimVector()

	local dist = 999999999999
	local spos, d, icurrent, target, itarget

	-- 找到距离最近的当前印记
	if not not_from_sigil then
		for i, sigil in pairs(sigils) do
			d = sigil:GetPos():DistToSqr(mypos)
			if d < dist then
				dist = d
				icurrent = i
			end
		end
	end

	-- 找到最符合视线方向的传送目标
	dist = -1
	for i, sigil in pairs(sigils) do
		if i ~= icurrent then
			spos = sigil:GetPos() - mypos
			spos:Normalize()
			d = spos:Dot(eyevector)
			if d > dist then
				dist = d
				target = sigil
				itarget = i
			end
		end
	end

	return target, itarget
end

-- 处理玩家的"交替使用"输入
-- 首先检查是否正在传送中，然后检测并调用附近实体的AltUse方法
function meta:DispatchAltUse()
	-- 如果正在传送中，则取消传送
	local tpexist = self:GetStatus("sigilteleport")
	if tpexist and tpexist:IsValid() then
		self:RemoveStatus("sigilteleport", false, true)
		return
	end

	-- 检测附近的可交互实体
	local tr = self:CompensatedMeleeTrace(64, 4, nil, nil, nil, true)
	local ent = tr.Entity
	if ent and ent:IsValid() and ent.AltUse then
		return ent:AltUse(self, tr)
	end
end

-- 根据近战伤害对玩家视角产生晃动效果
function meta:MeleeViewPunch(damage)
	local maxpunch = (damage + 25) * 0.5
	local minpunch = -maxpunch
	self:ViewPunch(Angle(math.Rand(minpunch, maxpunch), math.Rand(minpunch, maxpunch), math.Rand(minpunch, maxpunch)))
end

-- 检查玩家是否在军火箱或印记附近
-- 检测范围：100单位半径
function meta:NearArsenalCrate()
	local pos = self:EyePos()

	if self.ArsenalZone and self.ArsenalZone:IsValid() then return true end

	local arseents = {}
	table.Add(arseents, ents.FindByClass("prop_arsenalcrate"))
	table.Add(arseents, ents.FindByClass("prop_obj_sigil"))	
	table.Add(arseents, ents.FindByClass("status_arsenalpack"))

	for _, ent in pairs(arseents) do
		local nearest = ent:NearestPoint(pos)
		if pos:DistToSqr(nearest) <= 10000 and (WorldVisible(pos, nearest) or self:TraceLine(100).Entity == ent) then
			return true
		end
	end

	return false
end

-- NearArsenalCrate的别名
meta.IsNearArsenalCrate = meta.NearArsenalCrate

-- 检查玩家是否在拆解台(Remantler)附近
-- 检测范围：100单位半径
function meta:NearRemantler()
	local pos = self:EyePos()

	local remantlers = ents.FindByClass("prop_remantler")

	for _, ent in pairs(remantlers) do
		local nearest = ent:NearestPoint(pos)
		if pos:DistToSqr(nearest) <= 10000 and (WorldVisible(pos, nearest) or self:TraceLine(100).Entity == ent) then
			return true
		end
	end

	return false
end

-- 获取玩家当前应该从补给中获得的弹药类型
-- 优先使用武器指定的补给弹药类型，否则使用"scrap"作为默认
function meta:GetResupplyAmmoType()
	local ammotype
	if not self.ResupplyChoice then
		local wep = self:GetActiveWeapon()
		if wep:IsValid() then
			ammotype = wep.GetResupplyAmmoType and wep:GetResupplyAmmoType() or wep.ResupplyAmmoType or wep:GetPrimaryAmmoTypeString()
		end
	end

	ammotype = ammotype and ammotype:lower() or self.ResupplyChoice

	if not ammotype or not GAMEMODE.AmmoResupply[ammotype] then
		return "scrap"
	end

	return ammotype
end

-- 通过职业名称字符串来设置玩家的僵尸职业
function meta:SetZombieClassName(classname)
	if GAMEMODE.ZombieClasses[classname] then
		self:SetZombieClass(GAMEMODE.ZombieClasses[classname].Index)
	end
end

-- 获取玩家的点数（通过数据表第1个整数）
function meta:GetPoints()
	return self:GetDTInt(1)
end

-- 获取玩家的血甲值（通过数据表指定字段）
function meta:GetBloodArmor()
	return self:GetDTInt(DT_PLAYER_INT_BLOODARMOR)
end

-- 增加玩家的腿部伤害（影响移动速度）
-- 如果有出生保护则不应用
function meta:AddLegDamage(damage)
	if self.SpawnProtection then return end

	local legdmg = self:GetLegDamage() + damage

	-- 如果当前腿部伤害较大，维持较高的值
	if self:GetFlatLegDamage() - damage * 0.25 > damage then
		legdmg = self:GetFlatLegDamage()
	end

	self:SetLegDamage(legdmg)
end

-- 根据特定类型（脉冲、冰冻）增加额外的腿部伤害
-- 脉冲类型可能触发共振效果，冰冻类型可能触发低温诱导
function meta:AddLegDamageExt(damage, attacker, inflictor, type)
	inflictor = inflictor or attacker

	if type == SLOWTYPE_PULSE then
		-- 脉冲减速：受脉冲武器减速倍率影响
		local legdmg = damage * (attacker.PulseWeaponSlowMul or 1)
		local startleg = self:GetFlatLegDamage()

		self:AddLegDamage(legdmg)
		if attacker.PulseImpedance then
			self:AddArmDamage(legdmg)
		end

		if SERVER and attacker:HasTrinket("resonance") then
			-- 累积脉冲伤害，达到阈值后触发共振
			attacker.AccuPulse = (attacker.AccuPulse or 0) + (self:GetFlatLegDamage() - startleg)

			if attacker.AccuPulse > 80 then
				self:PulseResonance(attacker, inflictor)
			end
		end
	elseif type == SLOWTYPE_COLD then
		-- 冰冻减速：如果僵尸有抗冻属性则免疫
		if self:IsValidLivingZombie() and self:GetZombieClassTable().ResistFrost then return end

		self:AddLegDamage(damage)
		self:AddArmDamage(damage)

		if SERVER and attacker:HasTrinket("cryoindu") then
			self:CryogenicInduction(attacker, inflictor, damage)
		end
	end
end

-- 设置一个原始的腿部伤害值（转换为时间格式存储）
function meta:SetLegDamage(damage)
	self.LegDamage = CurTime() + math.min(GAMEMODE.MaxLegDamage, damage * 0.125)
	if SERVER then
		self:UpdateLegDamage()
	end
end

-- 直接设置腿部伤害的到期时间
function meta:RawSetLegDamage(time)
	self.LegDamage = math.min(CurTime() + GAMEMODE.MaxLegDamage, time)
	if SERVER then
		self:UpdateLegDamage()
	end
end

-- 设置腿部伤害到期时间，但不低于当前值
function meta:RawCapLegDamage(time)
	self:RawSetLegDamage(math.max(self.LegDamage or 0, time))
end

-- 获取当前腿部伤害的剩余时间
function meta:GetLegDamage()
	return math.max(0, (self.LegDamage or 0) - CurTime())
end

-- 将腿部伤害的剩余时间转换为一个固定数值
function meta:GetFlatLegDamage()
	return math.max(0, ((self.LegDamage or 0) - CurTime()) * 8)
end

-- 增加玩家的手臂伤害（影响攻击速度）
-- 如果有出生保护则不应用
function meta:AddArmDamage(damage)
	if self.SpawnProtection then return end

	local armdmg = self:GetArmDamage() + damage

	if self:GetFlatArmDamage() - damage * 0.25 > damage  then
		armdmg = self:GetFlatArmDamage()
	end

	self:SetArmDamage(armdmg)
end

-- 设置一个原始的手臂伤害值（转换为时间格式存储）
function meta:SetArmDamage(damage)
	self.ArmDamage = CurTime() + math.min(GAMEMODE.MaxArmDamage, damage * 0.125)
	if SERVER then
		self:UpdateArmDamage()
	end
end

-- 直接设置手臂伤害的到期时间
function meta:RawSetArmDamage(time)
	self.ArmDamage = math.min(CurTime() + GAMEMODE.MaxArmDamage, time)
	if SERVER then
		self:UpdateArmDamage()
	end
end

-- 设置手臂伤害到期时间，但不低于当前值
function meta:RawCapArmDamage(time)
	self:RawSetArmDamage(math.max(self.ArmDamage or 0, time))
end

-- 获取当前手臂伤害的剩余时间
function meta:GetArmDamage()
	return math.max(0, (self.ArmDamage or 0) - CurTime())
end

-- 将手臂伤害的剩余时间转换为一个固定数值
function meta:GetFlatArmDamage()
	return math.max(0, ((self.ArmDamage or 0) - CurTime()) * 8)
end

-- 在冷却时间结束后，触发一次flinching动画
-- 僵尸根据最后被击中的部位触发，人类触发随机的flinching
function meta:Flinch()
	if CurTime() >= (self.NextFlinch or 0) then
		self.NextFlinch = CurTime() + 0.75

		if P_Team(self) == TEAM_UNDEAD then
			self:DoFlinchEvent(self:LastHitGroup())
		else
			self:DoRandomFlinchEvent()
		end
	end
end

-- 获取玩家当前的僵尸职业索引
function meta:GetZombieClass()
	return self.Class or GAMEMODE.DefaultZombieClass
end

-- 缓存僵尸职业表以提高性能
local ZombieClasses = {}
if GAMEMODE then
	ZombieClasses = GAMEMODE.ZombieClasses
end
hook.Add("Initialize", "LocalizeZombieClasses", function() ZombieClasses = GAMEMODE.ZombieClasses end)

-- 获取玩家当前僵尸职业的属性表
function meta:GetZombieClassTable()
	return ZombieClasses[self:GetZombieClass()]
end

-- 以下为优化的僵尸职业函数调用系列
-- 由于vararg会创建表导致性能开销，所以为0-5个参数分别定义单独的函数

local zctab
local zcfunc

-- 调用当前僵尸职业属性表中的函数（0个参数）
function meta:CallZombieFunction0(funcname)
	if P_Team(self) == TEAM_UNDEAD then
		zctab = ZombieClasses[E_GetTable(self).Class or GAMEMODE.DefaultZombieClass]
		zcfunc = zctab[funcname]
		if zcfunc then
			return zcfunc(zctab, self)
		end
	end
end

-- 调用当前僵尸职业属性表中的函数（1个参数）
function meta:CallZombieFunction1(funcname, a1)
	if P_Team(self) == TEAM_UNDEAD then
		zctab = ZombieClasses[E_GetTable(self).Class or GAMEMODE.DefaultZombieClass]
		zcfunc = zctab[funcname]
		if zcfunc then
			return zcfunc(zctab, self, a1)
		end
	end
end

-- 调用当前僵尸职业属性表中的函数（2个参数）
function meta:CallZombieFunction2(funcname, a1, a2)
	if P_Team(self) == TEAM_UNDEAD then
		zctab = ZombieClasses[E_GetTable(self).Class or GAMEMODE.DefaultZombieClass]
		zcfunc = zctab[funcname]
		if zcfunc then
			return zcfunc(zctab, self, a1, a2)
		end
	end
end

-- 调用当前僵尸职业属性表中的函数（3个参数）
function meta:CallZombieFunction3(funcname, a1, a2, a3)
	if P_Team(self) == TEAM_UNDEAD then
		zctab = ZombieClasses[E_GetTable(self).Class or GAMEMODE.DefaultZombieClass]
		zcfunc = zctab[funcname]
		if zcfunc then
			return zcfunc(zctab, self, a1, a2, a3)
		end
	end
end

-- 调用当前僵尸职业属性表中的函数（4个参数）
function meta:CallZombieFunction4(funcname, a1, a2, a3, a4)
	if P_Team(self) == TEAM_UNDEAD then
		zctab = ZombieClasses[E_GetTable(self).Class or GAMEMODE.DefaultZombieClass]
		zcfunc = zctab[funcname]
		if zcfunc then
			return zcfunc(zctab, self, a1, a2, a3, a4)
		end
	end
end

-- 将CallZombieFunction别名设为4参数版本（为向后兼容）
meta.CallZombieFunction = meta.CallZombieFunction4

-- 调用当前僵尸职业属性表中的函数（5个参数）
function meta:CallZombieFunction5(funcname, a1, a2, a3, a4, a5)
	if P_Team(self) == TEAM_UNDEAD then
		zctab = ZombieClasses[E_GetTable(self).Class or GAMEMODE.DefaultZombieClass]
		zcfunc = zctab[funcname]
		if zcfunc then
			return zcfunc(zctab, self, a1, a2, a3, a4, a5)
		end
	end
end

-- 从玩家的射击位置发出一条射线检测
-- 参数：distance-距离, mask-掩码, filter-过滤器, start-起始位置
function meta:TraceLine(distance, mask, filter, start)
	start = start or self:GetShootPos()
	return util_TraceLine({start = start, endpos = start + self:GetAimVector() * distance, filter = filter or self, mask = mask})
end

-- 从玩家的射击位置发出一个带有体积的射线检测
-- 参数：distance-距离, mask-掩码, size-体积大小, filter-过滤器, start-起始位置
function meta:TraceHull(distance, mask, size, filter, start)
	start = start or self:GetShootPos()
	return util_TraceHull({start = start, endpos = start + self:GetAimVector() * distance, filter = filter or self, mask = mask, mins = Vector(-size, -size, -size), maxs = Vector(size, size, size)})
end

-- 设置玩家的行走、奔跑和最大速度
function meta:SetSpeed(speed)
	if not speed then speed = 200 end

	-- 如果血甲大于0且有心肺技能，增加额外速度
	local runspeed = self:GetBloodArmor() > 0 and self:IsSkillActive(SKILL_CARDIOTONIC) and speed + 40 or speed

	self:SetWalkSpeed(speed)
	self:SetRunSpeed(runspeed)
	self:SetMaxSpeed(runspeed)
end

-- 如果玩家是人类，则设置其速度
function meta:SetHumanSpeed(speed)
	if P_Team(self) == TEAM_HUMAN then self:SetSpeed(speed) end
end

-- 根据玩家的队伍、武器、技能和生命值等状态，重新计算并设置其移动速度
-- 参数noset为true时只计算不设置
function meta:ResetSpeed(noset, health)
	if not self:IsValid() then return end

	-- 僵尸速度：基于职业基础速度 × 全局速度倍率
	if P_Team(self) == TEAM_UNDEAD then
		local speed = math.max(140, self:GetZombieClassTable().Speed * GAMEMODE.ZombieSpeedMultiplier - (GAMEMODE.ObjectiveMap and 20 or 0))

		self:SetSpeed(speed)
		return speed
	end

	-- 人类速度：基于当前武器
	local wep = self:GetActiveWeapon()
	local speed

	if wep:IsValid() and wep.GetWalkSpeed then
		speed = wep:GetWalkSpeed()
	end

	if not speed then
		speed = wep.WalkSpeed or SPEED_NORMAL
	end

	-- 速度低于标准值时应用武器重量减速倍率
	if speed < SPEED_NORMAL then
		speed = SPEED_NORMAL - (SPEED_NORMAL - speed) * (self.WeaponWeightSlowMul or 1)
	end

	-- 应用技能速度加成
	if self.SkillSpeedAdd and P_Team(self) == TEAM_HUMAN then
		speed = speed + self.SkillSpeedAdd
	end

	-- 轻型技能：使用近战武器时额外加速
	if self:IsSkillActive(SKILL_LIGHTWEIGHT) and wep:IsValid() and wep.IsMelee then
		speed = speed + 6
	end

	speed = math.max(1, speed)

	-- 低生命值减速（非僵尸逃生模式）
	if 32 < speed and not GAMEMODE.ZombieEscape then
		health = health or self:Health()
		local maxhealth = self:GetMaxHealth() * 0.6666
		if health < maxhealth then
			speed = math.max(88, speed - speed * 0.4 * (1 - health / maxhealth) * (self.LowHealthSlowMul or 1))
		end
	end

	if not noset then
		self:SetSpeed(speed)
	end

	return speed
end

-- 根据玩家状态重新计算并设置其跳跃力
-- 支持僵尸职业、人类技能和武器的自定义跳跃
function meta:ResetJumpPower(noset)
	local power = DEFAULT_JUMP_POWER

	-- 僵尸跳跃力：基于职业设置
	if P_Team(self) == TEAM_UNDEAD then
		power = self:CallZombieFunction0("GetJumpPower") or power

		local classtab = self:GetZombieClassTable()
		if classtab and classtab.JumpPower then
			power = classtab.JumpPower
		end
	else
		-- 人类跳跃力：受技能倍率影响
		power = power * (self.JumpPowerMul or 1)

		-- 幽灵状态下跳跃力降低
		if self:GetBarricadeGhosting() then
			power = power * 0.25
			if not noset then
				self:SetJumpPower(power)
			end

			return power
		end
	end

	-- 武器自定义跳跃力
	local wep = self:GetActiveWeapon()
	if wep and wep.ResetJumpPower then
		power = wep:ResetJumpPower(power) or power
	end

	if not noset then
		self:SetJumpPower(power)
	end

	return power
end

-- 设置玩家是否可以穿透障碍物（"幽灵"状态）
-- b：是否启用，fullspeed：是否全速幽灵
function meta:SetBarricadeGhosting(b, fullspeed)
	if self == NULL then return end

	-- 禁止幽灵状态下，如果不处于幽灵状态则设置冷却
	if b and self.NoGhosting and not self:GetBarricadeGhosting() then
		self:SetDTFloat(DT_PLAYER_FLOAT_WIDELOAD, CurTime() + 6)
	end

	if fullspeed == nil then fullspeed = false end

	self:SetDTBool(0, b)
	self:SetDTBool(1, b and fullspeed)
	self:CollisionRulesChanged()

	self:ResetJumpPower()
end

-- 获取玩家是否处于穿透障碍物的状态
function meta:GetBarricadeGhosting()
	return E_GetDTBool(self, 0)
end

-- GetBarricadeGhosting的别名
meta.IsBarricadeGhosting = meta.GetBarricadeGhosting

-- 判断玩家是否应该穿透给定的实体
-- 默认逻辑：穿透路障道具
function meta:ShouldBarricadeGhostWith(ent)
	return ent:IsBarricadeProp()
end

-- 处理"幽灵"状态下的逻辑
-- 全速幽灵模式自动检测并取消，普通幽灵模式通过按键控制
function meta:BarricadeGhostingThink()
	if E_GetDTBool(self, 1) then
		-- 全速幽灵：不在障碍物内时取消
		if not self:ActiveBarricadeGhosting() then
			self:SetBarricadeGhosting(false)
		end
	else
		-- 普通幽灵：按住缩放键时保持，松开时取消
		if self:KeyDown(IN_ZOOM) or self:ActiveBarricadeGhosting() then
			if self.FirstGhostThink then
				self:SetLocalVelocity(vector_origin)
				self.FirstGhostThink = false
			end

			return
		end

		self.FirstGhostThink = true
		self:SetBarricadeGhosting(false)
	end
end

-- 核心碰撞检测函数
-- 判断玩家是否应该与另一个实体发生碰撞
-- 需要尽可能优化性能
function meta:ShouldNotCollide(ent)
	if E_IsValid(ent) then
		if getmetatable(ent) == meta then
			-- 同队玩家不碰撞，或设置了NoCollideAll的玩家不碰撞
			if P_Team(self) == P_Team(ent) or E_GetTable(self).NoCollideAll or E_GetTable(ent).NoCollideAll then
				return true
			end

			return false
		end

		-- 幽灵状态下穿透路障道具
		return E_GetDTBool(self, 0) and ent:IsBarricadeProp()
	end

	return false
end

-- 保存原始的SetHealth方法并重写
-- 在生命值改变时更新移动速度
meta.OldSetHealth = FindMetaTable("Entity").SetHealth
function meta:SetHealth(health)
	self:OldSetHealth(health)
	if P_Team(self) == TEAM_HUMAN and 1 <= health then
		self:ResetSpeed(nil, health)
	end
end

-- 检查玩家是否为头蟹类型的僵尸
function meta:IsHeadcrab()
	return P_Team(self) == TEAM_UNDEAD and GAMEMODE.ZombieClasses[self:GetZombieClass()].IsHeadcrab
end

-- 检查玩家是否为躯干类型的僵尸
function meta:IsTorso()
	return P_Team(self) == TEAM_UNDEAD and GAMEMODE.ZombieClasses[self:GetZombieClass()].IsTorso
end

-- 在空中急剧减速（用于空中制动）
function meta:AirBrake()
	local vel = self:GetVelocity()

	vel.x = vel.x * 0.15
	vel.y = vel.y * 0.15
	if vel.z > 0 then
		vel.z = vel.z * 0.15
	end

	self:SetLocalVelocity(vel)
end

-- 近战射线检测的临时变量
local temp_attacker = NULL
local temp_attacker_team = -1
local temp_pen_ents = {}
local temp_override_team

-- 近战射线检测过滤函数
-- 过滤掉攻击者自身、被穿透过的实体、友军等
local function MeleeTraceFilter(ent)
	if ent == temp_attacker
	or E_GetTable(ent).IgnoreMelee
	or getmetatable(ent) == meta and P_Team(ent) == temp_attacker_team
	or not temp_override_team and ent.IgnoreMeleeTeam and ent.IgnoreMeleeTeam == temp_attacker_team
	or temp_pen_ents[ent] then
		return false
	end

	return true
end

-- 动态跟踪过滤函数：忽略IgnoreTraces实体和玩家
local function DynamicTraceFilter(ent)
	if ent.IgnoreTraces or ent:IsPlayer() then
		return false
	end

	return true
end

-- FFA（自由混战）模式下的近战过滤函数
local function MeleeTraceFilterFFA(ent)
	if temp_pen_ents[ent] then
		return false
	end

	return ent ~= temp_attacker
end

-- 近战射线检测的基础配置表
local melee_trace = {filter = MeleeTraceFilter, mask = MASK_SOLID, mins = Vector(), maxs = Vector()}

-- 获取动态跟踪过滤函数（用于外部调用）
function meta:GetDynamicTraceFilter()
	return DynamicTraceFilter
end

-- FHB（假父级）实体检测函数
-- 将命中FHB实体替换为真正的父级实体
local function CheckFHB(tr)
	if tr.Entity.FHB and tr.Entity:IsValid() then
		tr.Entity = tr.Entity:GetParent()
	end
end

-- 执行一次近战攻击的射线检测
-- 支持距离、体积、起始位置、方向、是否命中队友等参数
function meta:MeleeTrace(distance, size, start, dir, hit_team_members, override_team, override_mask)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()
	hit_team_members = hit_team_members or GAMEMODE.RoundEnded

	local tr

	temp_attacker = self
	temp_attacker_team = P_Team(self)
	temp_override_team = override_team
	melee_trace.start = start
	melee_trace.endpos = start + dir * distance
	melee_trace.mask = override_mask or MASK_SOLID
	melee_trace.mins.x = -size
	melee_trace.mins.y = -size
	melee_trace.mins.z = -size
	melee_trace.maxs.x = size
	melee_trace.maxs.y = size
	melee_trace.maxs.z = size
	melee_trace.filter = hit_team_members and MeleeTraceFilterFFA or MeleeTraceFilter

	-- 先进行线检测
	tr = util_TraceLine(melee_trace)

	CheckFHB(tr)

	-- 如果未命中，再进行包围盒检测
	if tr.Hit then
		return tr
	end

	return util_TraceHull(melee_trace)
end

-- 使补偿后的射线检测无效化
-- 防止高延迟玩家在远处击中其他人
local function InvalidateCompensatedTrace(tr, start, distance)
	if tr.Entity:IsValid() and tr.Entity:IsPlayer() and tr.HitPos:DistToSqr(start) > distance * distance + 144 then
		tr.Hit = false
		tr.HitNonWorld = false
		tr.Entity = NULL
	end
end

-- 执行一次经过延迟补偿的近战攻击射线检测
function meta:CompensatedMeleeTrace(distance, size, start, dir, hit_team_members, override_team)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	self:LagCompensation(true)
	local tr = self:MeleeTrace(distance, size, start, dir, hit_team_members, override_team)
	CheckFHB(tr)
	self:LagCompensation(false)

	InvalidateCompensatedTrace(tr, start, distance)

	return tr
end

-- 执行一次可穿透多个目标的、经过延迟补偿的近战射线检测
function meta:CompensatedPenetratingMeleeTrace(distance, size, start, dir, hit_team_members)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	self:LagCompensation(true)
	local t = self:PenetratingMeleeTrace(distance, size, start, dir, hit_team_members)
	self:LagCompensation(false)

	for _, tr in pairs(t) do
		InvalidateCompensatedTrace(tr, start, distance)
	end

	return t
end

-- 专为僵尸设计的、经过延迟补偿的组合近战射线检测
-- 同时从眼睛和身体中心发出检测，合并结果
function meta:CompensatedZombieMeleeTrace(distance, size, start, dir, hit_team_members)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()

	self:LagCompensation(true)

	local hit_entities = {}

	-- 分别从视线位置和身体中心位置进行穿透检测
	local t, hitprop = self:PenetratingMeleeTrace(distance, size, start, dir, hit_team_members)
	local t_legs = self:PenetratingMeleeTrace(distance, size, self:WorldSpaceCenter(), dir, hit_team_members)

	-- 记录已命中的实体
	for _, tr in pairs(t) do
		hit_entities[tr.Entity] = true
	end

	-- 如果没命中道具，将身体中心检测的额外命中合并进来
	if not hitprop then
		for _, tr in pairs(t_legs) do
			if not hit_entities[tr.Entity] then
				t[#t + 1] = tr
			end
		end
	end

	-- 无效化远程命中
	for _, tr in pairs(t) do
		InvalidateCompensatedTrace(tr, tr.StartPos, distance)
	end

	self:LagCompensation(false)

	return t
end

-- 执行一次可穿透多个目标的近战射线检测
-- 最多穿透50个实体，遇到世界实体时停止
function meta:PenetratingMeleeTrace(distance, size, start, dir, hit_team_members)
	start = start or self:GetShootPos()
	dir = dir or self:GetAimVector()
	hit_team_members = hit_team_members or GAMEMODE.RoundEnded

	local tr, ent

	temp_attacker = self
	temp_attacker_team = P_Team(self)
	temp_pen_ents = {}
	melee_trace.start = start
	melee_trace.endpos = start + dir * distance
	melee_trace.mask = MASK_SOLID
	melee_trace.mins.x = -size
	melee_trace.mins.y = -size
	melee_trace.mins.z = -size
	melee_trace.maxs.x = size
	melee_trace.maxs.y = size
	melee_trace.maxs.z = size
	melee_trace.filter = hit_team_members and MeleeTraceFilterFFA or MeleeTraceFilter

	local t = {}
	local onlyhitworld
	-- 循环穿透检测，最多50次
	for i=1, 50 do
		tr = util_TraceLine(melee_trace)

		if not tr.Hit then
			tr = util_TraceHull(melee_trace)
		end

		if not tr.Hit then break end

		-- 命中世界实体则停止
		if tr.HitWorld then
			table.insert(t, tr)
			break
		end

		if onlyhitworld then break end

		CheckFHB(tr)

		ent = tr.Entity
		if ent:IsValid() then
			-- 命中非玩家实体后，后续只检测世界实体
			if not ent:IsPlayer() then
				melee_trace.mask = MASK_SOLID_BRUSHONLY
				onlyhitworld = true
			end

			table.insert(t, tr)
			temp_pen_ents[ent] = true
		end
	end

	temp_pen_ents = {}

	return t, onlyhitworld
end

-- 检查玩家当前是否正处于障碍物内部并且启用了"幽灵"状态
function meta:ActiveBarricadeGhosting(override)
	if P_Team(self) ~= TEAM_HUMAN and not override or not self:GetBarricadeGhosting() then return false end

	-- 略微缩小玩家的包围盒用于检测
	local min, max = self:WorldSpaceAABB()
	min.x = min.x + 1
	min.y = min.y + 1

	max.x = max.x - 1
	max.y = max.y - 1

	-- 检测是否有路障道具在玩家的包围盒内
	for _, ent in pairs(ents.FindInBox(min, max)) do
		if ent and ent:IsValid() and self:ShouldBarricadeGhostWith(ent) then return true end
	end

	return false
end

-- 检查玩家是否正持有（搬运）一个物体
function meta:IsHolding()
	return self:GetHolding():IsValid()
end

-- IsHolding的别名
meta.IsCarrying = meta.IsHolding

-- 获取玩家当前持有（搬运）的物体
function meta:GetHolding()
	local status = self.status_human_holding
	if status and status:IsValid() then
		local obj = status:GetObject()
		if obj:IsValid() then return obj end
	end

	return NULL
end

-- 寻找离玩家最近的拆解台(Remantler)
function meta:NearestRemantler()
	local pos = self:EyePos()

	local remantlers = ents.FindByClass("prop_remantler")
	local min, remantler = 99999

	for _, ent in pairs(remantlers) do
		local nearpoint = ent:NearestPoint(pos)
		local trmatch = self:TraceLine(100).Entity == ent
		local dist = trmatch and 0 or pos:DistToSqr(nearpoint)
		if pos:DistToSqr(nearpoint) <= 10000 and dist < min then
			remantler = ent
		end
	end

	return remantler
end

-- 获取玩家作为僵尸时的最大生命值（来自职业表）
function meta:GetMaxZombieHealth()
	return self:GetZombieClassTable().Health
end

-- 保存原始GetMaxHealth方法并重写
-- 区分人类和僵尸的最大生命值
local oldmaxhealth = FindMetaTable("Entity").GetMaxHealth
function meta:GetMaxHealth()
	if P_Team(self) == TEAM_UNDEAD then
		return self:GetMaxZombieHealth()
	end

	return oldmaxhealth(self)
end

-- 重写存活判断函数
-- 加入观察者模式、NeverAlive状态等的检查
if not meta.OldAlive then
	meta.OldAlive = meta.Alive
	function meta:Alive()
		return self:GetObserverMode() == OBS_MODE_NONE and not self.NeverAlive and self:OldAlive()
	end
end

-- 同步并返回玩家的水平朝向角度（忽略垂直角度）
function meta:SyncAngles()
	local ang = self:EyeAngles()
	ang.pitch = 0
	ang.roll = 0
	return ang
end

-- SyncAngles的别名
meta.GetAngles = meta.SyncAngles

-- 获取玩家的水平前向向量
function meta:GetForward()
	return self:SyncAngles():Forward()
end

-- 获取玩家的水平上向向量
function meta:GetUp()
	return self:SyncAngles():Up()
end

-- 获取玩家的水平右向向量
function meta:GetRight()
	return self:SyncAngles():Right()
end

-- 获取僵尸的近战攻击速度加成
-- 受手臂伤害影响（增加速度），受战斗怒吼影响（降低速度）
function meta:GetZombieMeleeSpeedMul()
	return 1 * (1 + math.Clamp(self:GetArmDamage() / GAMEMODE.MaxArmDamage, 0, 1)) / (self:GetStatus("zombie_battlecry") and 1.2 or 1)
end

-- 获取玩家（人类或僵尸）的近战攻击速度加成
function meta:GetMeleeSpeedMul()
	if P_Team(self) == TEAM_UNDEAD then
		return self:GetZombieMeleeSpeedMul()
	end

	-- 人类：受手臂伤害和冰冻状态影响
	return 1 * (1 + math.Clamp(self:GetArmDamage() / GAMEMODE.MaxArmDamage, 0, 1)) / (self:GetStatus("frost") and 0.7 or 1)
end

-- 获取玩家的幻影生命值（通过数据表指定字段）
function meta:GetPhantomHealth()
	return self:GetDTFloat(DT_PLAYER_FLOAT_PHANTOMHEALTH)
end

-- 获取冰冻效果倍率：根据僵尸职业的冰冻抗性计算
-- 抗性为去掉百分号的数值，直接表示冰冻效果百分比：
--   0   = 完全免疫（寒冰boss等冰系僵尸用）
--   100 = 标准效果（与不设置等价）
--   200 = 双倍效果（更快被冻住）
--   50  = 半效（更抗冻）
-- 返回 0 表示免疫冰冻 buff
function meta:GetFreezeEffectMult()
	if not self:IsValidLivingZombie() then return 0 end

	local class = self:GetZombieClassTable()
	if not class or class.ResistFrost then return 0 end

	local res = class.FreezeResistance
	if res == 0 then return 0 end

	return (res or 100) / 100
end

-- 玩家是否处于完全冻结状态（冰冻 buff 阶段3：定身+禁攻+受伤倍率）
function meta:IsFrozenFull()
	local status = self:GetStatus("freeze")
	return status ~= nil and status:IsValid() and status:IsFullyFrozen()
end
