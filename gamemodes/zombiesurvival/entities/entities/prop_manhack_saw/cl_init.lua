-- ============================================================================
-- prop_manhack_saw/cl_init.lua - 电锯人形机器人（客户端）
-- 负责：创建高速旋转的锯片子模型并每帧旋转绘制；
--       播放旋转循环音效，音量随飞行速度提升
-- ============================================================================
INC_CLIENT()

-- ==== CreateSubModel - 创建锯片子模型并挂接到主体 ====
function ENT:CreateSubModel()
	local ent = ClientsideModel("models/props_junk/sawblade001a.mdl", RENDERGROUP_OPAQUE)
	if ent:IsValid() then
		ent:SetOwner(self)
		ent:SetParent(self)
		ent:SetPos(self:LocalToWorld(Vector(0, 0, -1.5)))
		ent:SetNoDraw(true)
		ent:SetModelScale(0.8, 0)
		ent:Spawn()
		self.SubModel = ent
	end
end

-- ==== RemoveSubModel - 移除锯片子模型 ====
function ENT:RemoveSubModel()
	if self.SubModel and self.SubModel:IsValid() then
		self.SubModel:Remove()
	end
end

-- ==== DrawSubModel - 每帧旋转锯片并绘制 ====
function ENT:DrawSubModel()
	if self.SubModel and self.SubModel:IsValid() then
		local ang = self:GetAngles()
		-- 以竖直轴为中心高速旋转（每帧 2000 度/秒的角速度）
		ang:RotateAroundAxis(ang:Up(), (CurTime() * 2000) % 360)

		self.SubModel:SetRenderAngles(ang)
		self.SubModel:DrawModel()
	end
end

-- ==== CreateAmbientSounds - 创建旋转与锯片两种循环音效 ====
function ENT:CreateAmbientSounds()
	self.AmbientSound = CreateSound(self, "ambient/machines/spin_loop.wav")
	self.AmbientSound2 = CreateSound(self, "npc/manhack/mh_blade_loop1.wav")
end

-- ==== PlayAmbientSounds - 播放音效：主音量随飞行速度增大 ====
function ENT:PlayAmbientSounds()
	-- 旋转声：音量随飞行速度线性提升（上限 140），制造高速呼啸感
	self.AmbientSound:PlayEx(0.5, math.min(100 + self:GetVelocity():Length() * 0.2, 140))
	-- 锯片声：音调随正弦波动轻微起伏
	self.AmbientSound2:PlayEx(0.3, 85 + math.sin(CurTime()))
end
