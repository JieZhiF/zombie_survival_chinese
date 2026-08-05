-- ============================================================================
-- hit_stone.lua - 石头命中特效（客户端）
-- 负责：石头攻击命中时播放岩石/混凝土碎裂音效，并生成 5 个随机
--       缩放的客户端石头模型，沿法线方向被物理力弹飞后落地消失
-- ============================================================================

-- ==== Init - 特效初始化：播放碎裂音效并生成飞溅的碎石模型 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal() * -1

	-- 播放岩石滚动与混凝土碎裂两种音效
	sound.Play("ambient/materials/rock4.wav", pos, 77, math.Rand(95, 105))
	sound.Play("physics/concrete/concrete_break2.wav", pos, 77, math.Rand(110, 120))

	local maxbound = Vector(3, 3, 3)
	local minbound = maxbound * -1
	-- 生成 5 块小型碎石，赋予向外弹飞的物理力
	for i=1, 5 do
		-- 以法线方向为主叠加随机偏移，得到碎石飞散方向
		local dir = (norm * 2 + VectorRand()) / 3
		dir:Normalize()

		local ent = ClientsideModel("models/props_junk/Rock001a.mdl", RENDERGROUP_OPAQUE)
		if ent:IsValid() then
			ent:SetModelScale(math.Rand(0.2, 0.5), 0)
			ent:SetPos(pos + dir * 6)
			ent:PhysicsInitBox(minbound, maxbound)
			ent:SetCollisionBounds(minbound, maxbound)

			-- 为碎石设置岩石材质并施加向外冲击力
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMaterial("rock")
				phys:ApplyForceOffset(ent:GetPos() + VectorRand() * 5, dir * math.Rand(300, 800))
			end

			-- 6~10 秒后自动移除碎石
			SafeRemoveEntityDelayed(ent, math.Rand(6, 10))
		end
	end
end

-- 纯模型特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
