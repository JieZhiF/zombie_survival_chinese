-- ============================================================================
-- shared.lua - 探照灯道具（共享）：声明实体属性与耐久/归属/光照位置
-- 负责：定义探照灯作为路障物/可打包道具的属性，及灯光朝向的换算
-- ============================================================================
-- 动画实体类型
ENT.Type = "anim"
-- 半透明渲染组（灯光光晕半透明绘制）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- 不可被钉子冻结/钉住（作为建筑类道具的例外）
ENT.m_NoNailUnfreeze = true
ENT.NoNails = true

-- 可以打包带走
ENT.CanPackUp = true

-- 属于路障类道具
ENT.IsBarricadeObject = true
-- 放置阶段始终显示幽灵预览
ENT.AlwaysGhostable = true

-- ==== SetObjectHealth - 写入耐久：归零时标记销毁 ====
function ENT:SetObjectHealth(health)
	self:SetDTFloat(0, health)

	if health <= 0 and not self.Destroyed then
		self.Destroyed = true
	end
end

-- ==== GetObjectHealth - 读取当前耐久 ====
function ENT:GetObjectHealth()
	return self:GetDTFloat(0)
end

-- ==== SetMaxObjectHealth - 写入最大耐久 ====
function ENT:SetMaxObjectHealth(health)
	self:SetDTFloat(1, health)
end

-- ==== GetMaxObjectHealth - 读取最大耐久 ====
function ENT:GetMaxObjectHealth()
	return self:GetDTFloat(1)
end

-- ==== SetObjectOwner - 写入持有者（DT 同步到客户端） ====
function ENT:SetObjectOwner(ent)
	self:SetDTEntity(0, ent)
end

-- ==== GetObjectOwner - 读取持有者 ====
function ENT:GetObjectOwner()
	return self:GetDTEntity(0)
end

-- ==== ClearObjectOwner - 清空持有者 ====
function ENT:ClearObjectOwner()
	self:SetObjectOwner(NULL)
end

-- ==== GetSpotLightPos - 灯光世界坐标：模型前方 -2、上方 15 单位处 ====
function ENT:GetSpotLightPos()
	return self:LocalToWorld(Vector(-2, 0, 15))
end

-- ==== GetSpotLightAngles - 灯光朝向：绕自身上轴旋转 180 度对准照射方向 ====
function ENT:GetSpotLightAngles()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 180)
	return ang
end
