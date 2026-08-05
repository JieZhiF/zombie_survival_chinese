-- ============================================================================
-- prop_remantler/shared.lua - 残骸重组器部署物（共享）
-- 负责：定义对象生命/废料数据的网络同步存取，以及生命归零时的破碎效果
-- ============================================================================
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

-- 不允许通过钉子解除冻结（防拆陷阱），也不接受钉子加固
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

-- 允许在打包（PackUp）模式下被收起带走
ENT.CanPackUp = true

-- 属于路障类对象，可被幽灵预览（Ghost）放置
ENT.IsBarricadeObject = true
ENT.AlwaysGhostable = true

-- ==== SetObjectHealth - 设置对象生命：归零时生成破碎物理模型 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)
	-- 生命归零且尚未标记销毁时，复制模型生成物理破碎体播放破碎动画
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 复制模型/材质/位置/皮肤/颜色生成 prop_physics，先破碎后移除
		local ent = ents.Create("prop_physics")
		if ent:IsValid() then
			ent:SetModel(self:GetModel())
			ent:SetMaterial(self:GetMaterial())
			ent:SetAngles(self:GetAngles())
			ent:SetPos(self:GetPos())
			ent:SetSkin(self:GetSkin() or 0)
			ent:SetColor(self:GetColor())
			ent:Spawn()
			ent:Fire("break", "", 0)
			ent:Fire("kill", "", 0.1)
		end
	end
end

-- ==== GetObjectHealth - 读取当前对象生命 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== SetMaxObjectHealth - 设置对象生命上限 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== GetMaxObjectHealth - 读取对象生命上限 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== SetObjectOwner - 记录放置者（认领人） ====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(0, ent)
end

-- ==== GetObjectOwner - 读取放置者（认领人） ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end

-- ==== SetScraps - 设置储存的废料数量（拆解所得，可取出为 scrap 弹药） ====
function ENT:SetScraps(scraps)
	self:SetDTInt(0, scraps)
end

-- ==== GetScraps - 读取储存的废料数量 ====
function ENT:GetScraps()
	return self:GetDTInt(0)
end

-- ==== ClearObjectOwner - 清除放置者记录（玩家离开/换队时调用） ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end
