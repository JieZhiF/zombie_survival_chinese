-- ============================================================================
-- 冰霜暗影 (Frost Shade) — BOSS僵尸职业
-- 继承自：boss_shade
-- 特点：冰霜抗性、腿部/躯干子弹免伤、半透明渲染、冰冻折射特效、
--       暗影护盾技能、死亡时触发暗影死亡特效
-- ============================================================================

-- 基础职业为"暗影"
CLASS.Base = "boss_shade"

-- 职业显示名称
CLASS.Name = "Frost Shade"
-- 翻译键名
CLASS.TranslationName = "class_frostshade"
-- 描述文本键名
CLASS.Description = "description_frostshade"
-- 控制帮助文本键名
CLASS.Help = "controls_frostshade"

-- 标记为BOSS
CLASS.Boss = true

-- 生命值
CLASS.Health = 2400
-- 移动速度
CLASS.Speed = 170

-- 击杀得分
CLASS.Points = 30

-- 绑定的武器
CLASS.SWEP = "weapon_zs_frostshade"

-- 冰霜抗性
CLASS.ResistFrost = true

-- 使用快速僵尸模型
CLASS.Model = Model("models/player/zombie_fast.mdl")

-- 缓存数学函数
local math_cos = math.cos
local math_abs = math.abs
local math_Clamp = math.Clamp
local CurTime = CurTime

-- 缩放伤害：仅子弹伤害生效，腿部和躯干部位免疫
function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	if not dmginfo:IsBulletDamage() then return true end

	if hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR or hitgroup == HITGROUP_GENERIC then
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
	end
	return true
end

-- 忽略腿部伤害
function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

-- 死亡时触发暗影死亡特效
function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	if SERVER then
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:WorldSpaceCenter())
			effectdata:SetNormal(pl:GetUp())
			effectdata:SetEntity(pl)
		util.Effect("death_shade", effectdata, nil, true)
	end
	return true
end

-- 服务端逻辑
if SERVER then
	-- 生成时创建环境音效并设置半透明渲染
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("frostshadeambience")
		pl:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	-- 伤害处理：物理碰撞免疫，更新环境音效受伤时间
	function CLASS:ProcessDamage(pl, dmginfo)
		if SERVER then
			local inflictor = dmginfo:GetInflictor()
			if inflictor:IsValid() and (inflictor:IsPhysicsModel() or inflictor.IsPhysbox) then
				return
			end
			local status = pl.status_frostshadeambience
			if status and status:IsValid() then
				status:SetLastDamaged(CurTime())
			end
		end
	end

	-- 暗影护盾技能
	function CLASS:ShadeShield(pl)
		local shadeshield = pl.ShadeShield
		local curtime = CurTime()
		if pl.NextShield and curtime <= pl.NextShield then return end

		if shadeshield and shadeshield:IsValid() then
			if curtime >= shadeshield:GetStateEndTime() then
				shadeshield:SetState(1)
				shadeshield:SetStateEndTime(curtime + 0.5)
			end
		elseif pl:IsOnGround() and not pl:IsPlayingTaunt() then
			local wep = pl:GetActiveWeapon()
			if wep:IsValid() and curtime > wep:GetNextPrimaryFire() and curtime > wep:GetNextSecondaryFire() then
				local status = pl:GiveStatus("frostshadeshield")
				if status and status:IsValid() then
					status:SetStateEndTime(curtime + 0.5)
					for _, ent in pairs(ents.FindByClass("env_frostshadecontrol")) do
						if ent:IsValid() and ent:GetOwner() == pl then
							ent:Remove()
							return
						end
					end
				end
			end
		end
	end

	-- 备用使用键触发暗影护盾
	function CLASS:AltUse(pl)
		self:ShadeShield(pl)
	end
end

-- 客户端在此处结束
if not CLIENT then return end

-- 击杀图标（暗影版本2）
CLASS.Icon = "zombiesurvival/killicons/shadev2"
-- 图标颜色（淡蓝色）
CLASS.IconColor = Color(0, 190, 255)

local nodraw = false
local matWhite = Material("models/debug/debugwhite")
local matRefract = Material("models/spawn_effect")

-- 渲染前特效处理
function CLASS:PreRenderEffects(pl)
    if render.SupportsVertexShaders_2_0() then
        local normal = pl:GetUp()
        render.EnableClipping(true)
        render.PushCustomClipPlane(normal, normal:Dot(pl:GetPos() + normal * 16))
    end

    if nodraw then return end

    local red = 0
    local status = pl.status_frostshadeambience
    if status and status:IsValid() then
        -- 根据受伤时间计算红色程度
        local t = (CurTime() - status:GetLastDamaged()) * 3
        local clamped = math.Clamp(t, 0, 1)
        red = 1 - (clamped ^ 3)
    end

    -- 设置冰霜色调：根据受伤程度混合蓝色和红色
    render.SetColorModulation(red, 0.7 * (1 - red), 1 - red)
    render.SetBlend(0.5 + (math.abs(math.cos(CurTime())) ^ 2) * 0.1)

    render.SuppressEngineLighting(true)
    render.ModelMaterialOverride(matWhite)
end

-- 渲染后特效处理
function CLASS:PostRenderEffects(pl)
    if render.SupportsVertexShaders_2_0() then
        render.PopCustomClipPlane()
        render.EnableClipping(false)
    end

    if nodraw then return end

    -- 恢复材质与渲染状态
    render.SetColorModulation(1, 1, 1)
    render.SetBlend(1)
    render.SuppressEngineLighting(false)
    render.ModelMaterialOverride()

    -- 折射特效（半透明冰霜效果）
    if render.SupportsPixelShaders_2_0() then
        render.UpdateRefractTexture()
        matRefract:SetFloat("$refractamount", 0.01)
        render.ModelMaterialOverride(matRefract)
        nodraw = true
        pl:DrawModel()
        nodraw = false
        render.ModelMaterialOverride()
    end
end

-- 绘制前：移除贴花并调用渲染前特效
function CLASS:PrePlayerDraw(pl)
    pl:RemoveAllDecals()
    self:PreRenderEffects(pl)
end

-- 绘制后：调用渲染后特效
function CLASS:PostPlayerDraw(pl)
    self:PostRenderEffects(pl)
end
