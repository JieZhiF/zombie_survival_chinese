-- ============================================================================
-- bloodstream_sb.lua - 喷血特效（变体）：平面血渍粒子版
-- 负责：命中时喷洒 decals/blood 平面贴图粒子，粒子落地后留下血迹贴图并
--       播放血肉撞击音效，部分血滴还会二次溅射小血滴
-- ============================================================================

-- 预缓存所有碰撞音效，避免首次播放时出现卡顿
util.PrecacheSound("physics/flesh/flesh_bloody_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard1.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard2.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard3.wav")
util.PrecacheSound("physics/flesh/flesh_squishy_impact_hard4.wav")

-- ==== CollideCallbackSmall - 小血滴碰撞回调：终止粒子并播放大块血液音效 ====
local function CollideCallbackSmall(particle, hitpos, hitnormal)
    -- 已停止的粒子直接忽略，避免重复处理
    if particle:GetDieTime() == 0 then return end
    particle:SetDieTime(0)

    -- 1/3 概率播放血块撞击音效并在碰撞面留下血肉印记
    if math.random(3) == 3 then
        sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.Rand(95, 105))
        util.Decal("Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
    end
end

-- ==== CollideCallback - 主血滴碰撞回调：停止粒子、留血迹并二次溅射小血滴 ====
local function CollideCallback(oldparticle, hitpos, hitnormal)
    -- 已停止的粒子直接忽略，避免重复处理
    if oldparticle:GetDieTime() == 0 then return end
    oldparticle:SetDieTime(0)

    -- 碰撞点沿法线方向偏移，避免血迹贴图嵌入表面内部
    local pos = hitpos + hitnormal

    -- 1/3 概率播放血肉撞击音效（随机选取 4 种音效之一）
    if math.random(3) == 3 then
        sound.Play("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav", hitpos, 50, math.Rand(95, 105))
    end
    -- 在碰撞面留下血迹贴图
    util.Decal("Blood", pos, hitpos - hitnormal, ents.GetAll())

    -- 二次溅射数量随机（-4 ~ 4），非正数则不产生小血滴
    local num = math.random(-4, 4)
    if num < 1 then return end

    -- 沿碰撞法线方向给每个小血滴一个基础弹开速度
    local nhitnormal = hitnormal * 90

    local emitter = ParticleEmitter(pos)
    for i=1, num do
        -- 小血滴：平面血渍贴图，重力下落、碰撞后由 CollideCallbackSmall 收尾
        local particle = emitter:Add("decals/blood"..math.random(8), pos)
        particle:SetLighting(true)
        particle:SetVelocity(VectorRand():GetNormalized() * math.Rand(75, 150) + nhitnormal)
        particle:SetDieTime(3)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(255)
        particle:SetStartSize(math.Rand(1.5, 2.5))
        particle:SetEndSize(1.5)
        particle:SetRoll(math.Rand(-25, 25))
        particle:SetRollDelta(math.Rand(-25, 25))
        particle:SetAirResistance(5)
        particle:SetGravity(Vector(0, 0, -600))
        particle:SetCollide(true)
        particle:SetColor(255, 0, 0)
        particle:SetCollideCallback(CollideCallbackSmall)
    end
    emitter:Finish()
end

-- ==== Init - 特效初始化：按命中数据喷射主血滴 ====
function EFFECT:Init(data)
    -- 起点略微抬高，避免粒子出生在表面内部
    local pos = data:GetOrigin() + Vector(0, 0, 10)

    -- 喷射主方向（命中法线）与喷射力度
    local dir = data:GetNormal()
    local force = data:GetScale()

    local emitter = ParticleEmitter(pos)
    for i=1, data:GetMagnitude() do
        -- 在喷射方向附近随机偏移，形成锥形喷溅的血雾
        local heading = (VectorRand():GetNormalized() * 3 + dir) / 4
        local particle = emitter:Add("decals/blood"..math.random(8), pos + heading)
        particle:SetVelocity(force * math.Rand(0.8, 1) * heading)
        particle:SetDieTime(math.Rand(3, 6))
        particle:SetStartAlpha(200)
        particle:SetEndAlpha(200)
        particle:SetStartSize(math.Rand(3, 5))
        particle:SetEndSize(3)
        particle:SetRoll(math.Rand(0, 360))
        particle:SetRollDelta(math.Rand(-20, 20))
        particle:SetAirResistance(5)
        particle:SetGravity(Vector(0, 0, -600))
        particle:SetCollide(true)
        particle:SetLighting(true)
        particle:SetColor(255, 0, 0)
        particle:SetCollideCallback(CollideCallback)
    end
    emitter:Finish()
end

-- ==== Think - 特效思考：单帧粒子效果，无需持续更新 ====
function EFFECT:Think()
    return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
