-- 如果当前地图不是以 "ze_" 开头，则跳过本文件的执行（本文件仅适用于僵尸逃跑模式）
if string.sub(string.lower(game.GetMap()), 1, 3) ~= "ze_" then return end

-- 标记当前游戏为僵尸逃跑（Zombie Escape）模式
GM.ZombieEscape = true
-- 第0波（准备阶段）的持续时间为90秒
GM.WaveZeroLength = 90
-- 游戏结束倒计时为35秒
GM.EndGameTime = 35
-- 僵尸逃跑模式中的冻结时间为20秒
GM.ZE_FreezeTime = 20
-- 整个ZE模式的时间上限为16分钟（60秒 × 16）
GM.ZE_TimeLimit = 60 * 16

-- 默认僵尸种类设为"超级僵尸"
GM.DefaultZombieClass = GM.ZombieClasses["Super Zombie"].Index

-- 默认跳跃力设为195
DEFAULT_JUMP_POWER = 195

-- CSS（反恐精英：起源）武器列表，用于在ZE地图中注册虚拟武器实体
local CSSWEAPONS = {"weapon_knife","weapon_glock","weapon_usp","weapon_p228","weapon_deagle",
	"weapon_elite","weapon_fiveseven","weapon_m3","weapon_xm1014","weapon_galil",
	"weapon_ak47","weapon_scout","weapon_sg552","weapon_awp","weapon_g3sg1",
	"weapon_famas","weapon_m4a1","weapon_aug","weapon_sg550","weapon_mac10",
	"weapon_tmp","weapon_mp5navy","weapon_ump45","weapon_p90","weapon_m249"}

-- 覆盖移动逻辑：根据玩家状态和腿部伤害调整移动速度
-- @param pl 玩家对象
-- @param move 移动数据对象
function GM:Move(pl, move)
	-- 如果玩家是人类阵营
	if pl:Team() == TEAM_HUMAN then
		-- 处于路障幽灵状态时，将速度限制到极慢
		if pl:GetBarricadeGhosting() then
			move:SetMaxSpeed(36)
			move:SetMaxClientSpeed(36)
		-- 后退时速度降低至90%
		elseif move:GetForwardSpeed() < 0 then
			move:SetMaxSpeed(move:GetMaxSpeed() * 0.9)
			move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.9)
		-- 原地不动时速度降低至95%
		elseif move:GetForwardSpeed() == 0 then
			move:SetMaxSpeed(move:GetMaxSpeed() * 0.95)
			move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.95)
		end
	-- 如果是僵尸阵营，调用僵尸特有的移动逻辑
	elseif pl:CallZombieFunction1("Move", move) then
		return
	end

	-- 处理腿部伤害对移动速度的影响
	local legdamage = pl:GetLegDamage()
	if legdamage > 0 then
		local scale = 1 - math.min(1, legdamage * 0.25)
		move:SetMaxSpeed(move:GetMaxSpeed() * scale)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * scale)
	end
end

-- 获取僵尸伤害倍率（在ZE模式中为固定倍率，不随位置变化）
-- @param pos 伤害发生的位置（未使用）
-- @param ignore 忽略参数（未使用）
-- @return 僵尸伤害倍率
function GM:GetZombieDamageScale(pos, ignore)
	return self.ZombieDamageMultiplier
end

-- 缩放玩家受到的伤害：处理爆头、部位伤害倍率和腿部伤害积累
-- @param pl 受伤的玩家
-- @param hitgroup 命中的部位组
-- @param dmginfo 伤害信息对象
function GM:ScalePlayerDamage(pl, hitgroup, dmginfo)
	-- 非子弹伤害不进行处理
	if not dmginfo:IsBulletDamage() then return end

	-- 如果是子弹爆头伤害，记录爆头时间
	if dmginfo:IsBulletDamage() and hitgroup == HITGROUP_HEAD then
		pl.m_LastHeadShot = CurTime()
	end

	-- 调用僵尸特有函数处理伤害缩放，如果返回false则使用默认缩放
	if not pl:CallZombieFunction2("ScalePlayerDamage", hitgroup, dmginfo) then
		-- 头部伤害：2倍伤害
		if hitgroup == HITGROUP_HEAD then
			dmginfo:SetDamage(dmginfo:GetDamage() * 2)
		-- 腿部/裆部伤害：25%伤害
		elseif hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.25)
		-- 腹部/手臂伤害：75%伤害
		elseif hitgroup == HITGROUP_STOMACH or hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
			dmginfo:SetDamage(dmginfo:GetDamage() * 0.75)
		end
	end

	-- 如果是亡灵阵营且应该承受伤害，则根据伤害量和部位积累腿部伤害
	if pl:Team() == TEAM_UNDEAD and self:PlayerShouldTakeDamage(pl, dmginfo:GetAttacker()) then
		pl:AddLegDamage(((hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG) and 1 or 0.125) * dmginfo:GetDamage())
	end
end

-- 创建一些虚拟实体，避免控制台被找不到实体的报错刷屏
-- 以下定义一个虚拟实体基表
local ENT = {}

-- 实体类型为动画实体
ENT.Type = "anim"
-- 不进行任何渲染
ENT.RenderGroup = RENDERGROUP_NONE

-- 初始化：设置实体不可见
function ENT:Initialize()
	self:SetNoDraw(true)
end

-- 服务端逻辑：每帧尝试移除自己（这些虚拟实体不需要存在）
if SERVER then
function ENT:Think()
	self:Remove()
end
end

-- 于游戏初始化时注册虚拟实体，避免找不到武器/弹药实体的报错
hook.Add("Initialize", "RegisterDummyEntities", function()
	-- 注册虚拟弹药实体
	scripted_ents.Register(ENT, "ammo_50ae")
	scripted_ents.Register(ENT, "ammo_556mm_box")
	-- 注册虚拟武器剥离实体
	scripted_ents.Register(ENT, "player_weaponstrip")

	-- 为ZE地图注册CSS武器虚拟实体，使它们能被地图逻辑引用
	for i, weapon in pairs(CSSWEAPONS) do
		weapons.Register({Base = "weapon_map_base"},weapon)
	end
end)

-- 限制玩家拾取武器的钩子：根据阵营和已有武器类型进行过滤
hook.Add( "PlayerCanPickupWeapon", "RestrictMapWeapons", function( ply, wep )
	-- 人类不能拾取刀（weapon_knife）
	if wep:GetClass() == "weapon_knife" then
		if ply:Team() == TEAM_HUMAN then return false end
	-- 亡灵不能拾取CSS武器
	else
		if table.HasValue(CSSWEAPONS,wep:GetClass()) and ply:Team() == TEAM_UNDEAD then return false end
	end

	-- 获取玩家当前拥有的所有武器
	local weps = ply:GetWeapons()
	-- 每个玩家只允许拥有一把特殊武器（CSS武器或地图基础武器）
	for k, v in pairs(weps) do
		if table.HasValue( CSSWEAPONS, v:GetClass() ) or v:GetClass() == "weapon_map_base" then return false end
	end

	return true
end)
