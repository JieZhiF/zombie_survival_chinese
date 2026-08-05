-- 本文件主要负责处理客户端的屏幕空间效果和视觉渲染，包括后期处理、颜色修正、特殊视觉模式（夜视、僵尸视觉）、玩家光环以及各种基于玩家状态（如受伤、恐惧、死亡）的视觉反馈。
-- GM:RenderScreenspaceEffects 预定义的空渲染钩子，实际逻辑在 RenderScreenspaceEffects 中。
-- zs_postprocessing 客户端控制台变量，用于开关所有后期处理效果。
-- zs_filmgrain 客户端控制台变量，用于开关电影胶片颗粒效果。
-- zs_filmgrainopacity 客户端控制台变量，用于设置电影胶片颗粒效果的不透明度。
-- zs_colormod 客户端控制台变量，用于开关颜色修正效果。
-- zs_auras 客户端控制台变量，用于开关僵尸视角下的人类光环。
-- zs_auracolor_empty* 客户端控制台变量，设置人类在低血量时光环的RGB颜色。
-- zs_auracolor_full_* 客户端控制台变量，设置人类在满血量时光环的RGB颜色。
-- tColorModDead 玩家死亡后的颜色修正参数表。
-- tColorModHuman 人类玩家的默认颜色修正参数表。
-- tColorModZombie 僵尸玩家的默认颜色修正参数表。
-- tColorModZombieVision 僵尸开启特殊视觉后的颜色修正参数表。
-- tColorModNightVision 人类开启夜视仪后的颜色修正参数表。
-- GM:_RenderScreenspaceEffects 核心的屏幕效果渲染函数，根据玩家状态应用不同的视觉效果。
-- GM:_RenderScene 渲染场景前调用，用于根据视觉模式（夜视/僵尸视觉）设置全亮模式。
-- GM:FullBrightOn 开启全亮渲染模式。
-- GM:FullBrightOff 关闭全亮渲染模式。
-- GM:DrawHumanIndicators 为僵尸玩家绘制人类玩家身上的光环指示器。
-- GM:ToggleZombieVision 切换僵尸视觉的开关，并播放音效。
-- RenderWhiteOut 渲染白屏/闪光效果的内部函数。
-- util.WhiteOut 触发一个白屏/闪光效果。

-- 预定义的空渲染钩子，实际逻辑由其他函数接管
function GM:RenderScreenspaceEffects()
end

-- 后期处理总开关控制变量（默认开启）
GM.PostProcessingEnabled = CreateClientConVar("zs_postprocessing", 1, true, false):GetBool()
-- 监听控制变量变化，实时更新状态
cvars.AddChangeCallback("zs_postprocessing", function(cvar, oldvalue, newvalue)
	GAMEMODE.PostProcessingEnabled = tonumber(newvalue) == 1
end)

-- 电影胶片颗粒效果开关控制变量（默认开启）
GM.FilmGrainEnabled = CreateClientConVar("zs_filmgrain", 1, true, false):GetBool()
-- 监听控制变量变化，实时更新状态
cvars.AddChangeCallback("zs_filmgrain", function(cvar, oldvalue, newvalue)
	GAMEMODE.FilmGrainEnabled = tonumber(newvalue) == 1
end)

-- 电影胶片颗粒效果不透明度控制变量（默认50，范围0-255）
GM.FilmGrainOpacity = CreateClientConVar("zs_filmgrainopacity", 50, true, false):GetInt()
-- 监听控制变量变化，实时更新并限制在0-255范围内
cvars.AddChangeCallback("zs_filmgrainopacity", function(cvar, oldvalue, newvalue)
	GAMEMODE.FilmGrainOpacity = math.Clamp(tonumber(newvalue) or 0, 0, 255)
end)

-- 颜色修正效果开关控制变量（默认开启）
GM.ColorModEnabled = CreateClientConVar("zs_colormod", "1", true, false):GetBool()
-- 监听控制变量变化，实时更新状态
cvars.AddChangeCallback("zs_colormod", function(cvar, oldvalue, newvalue)
	GAMEMODE.ColorModEnabled = tonumber(newvalue) == 1
end)

-- 僵尸视角下的人类光环显示开关控制变量（默认开启）
GM.Auras = CreateClientConVar("zs_auras", 1, true, false):GetBool()
-- 监听控制变量变化，实时更新状态
cvars.AddChangeCallback("zs_auras", function(cvar, oldvalue, newvalue)
	GAMEMODE.Auras = tonumber(newvalue) == 1
end)

-- 低血量时的光环颜色（默认红色）
GM.AuraColorEmpty = Color(CreateClientConVar("zs_auracolor_empty_r", 255, true, false):GetInt(), CreateClientConVar("zs_auracolor_empty_g", 0, true, false):GetInt(), CreateClientConVar("zs_auracolor_empty_b", 0, true, false):GetInt(), 255)
-- 满血量时的光环颜色（默认绿色）
GM.AuraColorFull = Color(CreateClientConVar("zs_auracolor_full_r", 20, true, false):GetInt(), CreateClientConVar("zs_auracolor_full_g", 255, true, false):GetInt(), CreateClientConVar("zs_auracolor_full_b", 20, true, false):GetInt(), 255)

-- 监听空血光环颜色的红色分量变化
cvars.AddChangeCallback("zs_auracolor_empty_r", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorEmpty.r = math.Clamp(math.ceil(tonumber(newvalue) or 0), 0, 255)
end)

-- 监听空血光环颜色的绿色分量变化
cvars.AddChangeCallback("zs_auracolor_empty_g", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorEmpty.g = math.Clamp(math.ceil(tonumber(newvalue) or 0), 0, 255)
end)

-- 监听空血光环颜色的蓝色分量变化
cvars.AddChangeCallback("zs_auracolor_empty_b", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorEmpty.b = math.Clamp(math.ceil(tonumber(newvalue) or 0), 0, 255)
end)

-- 监听满血光环颜色的红色分量变化
cvars.AddChangeCallback("zs_auracolor_full_r", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorFull.r = math.Clamp(math.ceil(tonumber(newvalue) or 0), 0, 255)
end)

-- 监听满血光环颜色的绿色分量变化
cvars.AddChangeCallback("zs_auracolor_full_g", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorFull.g = math.Clamp(math.ceil(tonumber(newvalue) or 0), 0, 255)
end)

-- 监听满血光环颜色的蓝色分量变化
cvars.AddChangeCallback("zs_auracolor_full_b", function(cvar, oldvalue, newvalue)
	GAMEMODE.AuraColorFull.b = math.Clamp(math.ceil(tonumber(newvalue) or 0), 0, 255)
end)

-- 缓存常用全局函数和变量到本地，提升性能
local DrawColorModify = DrawColorModify
local DrawSharpen = DrawSharpen
local EyePos = EyePos
local TEAM_HUMAN = TEAM_HUMAN
local TEAM_UNDEAD = TEAM_UNDEAD
local render_SetMaterial = render.SetMaterial
local render_DrawSprite = render.DrawSprite
local render_SetLightingMode = render.SetLightingMode
local math_Approach = math.Approach
local FrameTime = FrameTime
local CurTime = CurTime
local math_sin = math.sin
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local team_GetPlayers = team.GetPlayers

-- 全亮模式开关标记
local FullBright = false

-- 玩家死亡后的颜色修正参数表（高对比度、去色、暗化）
local tColorModDead = {
	["$pp_colour_contrast"] = 1.25,
	["$pp_colour_colour"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.02,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

-- 人类玩家的默认颜色修正参数表（未修改）
local tColorModHuman = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

-- 僵尸玩家的默认颜色修正参数表（高对比度、降低色彩饱和度）
local tColorModZombie = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1.25,
	["$pp_colour_colour"] = 0.5,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

-- 僵尸开启特殊视觉后的颜色修正参数表（高色彩饱和度、暗化、绿色调）
local tColorModZombieVision = {
	["$pp_colour_colour"] = 3,
	["$pp_colour_brightness"] = -0.1,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_mulr"]	= 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.1,
	["$pp_colour_addb"] = 0
}

-- 人类开启夜视仪后的颜色修正参数表（绿色单色效果、高对比度）
local tColorModNightVision = {
	["$pp_colour_colour"] = 0.99,
	["$pp_colour_brightness"] = -0.34,
	["$pp_colour_contrast"] = 1.46,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 1,
	["$pp_colour_mulb"] = 0,
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.2,
	["$pp_colour_addb"] = 0
}

-- 受伤时的红色视效强度（随时间平滑变化）
local redview = 0
-- 当前恐惧效果强度（随时间平滑变化）
local fear = 0

-- 核心屏幕效果渲染函数，根据玩家状态应用不同的视觉效果
function GM:_RenderScreenspaceEffects()
	-- 如果玩家当前有混淆效果且有效，渲染混淆效果
	if MySelf.Confusion and MySelf.Confusion:IsValid() then
		MySelf.Confusion:RenderScreenSpaceEffects()
	end

	-- 恐惧值平滑趋近于当前实际恐惧强度
	fear = math_Approach(fear, self:CachedFearPower(), FrameTime())

	-- 如果后期处理被禁用，直接返回
	if not self.PostProcessingEnabled then return end

	-- 如果开启了受伤闪光效果且伤害效果值大于0，绘制锐化效果
	if self.DrawPainFlash and self.HurtEffect > 0 then
		DrawSharpen(1, math_min(6, self.HurtEffect * 3))
	end

	-- 颜色修正未启用时跳过全部 DrawColorModify（每帧高开销）
	if not self.ColorModEnabled then return end

	if not MySelf:Alive() and MySelf:GetObserverMode() ~= OBS_MODE_CHASE then
			-- 死亡状态且非追踪观察模式：应用死亡颜色修正（去色效果逐渐增强）
			if not MySelf:HasWon() then
				tColorModDead["$pp_colour_colour"] = (1 - math_min(1, CurTime() - self.LastTimeAlive)) * 0.5
				DrawColorModify(tColorModDead)
			end
		elseif MySelf:Team() == TEAM_UNDEAD then
			-- 僵尸阵营：根据是否开启僵尸视觉选择不同的颜色修正
			if self.m_ZombieVision then
				DrawColorModify(tColorModZombieVision)
			else
				-- 僵尸默认视觉：颜色饱和度随时间恢复，并与恐惧值相关
				tColorModZombie["$pp_colour_colour"] = math_min(1, 0.25 + math_min(1, (CurTime() - self.LastTimeDead) * 0.5) * 1.75 * fear)
				DrawColorModify(tColorModZombie)
			end
		else
			-- 人类阵营：根据是否开启夜视选择不同的颜色修正
			if self.m_NightVision then
				DrawColorModify(tColorModNightVision)
			else
				-- 人类默认视觉：根据生命值添加红色边缘效果，根据恐惧值调整亮度/对比度/饱和度
				local curr = tColorModHuman["$pp_colour_addr"]
				local health = MySelf:Health()
				local maxhealth = MySelf:GetMaxHealth() / 3
				-- 当生命值低于三分之一时，红色视效随生命值降低而增强
				if health <= maxhealth then
					redview = math_Approach(redview, 1 - health / maxhealth, FrameTime() * 0.2)
				elseif 0 < curr then
					-- 生命值恢复后，红色视效逐渐减弱
					redview = math_Approach(redview, 0, FrameTime() * 0.2)
				end

				-- 应用红色边缘效果（带心跳脉冲效果）
				tColorModHuman["$pp_colour_addr"] = redview * (0.035 + math_abs(math_sin(CurTime() * 2)) * 0.14)
				-- 恐惧值影响：降低亮度、提高对比度、降低色彩饱和度
				tColorModHuman["$pp_colour_brightness"] = fear * -0.045
				tColorModHuman["$pp_colour_contrast"] = 1 + fear * 0.15
				tColorModHuman["$pp_colour_colour"] = 1 - fear * 0.725 --0.85

				DrawColorModify(tColorModHuman)
			end
		end
end

-- 渲染场景前调用，根据视觉模式设置全亮模式
function GM:_RenderScene()
	-- 如果僵尸开启了僵尸视觉，或者人类开启了夜视（且没有"昏暗视觉"状态），启用全亮渲染
	if (self.m_ZombieVision and MySelf:Team() == TEAM_UNDEAD) or (self.m_NightVision and MySelf:Team() == TEAM_HUMAN and not MySelf:GetStatus("dimvision")) then
		render_SetLightingMode(1)
		FullBright = true
	else
		FullBright = false
	end
end

-- 开启全亮渲染模式：如果全亮标记为true，设置光照模式为全亮
function GM:FullBrightOn()
	if FullBright then
		render_SetLightingMode(1)
	end
end

-- 关闭全亮渲染模式：如果全亮标记为true，恢复默认光照模式
function GM:FullBrightOff()
	if FullBright then
		render_SetLightingMode(0)
	end
end

-- 注册渲染钩子：在不透明/半透明渲染前关闭全亮，在渲染后恢复
hook.Add("PreDrawOpaqueRenderables", "ZFullBright", GM.FullBrightOff)
hook.Add("PreDrawTranslucentRenderables", "ZFullBright", GM.FullBrightOff)
hook.Add("PostDrawTranslucentRenderables", "ZFullBright", GM.FullBrightOn)
-- 视图模型和屏幕空间效果渲染时关闭全亮
hook.Add("PreDrawViewModel", "ZFullBright", GM.FullBrightOff)
hook.Add("RenderScreenspaceEffects", "ZFullBright", GM.FullBrightOff)

-- 用于绘制光环的发光材质
local matGlow = Material("Sprites/light_glow02_add_noz")
-- 引用低血量和高血量光环颜色
local colHealthEmpty = GM.AuraColorEmpty
local colHealthFull = GM.AuraColorFull
-- 实际绘制时使用的过渡颜色
local colHealth = Color(255, 255, 255)

-- 为僵尸玩家绘制人类玩家身上的光环指示器
function GM:DrawHumanIndicators()
	-- 如果不是僵尸阵营、光环被禁用、或开启了僵尸视觉，则跳过绘制
	if MySelf:Team() ~= TEAM_UNDEAD or not self.Auras or self.m_ZombieVision then return end

	-- 获取玩家眼睛位置
	local eyepos = EyePos()
	local range, dist, healthfrac, pos, size
	-- 遍历所有人类玩家
	for _, pl in pairs(team_GetPlayers(TEAM_HUMAN)) do
		range = pl:GetAuraRangeSqr()
		dist = pl:GetPos():DistToSqr(eyepos)
		-- 如果人类存活、在光环范围内、且（非亡灵状态或距离足够远），则绘制光环
		if pl:Alive() and dist <= range and (not pl:GetDTBool(DT_PLAYER_BOOL_NECRO) or dist >= 27500) then
			-- 根据生命值比例在空血颜色和满血颜色之间插值
			healthfrac = math_max(pl:Health(), 0) / pl:GetMaxHealth()
			colHealth.r = math_Approach(colHealthEmpty.r, colHealthFull.r, math_abs(colHealthEmpty.r - colHealthFull.r) * healthfrac)
			colHealth.g = math_Approach(colHealthEmpty.g, colHealthFull.g, math_abs(colHealthEmpty.g - colHealthFull.g) * healthfrac)
			colHealth.b = math_Approach(colHealthEmpty.b, colHealthFull.b, math_abs(colHealthEmpty.b - colHealthFull.b) * healthfrac)

			-- 获取玩家世界中心位置
			pos = pl:WorldSpaceCenter()

			-- 绘制基础光环精灵
			render_SetMaterial(matGlow)
			render_DrawSprite(pos, 13, 13, colHealth)
			-- 根据心跳时间和玩家索引计算脉冲大小的放大光环
			size = math_sin(self.HeartBeatTime + pl:EntIndex()) * 50 - 21
			if size > 0 then
				render_DrawSprite(pos, size * 1.5, size, colHealth)
				render_DrawSprite(pos, size, size * 1.5, colHealth)
			end
		end
	end
end

-- 切换僵尸视觉的开启/关闭，并播放对应的音效
function GM:ToggleZombieVision(onoff)
	-- 如果没有指定状态，则切换当前状态
	if onoff == nil then
		onoff = not self.m_ZombieVision
	end

	-- 开启僵尸视觉：设置标记并播放开启音效
	if onoff then
		if not self.m_ZombieVision then
			self.m_ZombieVision = true
			MySelf:EmitSound("npc/stalker/breathing3.wav", 0, 230)
		end
	-- 关闭僵尸视觉：清除标记并播放关闭音效
	elseif self.m_ZombieVision then
		self.m_ZombieVision = nil
		MySelf:EmitSound("npc/zombie/zombie_pain6.wav", 0, 110)
	end
end

-- 白屏/闪光效果的颜色修正参数表
local CModWhiteOut = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
-- 白屏效果的结束时间
local WhiteOutEnd
-- 白屏效果的淡出时间
local WhiteOutFadeTime

-- 渲染白屏/闪光效果的内部函数
local function RenderWhiteOut()
	-- 计算剩余时间比例
	local dt = math_max(WhiteOutEnd - CurTime(), 0) / WhiteOutFadeTime
	if dt <= 0 then
		-- 效果结束，清理变量并移除钩子
		WhiteOutEnd = nil
		WhiteOutFadeTime = nil
		hook.Remove("RenderScreenspaceEffects", "WhiteOut")
	else
		-- 根据剩余时间计算闪光参数并渲染
		local size = 5 + dt * 10
		CModWhiteOut["$pp_colour_brightness"] = dt ^ 2
		DrawBloom(1 - dt, dt * 3, size, size, 1, 1, 1, 1, 1)
		DrawColorModify(CModWhiteOut)
	end
end

-- 触发一个白屏/闪光效果（用于重生等场景）
function util.WhiteOut(time, fadeouttime)
	time = time or 1

	-- 设置白屏结束时间（取当前值与已有值中的较大值，实现叠加效果）
	WhiteOutEnd = math_max(CurTime() + time, WhiteOutEnd or 0)
	-- 设置淡出时间
	WhiteOutFadeTime = math_max(fadeouttime or time, WhiteOutFadeTime or 0)

	-- 注册渲染钩子，在每次屏幕空间效果渲染时调用RenderWhiteOut
	hook.Add("RenderScreenspaceEffects", "WhiteOut", RenderWhiteOut)
end
