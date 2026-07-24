-- ============================================================
-- 浮动分数显示系统
-- 当玩家收到佣金、治疗队友或修理物体时，在目标位置显示浮动分数
-- ============================================================

-- 当补给箱被购买时调用，显示佣金点数
function GM:ReceivedCommission(crate, buyer, points)
	gamemode.Call("FloatingScore", crate, "floatingscore_com", points)
end

-- 当治疗其他玩家时调用，显示治疗量
function GM:HealedOtherPlayer(other, health)
	gamemode.Call("FloatingScore", other, "floatingscore_heal", health, nil, true)
end

-- 当修理物体时调用，显示修理量
function GM:RepairedObject(other, health)
	gamemode.Call("FloatingScore", other, "floatingscore_rep", health, nil, true)
end

-- 客户端控制台变量：是否禁用浮动分数显示（默认启用）
local cvarNoFloatingScore = CreateClientConVar("zs_nofloatingscore", 0, true, false)

-- 核心浮动分数触发函数
-- victim: 目标（可以是实体或Vector坐标）
-- effectname: 特效名称
-- frags: 分数数值
-- flags: 特效标志
-- override_allow: 是否允许在同队情况下显示
function GM:FloatingScore(victim, effectname, frags, flags, override_allow)
	-- 如果玩家禁用了浮动分数，直接返回
	if cvarNoFloatingScore:GetBool() then return end

	-- 判断victim是否为Vector类型
	local isvec = type(victim) == "Vector"

	-- 如果不是Vector且无效，或是同队玩家（除非override_allow为true），则不显示
	if not isvec and (not victim:IsValid() or victim:IsPlayer() and victim:Team() == MySelf:Team() and not override_allow) then
		return
	end

	-- 默认特效名称为"floatingscore"
	effectname = effectname or "floatingscore"

	-- 获取目标位置：Vector直接使用，实体则取离视点最近的点
	local pos = isvec and victim or victim:NearestPoint(EyePos())

	-- 构建特效数据
	local effectdata = EffectData()
	effectdata:SetOrigin(pos)
	effectdata:SetScale(flags or 0)

	-- 如果是僵尸击杀分数，从ZombieClasses表中获取对应点数
	if effectname == "floatingscore_und" then
		effectdata:SetMagnitude(math.Round(frags or GAMEMODE.ZombieClasses[victim:GetZombieClass()].Points or 1, 2))
	else
		effectdata:SetMagnitude(math.Round(frags or 1, 2))
	end

	-- 发送特效到所有客户端显示
	util.Effect(effectname, effectdata, true, true)
end
