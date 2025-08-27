-- dmodelpanelex.lua
local PANEL = {}

-- Helper: safe copy
local deepCopy = table.FullCopy or function(t) return table.Copy(t) end

-- 初始化一些默认值
function PANEL:Init()
	self.Entity = nil
	self.WElements = nil
	self.wRenderOrder = nil

	self.Angles = Angle(0, 0, 0)          -- 面板当前角度（用于自动旋转）
	self.AutoRotate = true                -- 自动旋转开关（默认开）
	self.RotateSpeed = 30                 -- 角速度 (degrees / second)
	self.ShowBaseModel = true             -- 是否在渲染里 Draw 主模型 (由 SetWeaponPreview 设置)
end

-- 设置/创建主体模型（不负责是否 Draw，由 ShowBaseModel 决定）
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

function PANEL:AutoCam()
	if not IsValid(self.Entity) then return end
	local mins, maxs = self.Entity:GetRenderBounds()
	self:SetCamPos(mins:Distance(maxs) * Vector(0.75, 0.75, 0.5))
	self:SetLookAt((mins + maxs) / 2)
end

-- ========== WElements 支持 ==========

function PANEL:SetWElements(tab)
	-- 清除旧模型
	self:RemoveWModels()

	if not tab then
		self.WElements = nil
		self.wRenderOrder = nil
		return
	end

	self.WElements = deepCopy(tab)
	self.wRenderOrder = nil

	-- 若已有主体实体则直接创建 models
	if IsValid(self.Entity) then
		self:CreateWModels(self.WElements)
	end
end

-- 在 SetWeaponPreview 里确保应用 ModelScale 到 base 与 child
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

function PANEL:CreateWModels(tab)
	if not tab or not IsValid(self.Entity) then return end

	for k, v in pairs(tab) do
		-- Model
		if (v.type == "Model" and v.model and v.model ~= "" and
			(not IsValid(v.modelEnt) or v.createdModel ~= v.model) and
			string.find(v.model, "%.mdl") and file.Exists(v.model, "GAME")) then

			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_OPAQUE_ENTITY)
			if IsValid(v.modelEnt) then
				v.modelEnt:SetPos(self.Entity:GetPos())
				v.modelEnt:SetAngles(self.Entity:GetAngles())
				v.modelEnt:SetParent(self.Entity) -- 绑定到主体以便骨骼/相对变换一致
				v.modelEnt:SetNoDraw(true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end

		-- Sprite
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

function PANEL:RemoveWModels()
	if not self.WElements then return end
	for _, v in pairs(self.WElements) do
		if IsValid(v.modelEnt) then
			v.modelEnt:Remove()
			v.modelEnt = nil
		end
	end
end

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

        -- 找不到就返回 nil
        return nil
    end
end


-- RenderWElements：确保 SetupBones、按 ModelScale 缩放 pos、以及使用与游戏中一致的旋转顺序
function PANEL:RenderWElements(baseEnt)
    if not self.WElements or not IsValid(baseEnt) then return end

    -- 确保骨骼是最新的
    baseEnt:SetupBones()

    local modelScale = (self.WeaponPreview and self.WeaponPreview.ModelScale) or 1

    -- 重建渲染顺序（如果需要）
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

        -- 把 v.pos 按 modelScale 缩放，避免缩放导致偏移错误
        local px, py, pz = (v.pos.x or 0) * modelScale, (v.pos.y or 0) * modelScale, (v.pos.z or 0) * modelScale
        local drawpos = pos + ang:Forward() * px + ang:Right() * py + ang:Up() * pz

        if v.type == "Model" and IsValid(v.modelEnt) then
            -- 这里使用与 prop_weapon 相同的旋转顺序（保证与游戏一致）
            local ang2 = Angle(ang.p, ang.y, ang.r)
            ang2:RotateAroundAxis(ang:Up(), v.angle.y)
            ang2:RotateAroundAxis(ang:Right(), v.angle.p)
            ang2:RotateAroundAxis(ang:Forward(), v.angle.r)

            v.modelEnt:SetPos(drawpos)
            v.modelEnt:SetAngles(ang2)

            -- 如果 weptab 有 ModelScale，我们在创建时已经 SetModelScale 到 modelEnt，
            -- 此处确保 size 自身仍然生效（size * 1 为默认）
            local svec = Vector(1,1,1)
            if v.size then
                if type(v.size) == "number" then svec = Vector(v.size, v.size, v.size) end
                if type(v.size) == "Vector" then svec = v.size end
            end
            -- overall scale = modelScale (applied by SetModelScale) * svec (matrix)
            local matrix = Matrix()
            matrix:Scale(svec)
            v.modelEnt:EnableMatrix("RenderMultiply", matrix)

            -- 材质/皮肤处理按原逻辑
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


-- LayoutEntity：保留自动旋转 / 动画推进逻辑
function PANEL:LayoutEntity(ent)
	-- 动画推进（如果需要）
	if IsValid(ent) and ent.FrameAdvance then
		ent:FrameAdvance(FrameTime())
	end

	-- 自动旋转（当没有拖拽交互时）
	if self.AutoRotate and not self.Dragging then
		self.Angles.y = self.Angles.y + FrameTime() * self.RotateSpeed
	end

	-- 应用角度到实体（仅用于预览位置）
	if IsValid(ent) then
		ent:SetAngles(self.Angles)
	end
end

-- Paint：在正确的 3D 环境中先 Draw 主模型（如果需要），再 Draw WElements
function PANEL:Paint(w, h)
	if not IsValid(self.Entity) then
		-- nothing to draw
		return
	end

	-- 让父类更新一些内部变量（如果有），并执行我们自己的 LayoutEntity
	self:LayoutEntity(self.Entity)

	-- 转换为屏幕坐标区域，使用 DModelPanel 的内部相机参数
	local x, y = self:LocalToScreen(0, 0)

	-- DModelPanel 内部通常使用 self.vCamPos / self.vLookatPos / self.fFOV
	-- 这些在 SetCamPos/SetLookAt/SetFOV 时被设置。我们直接使用它们。
	local camPos = self.vCamPos or Vector(0,0,0)
	local lookPos = self.vLookatPos or Vector(0,0,0)
	local fov = self.fFOV or 50

	cam.Start3D(camPos, (lookPos - camPos):Angle(), fov, x, y, w, h)
		render.SuppressEngineLighting(true)
		render.SetLightingOrigin(self.Entity:GetPos())
		-- 主模型是否显示由 SetWeaponPreview 决定（ShowBaseModel）
		if self.ShowBaseModel then
			self.Entity:DrawModel()
		end

		-- 不论主模型是否绘制，都尝试渲染 WElements（若存在）
		if self.WElements then
			self:RenderWElements(self.Entity)
		end

		render.SuppressEngineLighting(false)
	cam.End3D()
end

function PANEL:OnRemove()
	self:RemoveWModels()
	if IsValid(self.Entity) then
		self.Entity:Remove()
		self.Entity = nil
	end
end


vgui.Register("DModelPanelEx", PANEL, "DModelPanel")
