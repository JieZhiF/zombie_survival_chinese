-- ============================================================================
-- 受折磨的怨灵 (Tormented Wraith) — 僵尸职业
-- 继承自：wraith
-- 特点：低血量触发狂暴模式（加速+特殊音效）、
--       按住速度键减速、自定义死亡音效
-- ============================================================================

-- 基础职业为"怨灵"
CLASS.Base = "wraith"

-- 职业显示名称
CLASS.Name = "Tormented Wraith"
-- 翻译键名
CLASS.TranslationName = "class_tormented_wraith"
-- 描述文本键名
CLASS.Description = "description_tormented_wraith"
-- 控制帮助文本键名
CLASS.Help = "controls_tormented_wraith"

-- 生命值
CLASS.Health = 150
-- 击杀得分
CLASS.Points = CLASS.Health/GM.NoHeadboxZombiePointRatio
-- 移动速度
CLASS.Speed = 150

-- 出现波次
CLASS.Wave = 2 / 6

-- 绑定的武器
CLASS.SWEP = "weapon_zs_tormentedwraith"

-- 移动逻辑
function CLASS:Move(pl, move)
	local wep = pl:GetActiveWeapon()
	if not wep.GetTormented then return end

	-- 狂暴模式下加速
	if CurTime() < wep:GetTormented() + 2 then
		move:SetMaxSpeed(225)
		move:SetMaxClientSpeed(225)
	end

	-- 按住速度键减速
	if pl:KeyDown(IN_SPEED) then
		move:SetMaxSpeed(40)
		move:SetMaxClientSpeed(40)
	end
end

-- 自定义死亡音效（多重播放）
function CLASS:PlayDeathSound(pl)
	for i=1, 4 do
		pl:EmitSound("zombiesurvival/wraithdeath4.ogg", 75, math.random(80, 140), 0.6, CHAN_AUTO + i)
	end
	return true
end

-- 处理动画事件
function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL, true)
		return ACT_INVALID
	elseif event == PLAYERANIMEVENT_RELOAD then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
		return ACT_INVALID
	end
end

-- 服务端逻辑
if SERVER then
	-- 伤害处理：低血量触发狂暴
	function CLASS:ProcessDamage(pl, dmginfo)
		local activ = pl:GetActiveWeapon()
		if not activ.GetTormented then return end

		local attacker, dmg = dmginfo:GetAttacker(), dmginfo:GetDamage()
		if not attacker:IsValidLivingHuman() or CurTime() < activ:GetTormented() + 8 then return end

		if pl:Health() - dmg < 90 then
			-- 播放多层次警报音效
			for i = 0, 3 do
				timer.Simple(0.04 * i,
					function() if pl:IsValidLivingZombie() then pl:EmitSound("npc/stalker/go_alert2a.wav", 75, 120 + i*12, 0.4, CHAN_WEAPON + i) end
				end)
			end
			activ:SetTormented(CurTime())
		end
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标
CLASS.Icon = "zombiesurvival/killicons/wraithv2"
-- 图标颜色（淡绿色）
CLASS.IconColor = Color(190, 255, 190)

-- 绘制前
function CLASS:PrePlayerDraw(pl)
	local alpha = self:GetAlpha(pl)
	if alpha == 0 then return true end
	render.SetBlend(alpha)
	render.SetColorModulation(0.025, 0.15, 0.065)
	render.SuppressEngineLighting(true)
end
