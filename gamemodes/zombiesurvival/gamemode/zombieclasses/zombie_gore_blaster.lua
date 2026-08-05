-- ============================================================================
-- zombie_gore_blaster.lua - 碎尸喷射僵尸 (Gore Blaster Zombie) 职业
-- 负责：初始解锁的高移速脆皮职业，死亡时碎尸爆炸并造成范围伤害，
--       可进化为化学爆破者；不复活、无受伤处理、红色皮肤渲染
-- ============================================================================

-- 继承普通僵尸的基础属性
CLASS.Base = "zombie"

-- 职业显示名称
CLASS.Name = "Gore Blaster Zombie"
-- 翻译键名
CLASS.TranslationName = "class_zombie_gore_blaster"
-- 描述文本键名
CLASS.Description = "description_zombie_gore_blaster"
-- 控制帮助文本键名
CLASS.Help = "controls_zombie_gore_blaster"

-- 进化目标：化学爆破者 (Chem Burster)
CLASS.BetterVersion = "Chem Burster"

-- 初始解锁波次
CLASS.Wave = 0
-- 默认解锁
CLASS.Unlocked = true

-- 生命值
CLASS.Health = 220
-- 移动速度
CLASS.Speed = 180
-- 死亡后不复活
CLASS.Revives = false

-- 击杀得分（按人形僵尸得分比例计算）
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 绑定的武器
CLASS.SWEP = "weapon_zs_zombie_gore_blaster"

-- ==== PlayPainSound - 播放受伤音效（带 0.5 秒冷却） ====
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie/zombie_pain"..math.random(6)..".wav", 75, math.random(87, 92))

	pl.NextPainSound = CurTime() + .5

	return true
end

-- ==== PlayDeathSound - 播放死亡音效 ====
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/zombie/zombie_die"..math.random(3)..".wav", 70, math.random(87, 92))

	return true
end

-- 服务端逻辑
if SERVER then

-- ==== ReviveCallback - 禁止复活 ====
function CLASS:ReviveCallback(pl, attacker, dmginfo)
	return false
end

-- ==== ProcessDamage - 不参与自定义受伤处理 ====
function CLASS:ProcessDamage(pl, dmginfo)
	return false
end

-- ==== OnKilled - 死亡时碎尸爆炸并造成范围伤害 ====
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	-- 自杀时不触发碎尸爆炸
	if suicide then return end

	local pos = pl:WorldSpaceCenter()

	-- 播放碎尸喷射特效
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("gore_blast", effectdata, true)
		effectdata:SetEntity(pl)
	util.Effect("gib_player", effectdata, true, true)

	-- 临时无敌后对周围造成爆炸伤害（避免误伤自己）
	pl:GodEnable()
	util.BlastDamageEx(pl:GetActiveWeapon() or pl, pl, pos, 105, 3, DMG_GENERIC, 0.7)
	pl:GodDisable()

	return true
end

end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/zombie"
-- 图标颜色（红色）
CLASS.IconColor = Color(255, 0, 0)

-- 皮肤材质
local matSkin = Material("models/Zombie_Classic/Zombie_Classic_sheet.vtf")

-- ==== PrePlayerDraw - 绘制前覆盖皮肤材质并施加红色调 ====
function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	render.SetColorModulation(1, 0, 0)
end

-- ==== PostPlayerDraw - 绘制后恢复材质与默认颜色 ====
function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end
