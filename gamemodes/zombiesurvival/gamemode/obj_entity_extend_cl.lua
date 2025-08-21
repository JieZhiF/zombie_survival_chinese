-- 本文件主要用于在客户端扩展实体（Entity）的功能，包括添加新的方法和通过定时器缓存特定类型的实体以优化性能。

-- SetModelScaleVector 设置实体模型的缩放比例
-- TakeDamageInfo （占位函数）防止客户端调用时出错
-- SetPhysicsAttacker （占位函数）防止客户端调用时出错
-- HealPlayer 计算治疗量对玩家的具体效果（优先治疗流血和中毒）
-- Draw3DHealthBar 在3D空间中为实体绘制一个生命条
-- CacheNails (Timer) 定时缓存地图上所有的钉子（prop_nail）实体
-- IsNailed 检查实体是否被钉子固定
-- TransAlphaToMe 根据实体与玩家的距离调整其透明度，防止遮挡视线
-- CacheArsenalEntities (Timer) 定时缓存军火相关的实体（军火箱、军火包、携带军火箱的玩家）
-- CachedResupplyEntities (Timer) 定时缓存补给相关的实体（补给箱、补给包、携带补给箱的玩家）
-- CachedRemantlerEntities (Timer) 定时缓存拆解器相关的实体
-- CachedNests (Timer) 定时缓存爬行者巢穴实体
-- CachedBabies (Timer) 定时缓存被投掷的婴儿实体
-- CacheSigils (Timer) 定时缓存游戏中的印记（Sigils）实体

local meta = FindMetaTable("Entity")

local M_Player = FindMetaTable("Player")
local P_Team = M_Player.Team

function meta:SetModelScaleVector(vec)
	local bonecount = self:GetBoneCount()
	if bonecount and bonecount > 1 then
		local scale
		if type(vec) == "number" then
			scale = vec
		else
			scale = math.min(vec.x, vec.y, vec.z)
		end
		self._ModelScale = Vector(scale, scale, scale)
		self:SetModelScale(scale, 0)
	else
		if type(vec) == "number" then
			vec = Vector(vec, vec, vec)
		end

		self._ModelScale = vec
		local m = Matrix()
		m:Scale(vec)
		self:EnableMatrix("RenderMultiply", m)
	end
end

if not meta.TakeDamageInfo then
	meta.TakeDamageInfo = function() end
end
if not meta.SetPhysicsAttacker then
	meta.SetPhysicsAttacker = function() end
end

function meta:HealPlayer(pl, amount)
	local healed, rmv = 0, 0

	local health, maxhealth = pl:Health(), pl:GetDTBool(DT_PLAYER_BOOL_FRAIL) and math.floor(pl:GetMaxHealth() * 0.25) or pl:GetMaxHealth()
	local missing_health = maxhealth - health
	local poison = pl:GetPoisonDamage()
	local bleed = pl:GetBleedDamage()

	local multiplier = self.MedicHealMul or 1

	amount = amount * multiplier

	-- Heal bleed first.
	if bleed > 0 then
		rmv = math.min(amount, bleed)
		healed = healed + rmv
		amount = amount - rmv
	end

	-- Heal poison next.
	if poison > 0 and amount > 0 then
		rmv = math.min(amount, poison)
		healed = healed + rmv
		amount = amount - rmv
	end

	-- Then heal missing health.
	if missing_health > 0 and amount > 0 then
		rmv = math.min(amount, missing_health)
		healed = healed + rmv
		amount = amount - rmv
	end

	return healed
end

local y = -50
local maxbarwidth = 560
local barheight = 30
function meta:Draw3DHealthBar(percentage, name, yoffset, widthprop, nameoffset)
	yoffset = yoffset or 0
	local barwidth = maxbarwidth * (widthprop or 1)
	local startx = barwidth * -0.5

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(startx, y + yoffset, barwidth, barheight)
	surface.SetDrawColor(255 - percentage * 255, percentage * 255, 0, 220)
	surface.DrawRect(startx + 4, y + 4 + yoffset, barwidth * percentage - 8, barheight - 8)
	surface.DrawOutlinedRect(startx, y + yoffset, barwidth, barheight)

	if name then
		draw.SimpleText(name, "ZS3D2DFont", 0, yoffset + (nameoffset or 0), COLOR_WHITE, TEXT_ALIGN_CENTER)
	end
end

-- Caching

local CachedNails = {}

timer.Create("CacheNails", 0.3333, 0, function()
	CachedNails = {}

	for _, nail in pairs(ents.FindByClass("prop_nail")) do
		if nail:IsValid() and nail.GetAttachEntity then
			CachedNails[#CachedNails + 1] = nail
			nail.CachedAttachEntity = nail:GetAttachEntity()
			nail.CachedBaseEntity = nail:GetBaseEntity()
		end
	end
end)

function meta:IsNailed()
	if self:IsValid() then -- In case we're the world.
		for _, nail in pairs(CachedNails) do
			if nail.CachedAttachEntity == self or nail.CachedBaseEntity == self then
				return true
			end
		end
	end

	return false
end

function meta:TransAlphaToMe()
	local radius = GAMEMODE.TransparencyRadius / 9
	if radius > 0 and P_Team(MySelf) == TEAM_HUMAN then
		local dist = self:GetPos():DistToSqr(EyePos())
		if dist < radius then
			return math.max(0.1, (dist / radius) ^ 0.5)
		end
	end

	return 1
end

GM.CachedArsenalEntities = {}
timer.Create("CacheArsenalEntities", 0.5, 0, function()
	if not GAMEMODE then return end
	GAMEMODE.CachedArsenalEntities = {}

	local arseents = {}
	table.Add(arseents, ents.FindByClass("prop_arsenalcrate"))
	table.Add(arseents, ents.FindByClass("status_arsenalpack"))

	for _, v in pairs(player.GetAll()) do
		if v ~= MySelf and not v:HasTrinket("arsenalpack") and v:HasWeapon("weapon_zs_arsenalcrate") then
			table.insert(arseents, v)
		end
	end

	GAMEMODE.CachedArsenalEntities = arseents
end)

GM.CachedResupplyEntities = {}
timer.Create("CachedResupplyEntities", 0.5, 0, function()
	if not GAMEMODE then return end
	GAMEMODE.CachedResupplyEntities = {}

	local resupents = {}
	table.Add(resupents, ents.FindByClass("prop_resupplybox"))
	table.Add(resupents, ents.FindByClass("status_resupplypack"))

	for _, v in pairs(player.GetAll()) do
		if v ~= MySelf and not v:HasTrinket("resupplypack") and v:HasWeapon("weapon_zs_resupplybox") then
			table.insert(resupents, v)
		end
	end

	GAMEMODE.CachedResupplyEntities = resupents
end)

GM.CachedRemantlerEntities = {}
timer.Create("CachedRemantlerEntities", 0.5, 0, function()
	if not GAMEMODE then return end
	GAMEMODE.CachedRemantlerEntities = {}

	local remanents = {}
	table.Add(remanents, ents.FindByClass("prop_remantler"))

	for _, v in pairs(player.GetAll()) do
		if v ~= MySelf and v:HasWeapon("weapon_zs_remantler") then
			table.insert(remanents, v)
		end
	end

	GAMEMODE.CachedRemantlerEntities = remanents
end)

GM.CachedNests = {}
timer.Create("CachedNests", 0.5, 0, function()
	if not GAMEMODE then return end
	GAMEMODE.CachedNests = {}

	local nests = {}
	table.Add(nests, ents.FindByClass("prop_creepernest"))

	GAMEMODE.CachedNests = nests
end)

GM.CachedBabies = {}
timer.Create("CachedBabies", 0.5, 0, function()
	if not GAMEMODE then return end
	GAMEMODE.CachedBabies = {}

	local babies = {}
	table.Add(babies, ents.FindByClass("prop_thrownbaby"))
	table.Add(babies, ents.FindByClass("prop_thrownshadowbaby"))

	GAMEMODE.CachedBabies = babies
end)

GM.CachedSigils = {}
timer.Create("CacheSigils", 2, 0, function()  -- 改为2秒间隔
    if not GAMEMODE then return end
    
    -- 检查游戏是否在进行中，避免重启时的问题
    if GAMEMODE:GetWave() < 0 then return end
    
    GAMEMODE.CachedSigils = GAMEMODE:GetSigils()
end)