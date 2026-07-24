-- ============================================================================
-- DModelPanelEx - 增强型 3D 模型预览面板
-- 继承自 DModelPanel，增加 WElements 子模型/精灵渲染系统
-- 支持武器预览（含模型缩放、配件、材质覆盖等）
-- ============================================================================

local PANEL = {}

-- Helper: safe copy - 安全复制表
local deepCopy = table.FullCopy or function(t) return table.Copy(t) end

-- ============================================================================
-- Init - 初始化一些默认值
-- ============================================================================
function PANEL:Init()
	self.Entity = nil
	self.WElements = nil
	self.wRenderOrder = nil

	self.Angles = Angle(0, 0, 0)          -- 面板当前角度（用于自动旋转）
	self.AutoRotate = true                -- 自动旋转开关（默认开）
	self.RotateSpeed = 30                 -- 角速度 (degrees / second)
	self.ShowBaseModel = true             -- 是否在渲染里 Draw 主模型 (由 SetWeaponPreview 设置)
end

-- ============================================================================
-- SetModel - 设置/创建主体模型
-- ============================================================================
function PANEL:SetModel(strModelName)
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end

	if not strModelName or strModelName == "" then return end
	if not ClientsideModel then return end

	self.Entity = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY)
	if not IsValid(self.Entity) then
		self.Entity = nil
		return
	end

	self.Entity:SetNoDraw(true)

	-- 找一个合理的默认序列（如果存在）
	local iSeq = self.Entity:LookupSequence("walk")
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("Run1") end
	if iSeq <= 0 then iSeq = self.Entity:LookupSequence("walk_all") end
	if iSeq > 0 then self.Entity:ResetSequence(iSeq) end

	-- 当模型变更时，尝试自动调整摄像机
	self:AutoCam()
end

-- ============================================================================
-- AutoCam - 自动调整摄像机视角以适配模型尺寸
-- ============================================================================
function PANEL:AutoCam()
	if not IsValid(self.Entity) then return end
	local mins, maxs = self.Entity:GetRenderBounds()
	self:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
	self:SetLookAt((mins + maxs) / 2)
end

-- ========== WElements 支持 ==========

-- ============================================================================
-- SetWElements - 设置武器配件元素列表
-- ============================================================================
function PANEL:SetWElements(tab)
	self:RemoveWModels()

	if not tab then
		self.WElements = nil
		self.wRenderOrder = nil
		return
	end

	self.WElements = deepCopy(tab)
	self.wRenderOrder = nil

	if IsValid(self.Entity) then
		self:CreateWModels(self.WElements)
	end
end

-- ============================================================================
-- SetWeaponPreview - 设置武器预览数据
-- 应用 ModelScale 到 base 与 child 模型
-- ============================================================================
function PANEL:SetWeaponPreview(weptab)
    if not weptab then return end
    self.WeaponPreview = weptab
    self.ShowBaseModel = (weptab.ShowWorldModel == nil) or weptab.ShowWorldModel

    if weptab.WorldModel then
        self:SetModel(weptab.WorldModel)
    end

    -- apply ModelScale to base entity if provided
    if weptab.ModelScale and IsValid(self.Entity) then
        self.Entity:SetModelScale(weptab.ModelScale, 0)
    end

    if weptab.WElements then
        self:SetWElements(weptab.WElements)
        -- apply ModelScale to existing child models too (if any)
        if weptab.ModelScale then
            for _, v in pairs(self.WElements) do
                if IsValid(v.modelEnt) then
                    v.modelEnt:SetModelScale(weptab.ModelScale, 0)
                end
            end
        end
    else
        self:SetWElements(nil)
    end
end

-- ============================================================================
-- CreateWModels - 根据 WElements 表创建子模型/精灵
-- ============================================================================
function PANEL:CreateWModels(tab)
	if not tab or not IsValid(self.Entity) then return end

	for k, v in pairs(tab) do
		-- Model - 创建客户端模型实体
		if (v.type == "Model" and v.model and v.model ~= "" and
			(not IsValid(v.modelEnt) or v.createdModel ~= v.model) and
			string.find(v.model, "%.mdl") and file.Exists(v.model, "GAME")) then

			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_OPAQUE_ENTITY)
			if IsValid(v.modelEnt) then
				v.modelEnt:SetPos(self.Entity:GetPos())
				v.modelEnt:SetAngles(self.Entity:GetAngles())
				v.modelEnt:SetParent(self.Entity)
				v.modelEnt:SetNoDraw(true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end

		-- Sprite - 创建精灵材质
		elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and
			(not v.spriteMaterial or v.createdSprite ~= v.sprite) and
			file.Exists("materials/"..v.sprite..".vmt", "GAME")) then

			local name = v.sprite.."-"
			local params = { ["$basetexture"] = v.sprite }
			for _, j in ipairs({ "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }) do
				if v[j] then
					params["$"..j] = 1
					name = name.."1"
				else
					name = name.."0"
				end
			end

			v.createdSprite = v.sprite
			v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
		end
	end

	-- 预计算渲染顺序：Model 先，Sprite/Quad 后
	self.wRenderOrder = {}
	for key, elem in pairs(tab) do
		if elem.type == "Model" then
			table.insert(self.wRenderOrder, 1, key)
		elseif elem.type == "Sprite" or elem.type == "Quad" then
			table.insert(self.wRenderOrder, key)
		end
	end
end

-- ============================================================================
-- RemoveWModels - 移除所有子模型实体
-- ============================================================================
function PANEL:RemoveWModels()
	if not self.WElements then return end
	for _, v in pairs(self.WElements) do
		if IsValid(v.modelEnt) then
			v.modelEnt:Remove()
			v.modelEnt = nil
		end
	end
end

-- ============================================================================
-- GetBoneOrientation - 获取骨骼/附件的变换矩阵
-- 支持相对定位和递归查询
-- ============================================================================
function PANEL:GetBoneOrientation(basetab, tab, baseEnt, bone_override)
    if (tab.rel and tab.rel ~= "") then
        local v = basetab[tab.rel]
        if not v then return end
        local pos, ang = self:GetBoneOrientation(basetab, v, baseEnt)
        if not pos then return end

        pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
        ang:RotateAroundAxis(ang:Up(), v.angle.y)
        ang:RotateAroundAxis(ang:Right(), v.angle.p)
        ang:RotateAroundAxis(ang:Forward(), v.angle.r)
        return pos, ang
    else
        if not IsValid(baseEnt) then return end

        local boneName = bone_override or tab.bone
        if not boneName or boneName == "" then return end

        -- 1) 尝试骨骼
        local bone = baseEnt:LookupBone(boneName)
        if bone and bone >= 0 then
            local m = baseEnt:GetBoneMatrix(bone)
            if m then
                return m:GetTranslation(), m:GetAngles()
            end
        end

        -- 2) 尝试 attachment
        if baseEnt.LookupAttachment then
            local aid = baseEnt:LookupAttachment(boneName)
            if aid and aid > 0 then
                local att = baseEnt:GetAttachment(aid)
                if att then
                    return att.Pos, att.Ang
                end
            end
        end

        -- 3) 兼容写法：bone 可能是 "attachment_1" 这种
        if baseEnt.LookupAttachment then
            local aid = baseEnt:LookupAttachment(boneName)
            if aid and aid > 0 then
                local att = baseEnt:GetAttachment(aid)
                if att then
                    return att.Pos, att.Ang
                end
            end
        end

        return nil
    end
end


-- ============================================================================
-- RenderWElements - 渲染所有子元素
-- 确保 SetupBones、按 ModelScale 缩放 pos、以及使用与游戏中一致的旋转顺序
-- ============================================================================
function PANEL:RenderWElements(baseEnt)
    if not self.WElements or not IsValid(baseEnt) then return end

    baseEnt:SetupBones()

    local modelScale = (self.WeaponPreview and self.WeaponPreview.ModelScale) or 1

    if not self.wRenderOrder then
        self.wRenderOrder = {}
        for k,v in pairs(self.WElements) do
            if v.type == "Model" then
                table.insert(self.wRenderOrder, 1, k)
            else
                table.insert(self.wRenderOrder, k)
            end
        end
    end

    for _, name in ipairs(self.wRenderOrder) do
        local v = self.WElements[name]
        if not v then self.wRenderOrder = nil break end
        if v.hide or v.active == false then continue end

        local pos, ang
        if v.bone then
            pos, ang = self:GetBoneOrientation(self.WElements, v, baseEnt)
        else
            pos, ang = self:GetBoneOrientation(self.WElements, v, baseEnt, "ValveBiped.Bip01_R_Hand")
        end
        if not pos then continue end

        local px, py, pz = (v.pos.x or 0) * modelScale, (v.pos.y or 0) * modelScale, (v.pos.z or 0) * modelScale
        local drawpos = pos + ang:Forward() * px + ang:Right() * py + ang:Up() * pz

        if v.type == "Model" and IsValid(v.modelEnt) then
            local ang2 = Angle(ang.p, ang.y, ang.r)
            ang2:RotateAroundAxis(ang:Up(), v.angle.y)
            ang2:RotateAroundAxis(ang:Right(), v.angle.p)
            ang2:RotateAroundAxis(ang:Forward(), v.angle.r)

            v.modelEnt:SetPos(drawpos)
            v.modelEnt:SetAngles(ang2)

            local svec = Vector(1,1,1)
            if v.size then
                if type(v.size) == "number" then svec = Vector(v.size, v.size, v.size) end
                if type(v.size) == "Vector" then svec = v.size end
            end
            local matrix = Matrix()
            matrix:Scale(svec)
            v.modelEnt:EnableMatrix("RenderMultiply", matrix)

            if v.material == "" then
                v.modelEnt:SetMaterial("")
            elseif v.modelEnt:GetMaterial() ~= v.material then
                v.modelEnt:SetMaterial(v.material)
            end

            if v.skin and v.skin ~= v.modelEnt:GetSkin() then v.modelEnt:SetSkin(v.skin) end
            if v.bodygroup then
                for kbg, vbg in ipairs(v.bodygroup) do
                    if v.modelEnt:GetBodygroup(kbg) ~= vbg then
                        v.modelEnt:SetBodygroup(kbg, vbg)
                    end
                end
            end

            local col = v.color or color_white
            render.SetColorModulation(col.r/255, col.g/255, col.b/255)
            render.SetBlend((col.a or 255)/255)
            v.modelEnt:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1,1,1)

        elseif v.type == "Sprite" and v.spriteMaterial then
            render.SetMaterial(v.spriteMaterial)
            local size = v.size or {x=16,y=16}
            local col = v.color or color_white
            render.DrawSprite(drawpos, size.x or size, size.y or size, col)
        elseif v.type == "Quad" and v.draw_func then
            local ang2 = Angle(ang.p, ang.y, ang.r)
            ang2:RotateAroundAxis(ang:Up(), v.angle.y)
            ang2:RotateAroundAxis(ang:Right(), v.angle.p)
            ang2:RotateAroundAxis(ang:Forward(), v.angle.r)
            cam.Start3D2D(drawpos, ang2, v.size)
                v.draw_func(self)
            cam.End3D2D()
        end
    end
end


-- ============================================================================
-- LayoutEntity - 保留自动旋转 / 动画推进逻辑
-- ============================================================================
function PANEL:LayoutEntity(ent)
	if IsValid(ent) and ent.FrameAdvance then
		ent:FrameAdvance(FrameTime())
	end

	if self.AutoRotate and not self.Dragging then
		self.Angles.y = self.Angles.y + FrameTime() * self.RotateSpeed
	end

	if IsValid(ent) then
		ent:SetAngles(self.Angles)
	end
end

-- ============================================================================
-- Paint - 在正确的 3D 环境中先 Draw 主模型，再 Draw WElements
-- ============================================================================
function PANEL:Paint(w, h)
	if not IsValid(self.Entity) then
		return
	end

	self:LayoutEntity(self.Entity)

	local x, y = self:LocalToScreen(0, 0)

	local camPos = self.vCamPos or Vector(0,0,0)
	local lookPos = self.vLookatPos or Vector(0,0,0)
	local fov = self.fFOV or 50

	cam.Start3D(camPos, (lookPos - camPos):Angle(), fov, x, y, w, h)
		render.SuppressEngineLighting(true)
		render.SetLightingOrigin(self.Entity:GetPos())
		if self.ShowBaseModel then
			self.Entity:DrawModel()
		end

		if self.WElements then
			self:RenderWElements(self.Entity)
		end

		render.SuppressEngineLighting(false)
	cam.End3D()
end

-- ============================================================================
-- OnRemove - 清理子模型和主体模型
-- ============================================================================
function PANEL:OnRemove()
	self:RemoveWModels()
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end
end


vgui.Register("DModelPanelEx", PANEL, "DModelPanel")
