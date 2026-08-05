-- ============================================================================
-- init.lua - 氛围实体基类（服务器）：数据驱动的拥有者职业检测
-- 负责：按子类声明的 AmbienceClassNames 判断拥有者是否为对应僵尸职业，
--       不匹配则移除自身；若子类声明 AmbienceModel 则设置实体模型
-- ============================================================================
INC_SERVER()

-- 氛围实体基类: 数据驱动的 owner 职业检测
-- 子类在 shared.lua 中声明:
--   ENT.AmbienceClassNames = {"职业名", ...}   -- 必填, 匹配则保留
--   ENT.AmbienceModel      = "models/xx.mdl"    -- 可选, 指定则设置模型

-- ==== Initialize - 初始化：关闭阴影，按需设置实体模型 ====
function ENT:Initialize()
	-- 氛围实体不投射阴影，避免与拥有者本体产生双重阴影
	self:DrawShadow(false)

	-- 子类声明了模型时设置之（如悬浮光球、骨片等视觉挂件）
	if self.AmbienceModel then
		self:SetModel(self.AmbienceModel)
	end
end

-- ==== Think - 逐帧校验拥有者职业，不匹配则移除自身 ====
function ENT:Think()
	local owner = self:GetOwner()
	-- 仅当拥有者存活且处于僵尸阵营时才校验职业
	if owner:Alive() and owner:Team() == TEAM_UNDEAD then
		local name = owner:GetZombieClassTable().Name
		-- 遍历子类声明的职业名列表，任一匹配则保留实体
		for _, classname in ipairs(self.AmbienceClassNames) do
			if name == classname then return end
		end
	end

	-- 拥有者死亡/更换阵营/职业不符：氛围实体随之移除
	self:Remove()
end
