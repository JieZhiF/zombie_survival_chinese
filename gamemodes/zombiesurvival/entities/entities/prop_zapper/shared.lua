-- ============================================================================
-- prop_zapper/shared.lua - 电击陷阱（共享）
-- 负责：可部署的电击器：消耗弹药对敌人造成电击伤害并附带腿部伤害，
--       有耐久与弹药上限；共享端提供耐久/弹药/所有者/电击冷却的
--       DT 读写接口，耐久归零时生成破碎残骸
-- ============================================================================
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 可打包收起，打包耗时 4 秒
ENT.CanPackUp = true
ENT.PackUpTime = 4
-- 弹药上限与得分倍率
ENT.MaxAmmo = 300
ENT.PointsMultiplier = 1.25
-- 电击伤害与腿部额外伤害
ENT.Damage = 25
ENT.LegDamage = 10

-- 不可被钉子解除冻结/加固
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

-- 免疫子弹伤害
ENT.IgnoreBullets = true

-- 不属于路障物体（不影响路障数量），放置时始终允许虚影预览
ENT.IsBarricadeObject = false
ENT.AlwaysGhostable = true

-- ==== SetObjectHealth - 设置耐久；归零时生成破碎残骸并标记销毁 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(1, health)
	if health <= 0 and not self.Destroyed then
		self.Destroyed = true

		-- 生成同外观的物理残骸，让其破碎后消失
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

-- ==== GetObjectHealth - 读取当前耐久 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== SetMaxObjectHealth - 设置耐久上限 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(2, health)
end

-- ==== GetMaxObjectHealth - 读取耐久上限 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(2)
end

-- ==== GetNextZap - 读取下一次电击时间 ====
function ENT:GetNextZap()
	return self:GetDTFloat(0)
end

-- ==== SetNextZap - 设置下一次电击时间（电击冷却） ====
function ENT:SetNextZap(time)
	self:SetDTFloat(0, time)
end

-- ==== SetObjectOwner - 记录放置者（DT 同步） ====
function ENT:SetObjectOwner(owner)
	self:SetDTEntity(0, owner)
end

-- ==== GetObjectOwner - 读取放置者 ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end

-- ==== SetAmmo - 设置剩余弹药 ====
function ENT:SetAmmo(ammo)
	self:SetDTInt(0, ammo)
end

-- ==== GetAmmo - 读取剩余弹药 ====
function ENT:GetAmmo()
	return self:GetDTInt(0)
end

-- ==== ClearObjectOwner - 清空放置者记录 ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end
