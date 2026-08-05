-- ============================================================================
-- DEXChangingLabel - 动态文本标签组件
-- 提供一个能自动检测值变化并更新显示的 DLabel 扩展
-- 每帧调用提供的函数，在返回值变化时自动更新标签文本
-- ============================================================================
-- 区域地图（VGUI 四字段）
-- [区域] 值变化检测
-- [位置] SetChangeFunction() / 覆写的 Think()
-- [作用] 每帧调用提供的函数，返回值变化时更新标签文本
-- [常改] 变化判定逻辑、自动调整大小开关
--
-- [区域] 变化回调
-- [位置] SetChangedFunction() / RemoveChangedFunction()
-- [作用] 文本变化时通知外部回调
-- [常改] 回调触发时机、回调清除方式
-- ============================================================================

local PANEL = {}

local function empty() end

-- ============================================================================
-- SetChangeFunction - 设置值变化检测函数
-- @func: 返回要显示文本的函数（每帧被调用）
-- @autosize: 如果为true，值变化时自动调整标签大小
-- ============================================================================
function PANEL:SetChangeFunction(func, autosize)
	self.Think = function(me)
		local val = func()
		if self.LastValue ~= val and val ~= nil then
			self.LastValue = val

			self:SetText(val)

			if autosize then
				self:SizeToContents()
			end

			if self.OnChanged then
				self:OnChanged(val)
			end
		end
	end
end

-- ============================================================================
-- RemoveChangeFunction - 移除值变化检测
-- ============================================================================
function PANEL:RemoveChangeFunction()
	self.Think = empty
end

-- ============================================================================
-- SetChangedFunction - 设置值变化时的回调函数
-- ============================================================================
function PANEL:SetChangedFunction(func)
	self.OnChanged = func
end

-- ============================================================================
-- RemoveChangedFunction - 移除值变化回调
-- ============================================================================
function PANEL:RemoveChangedFunction()
	self.OnChanged = empty
end

vgui.Register("DEXChangingLabel", PANEL, "DLabel")
