-- ============================================================================
-- hit_medical.lua - 医疗命中特效（客户端）
-- 负责：医疗针命中目标时播放蒸汽释放音效，喷出黄色治疗烟雾粒子，
--       并生成 5 个缓缓上升的治疗十字图标，飘散后自然消失
-- ============================================================================

-- 治疗十字图标材质与蒸汽音效路径
local HealIcon = Material("zombiesurvival/killicons/medpower_ammo_icon")
local GasSound = "ambient/machines/steam_release_2.wav"

-- ==== Init - 特效初始化：播放音效、喷烟雾并生成治疗图标 ====
function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local ent = data:GetEntity()
    local magnitude = data:GetMagnitude()

    -- 音效挂在目标实体上（无效时挂特效自身），音调拉高模拟喷射气流
    if IsValid(ent) then
        ent:EmitSound(GasSound, 75, 150, 1)
    else
        self:EmitSound(GasSound, 75, 150, 1)
    end

    local emitter = ParticleEmitter(pos)
    emitter:SetNearClip(16, 24)

    -- 40 个黄色烟雾粒子：沿随机方向缓缓飘散，模拟治疗蒸汽
    for i = 1, 40 do
        local particle = emitter:Add("particle/smokestack", pos)
        if particle then
            local ang = AngleRand()
            particle:SetVelocity(ang:Forward() * math.Rand(10, 40))
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(20)
            particle:SetColor(255, 220, math.random(50, 100))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-1, 1))
            particle:SetGravity(Vector(0, 0, 15))
            particle:SetAirResistance(50)
        end
    end
    emitter:Finish()

    -- 生成 5 个治疗十字图标：初始带随机速度，寿命 1.5 秒，由 Think/Render 驱动
    local duration = 1.5
    self.HealSprites = {}
    for i = 1, 5 do
        table.insert(self.HealSprites, {Pos = pos + VectorRand() * 4,Vel = VectorRand() * 10 + Vector(0, 0, 30), LifeTime = duration, DieTime = CurTime() + duration, Size = math.random(2,9)})
    end
end

-- ==== Think - 更新图标位置与速度，全部消亡后结束特效 ====
function EFFECT:Think()
    -- 未初始化（Init 未成功）时直接结束
    if not self.HealSprites then return false end

    -- 图标带初速上浮，随后受反向重力减速下落，超时后移除
    for k, spr in pairs(self.HealSprites) do
        spr.Pos = spr.Pos + spr.Vel * FrameTime()
        spr.Vel = spr.Vel + Vector(0, 0, -30) * FrameTime()
        if CurTime() > spr.DieTime then
		    self.HealSprites[k] = nil
		end
    end

    return next(self.HealSprites) ~= nil 
end

-- ==== Render - 逐帧绘制存活的治疗十字图标并渐隐 ====
function EFFECT:Render()
    if not self.HealSprites then return end

    render.SetMaterial(HealIcon)
    for _, spr in pairs(self.HealSprites) do
    	-- 剩余寿命比例决定透明度，图标随时间平滑淡出
    	local remaining = spr.DieTime - CurTime()
		local frac = math.Clamp(remaining / spr.LifeTime, 0, 1)
		local alpha = 255 * frac
        render.DrawSprite(spr.Pos, spr.Size, spr.Size, Color(0, 255, 0, alpha))
    end
end