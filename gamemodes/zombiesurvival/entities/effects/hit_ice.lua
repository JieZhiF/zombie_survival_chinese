-- ============================================================================
-- hit_ice.lua - 冰冻命中特效（客户端）
-- 负责：冰系攻击命中时播放混凝土碎裂与玻璃破碎音效，喷射旋转的淡蓝
--       冰晶碎片与白色/蓝色冰雾，并生成多个带物理的蓝色冰石块飞散
-- ============================================================================

-- ==== Init - 特效初始化：喷射冰晶与冰雾并生成物理冰石块 ====
function EFFECT:Init(data)
	-- 命中位置与破碎主方向（法线取反）
	local pos = data:GetOrigin()
	local norm = data:GetNormal() * -1


	-- 播放混凝土碎裂音效（高频）与大型玻璃破碎音效，表现冰块炸裂
	sound.Play("physics/concrete/concrete_break"..math.random(2,3)..".wav", pos, 75, math.Rand(130, 140))
	sound.Play("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", pos, 75, math.Rand(160, 180))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)

	-- 12~18 块淡蓝色冰晶碎片：沿破碎方向锥形飞出，带随机旋转并受重力弹跳
	for i=1, math.random(12, 18) do
		local Size = math.Rand(3, 5)
		local RandDarkness = math.Rand(0.8, 1.0)
		local dir = (norm * 2 + VectorRand()) / 3
		dir:Normalize()

		particle = emitter:Add("particles/balloon_bit", pos + VectorRand() * 6)
		particle:SetVelocity(dir * math.Rand(150, 250))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(3, 5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(100)
		particle:SetStartSize(Size)
		particle:SetEndSize(Size * 0.25)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetGravity(Vector(0, 0, -400))
		particle:SetColor(145 * RandDarkness, 230 * RandDarkness, 255 * RandDarkness)
		particle:SetCollide(true)
		particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))
		particle:SetBounce(0.45)
	end
	-- 6 个白色大冰雾团向四周快速膨胀，模拟寒气迸发
	for i=1, 6 do
		particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand():GetNormal() * 190)
		particle:SetDieTime(math.Rand(0.7, 0.85))
		particle:SetStartAlpha(math.Rand(50, 70))
		particle:SetStartSize(math.Rand(100,120))
		particle:SetEndSize(math.Rand(205, 210))
		particle:SetRoll(math.Rand(-360, 360))
		particle:SetRollDelta(math.Rand(-4.5, 4.5))
		particle:SetColor(255, 255, 255)
	end
	-- 12 个蓝色冰雾团高速膨胀，为冰爆补充冷色
	for i=1, 12 do
		particle = emitter:Add("particles/smokey", pos)
		particle:SetVelocity(VectorRand():GetNormal() * 240)
		particle:SetDieTime(math.Rand(0.3, 0.6))
		particle:SetStartAlpha(math.Rand(90, 110))
		particle:SetStartSize(1)
		particle:SetEndSize(math.Rand(160, 190))
		particle:SetRoll(math.Rand(-360, 360))
		particle:SetRollDelta(math.Rand(-4.5, 4.5))
		particle:SetColor(40, 160, 255)
	end

	emitter:Finish() emitter = nil collectgarbage("step", 64)

	-- 6~8 个客户端冰石块模型：半透明蓝色渲染，沿破碎方向飞出并带物理碰撞
	local maxbound = Vector(3, 3, 3)
	local minbound = maxbound * -1
	for i=1, math.random(6,8) do
		local dir = (norm * 2 + VectorRand()) / 3
		dir:Normalize()

		local ent = ClientsideModel("models/props_junk/Rock001a.mdl", RENDERGROUP_OPAQUE)
		if ent:IsValid() then
			-- 缩放、半透明蓝色材质与碰撞盒设置
			ent:SetModelScale(math.Rand(0.6, 0.9), 0)
			ent:SetMaterial("models/shadertest/shader2")
			ent:SetColor(Color(0, 150, 255, 255))
			ent:SetPos(pos + dir * 6)
			ent:PhysicsInitBox(minbound, maxbound)
			ent:SetCollisionBounds(minbound, maxbound)

			-- 赋予岩石材质并向破碎方向施加冲击力
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMaterial("rock")
				phys:ApplyForceCenter(dir * math.Rand(200, 300))
			end

			-- 6~10 秒后移除冰石块
			SafeRemoveEntityDelayed(ent, math.Rand(6, 10))
		end
	end
end

-- ==== Think - 特效思考：一次性粒子效果，无需持续更新 ====
function EFFECT:Think()
	return false
end

-- ==== Render - 无自定义渲染，粒子由引擎粒子系统绘制 ====
function EFFECT:Render()
end
