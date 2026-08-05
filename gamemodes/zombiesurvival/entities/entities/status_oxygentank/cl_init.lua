-- ============================================================================
-- status_oxygentank/cl_init.lua - 氧气罐状态实体（客户端）
-- 负责：将氧气罐模型挂载到拥有者背部脊柱骨骼，水下时播放呼吸音效
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：为本地玩家创建水下呼吸音效 ====
function ENT:Initialize()
	-- 不绘制阴影，模型缩放 0.5 倍
	self:DrawShadow(false)
	self:SetModelScale(0.5, 0)

	-- 只对本地玩家创建环境音效：水下呼吸声
	if self:GetOwner() == MySelf then
		self.AmbientSound = CreateSound(self, "player/breathe1.wav")
	end
end

-- ==== Think - 音效管理：本地玩家头部完全浸水时播放呼吸声 ====
function ENT:Think()
	if self.AmbientSound then
		-- 水位大于等于 3（完全没入水中）时播放，否则停止
		if MySelf:WaterLevel() >= 3 then
			self.AmbientSound:Play()
		else
			self.AmbientSound:Stop()
		end
	end
end

-- ==== OnRemove - 移除时停止呼吸音效 ====
function ENT:OnRemove()
	if self.AmbientSound then
		self.AmbientSound:Stop()
	end
end

-- ==== Draw - 将氧气罐模型贴合到拥有者背部脊柱骨骼 ====
function ENT:Draw()
	local owner = self:GetOwner()
	-- 拥有者无效，或本地玩家（未开启第三人称）时不绘制
	if not owner:IsValid() or owner == MySelf and not owner:ShouldDrawLocalPlayer() then return end

	-- 玩家手持氧气罐武器时不额外绘制（避免重复显示）
	local wep = owner:GetActiveWeapon()
	if wep:IsValid() and wep:GetClass() == "weapon_zs_t_oxygentank" then return end

	-- 定位脊柱骨骼，找不到则放弃绘制
	local boneid = owner:LookupBone("ValveBiped.Bip01_Spine2")
	if not boneid or boneid <= 0 then return end

	-- 获取骨骼世界坐标并旋转模型，使其贴合背部
	local bonepos, boneang = owner:GetBonePositionMatrixed(boneid)

	self:SetPos(bonepos + boneang:Forward() + boneang:Right() * 4)
	boneang:RotateAroundAxis(boneang:Right(), 270)
	boneang:RotateAroundAxis(boneang:Up(), 180)
	self:SetAngles(boneang)

	-- 拥有者处于暗影形态（ShadowMan）时半透明绘制
	if owner.ShadowMan then
		render.SetBlend(0.2)
	end

	self:DrawModel()

	-- 恢复不透明度
	if owner.ShadowMan then
		render.SetBlend(1)
	end
end
