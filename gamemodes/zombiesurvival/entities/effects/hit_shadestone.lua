-- ============================================================================
-- hit_shadestone.lua - 暗影石命中特效（客户端）
-- 负责：暗影石攻击命中时播放岩石碰撞音效，并生成 8 个随机缩放的
--       客户端石头模型，沿法线方向被物理力弹飞后落地消失
-- ============================================================================

-- ==== Init - 特效初始化：播放岩石音效并生成飞溅的碎石模型 ====
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local norm = data:GetNormal() * -1

	-- 播放两种岩石碰撞音效增强打击感
	sound.Play("ambient/materials/rock4.wav", pos, 77, math.Rand(65, 85))
	sound.Play("physics/concrete/boulder_impact_hard" .. math.random(1,4) .. ".wav", pos, 77, math.Rand(85, 95))

	local maxbound = Vector(3, 3, 3)
	local minbound = maxbound * -1
	-- 生成 8 块随机大小、随机朝向的碎石，赋予弹飞物理力
	for i=1, 8 do
		-- 以法线方向为主叠加随机偏移，得到碎石飞散方向
		local dir = (norm * 2 + VectorRand()) / 3
		dir:Normalize()

		local ent = ClientsideModel("models/props_junk/Rock001a.mdl", RENDERGROUP_OPAQUE)
		if ent:IsValid() then
			ent:SetModelScale(math.Rand(0.5, 0.9), 0)
			ent:SetPos(pos + dir * 6)
			ent:PhysicsInitBox(minbound, maxbound)
			ent:SetCollisionBounds(minbound, maxbound)

			-- 为碎石设置岩石材质并施加随机方向的冲击力
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetMaterial("rock")
				phys:ApplyForceOffset(ent:GetPos() + VectorRand() * 5, dir * math.Rand(-600, 600))
			end

			-- 4~8 秒后自动移除碎石
			SafeRemoveEntityDelayed(ent, math.Rand(4, 8))
		end
	end
end

-- 纯模型特效，无需逐帧更新
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
