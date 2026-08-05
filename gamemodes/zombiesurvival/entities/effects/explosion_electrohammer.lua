-- ============================================================================
-- explosion_electrohammer.lua - 电磁锤修复爆炸特效（客户端）
-- 负责：在修复目标（木板/物件）的包围盒内生成 50 个蓝色电火花粒子，
--       模拟修复能量沿目标全身扩散的视觉效果
-- ============================================================================

-- ==== Init - 特效初始化：在目标包围盒内随机位置生成电火花粒子 ====
function EFFECT:Init(effectdata)
    -- 取命中的目标实体（被修复的木板或物件）
    local ent = effectdata:GetEntity()
    if not IsValid(ent) then return end

    -- 获取实体世界包围盒，作为粒子的随机生成范围
    local min, max = ent:WorldSpaceAABB()
    -- 命中法线缺失时默认向上
    local normal = effectdata:GetNormal() or Vector(0,0,1)

    local emitter = ParticleEmitter(ent:GetPos())
    emitter:SetNearClip(24, 32)

    for i = 1, 50 do
        -- Posición aleatoria dentro del bounding box
        -- 在包围盒内随机取点，让火花遍布整个修复目标
        local pos = Vector(
            math.Rand(min.x, max.x),
            math.Rand(min.y, max.y),
            math.Rand(min.z, max.z)
        )

        local particle = emitter:Add("sprites/glow04_noz", pos)
        -- 蓝色电火花：1 秒内从亮到消失，尺寸逐渐放大
        particle:SetDieTime(1)
        particle:SetColor(50, 90, 255)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(4)
        particle:SetEndSize(11)
        -- 沿法线方向飘散并叠加随机扰动，模拟电光四溅
        particle:SetVelocity((normal + VectorRand()):GetNormal() * 20)
        -- 受重力下落并带随机飘移
        particle:SetGravity(VectorRand() * 20 + Vector(0, 0, -400))
        particle:SetCollide(true)
        particle:SetBounce(0.75)
        particle:SetAirResistance(12)
    end

    emitter:Finish()
    emitter = nil
    collectgarbage("step", 64)
end

-- ==== Think - 特效思考：单帧粒子效果，无需持续更新 ====
function EFFECT:Think()
    return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end