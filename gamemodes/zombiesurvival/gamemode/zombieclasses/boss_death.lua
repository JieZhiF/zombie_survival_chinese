-- ============================================================================
-- 死神 (Death) — BOSS僵尸职业
-- 继承自影子 (Shade)，保留其半透明幽灵渲染；武器为改版镰刀
-- ============================================================================

-- 继承影子 BOSS 的基础属性与渲染
CLASS.Base = "boss_shade"

-- 职业显示名称
CLASS.Name = "Death"
-- 翻译键名
CLASS.TranslationName = "class_death"
-- 描述文本键名
CLASS.Description = "description_death"
-- 控制帮助文本键名
CLASS.Help = "controls_death"

-- 标记为BOSS
CLASS.Boss = true

-- 生命值
CLASS.Health = 2400
-- 移动速度
CLASS.Speed = 165

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_deathscythe"

-- 缓存的动画常量
local ACT_HL2MP_IDLE_MELEE2 = ACT_HL2MP_IDLE_MELEE2
local ACT_HL2MP_RUN_MELEE2 = ACT_HL2MP_RUN_MELEE2
local ACT_HL2MP_IDLE_MAGIC = ACT_HL2MP_IDLE_MAGIC
local ACT_INVALID = ACT_INVALID
local PLAYERANIMEVENT_RELOAD = PLAYERANIMEVENT_RELOAD

-- 计算主要活动动画：
-- 传送时使用魔法姿势（武器已隐藏）；走路/待机使用 melee2 持刀姿势
function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsTeleporting and wep:IsTeleporting() then
		return ACT_HL2MP_IDLE_MAGIC, -1
	end

	if velocity:Length2DSqr() <= 1 then
		return ACT_HL2MP_IDLE_MELEE2, -1
	end

	return ACT_HL2MP_RUN_MELEE2, -1
end

-- 更新动画：传送时定格在魔法姿势，其余时间沿用影子基类的脉动效果
function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsTeleporting and wep:IsTeleporting() then
		pl:SetPlaybackRate(0)
		pl:SetCycle(0.5)
		return true
	end

	return self.BaseClass.UpdateAnimation(self, pl, velocity, maxseqgroundspeed)
end

-- 处理动画事件：屏蔽 R 键触发的僵尸嚎叫（换弹手势）
-- 左键攻击事件仍由基类处理为 melee2 挥砍手势
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_RELOAD then
		return ACT_INVALID
	end

	return self.BaseClass.DoAnimationEvent(self, pl, event, data)
end

-- 服务端逻辑
if SERVER then
	-- 覆盖冲刺技能：不再施放影子护盾（避免继承 Shade 的护盾技能）
	function CLASS:AltUse(pl) end
end