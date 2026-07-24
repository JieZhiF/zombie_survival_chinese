-- ============================================================================
-- DEXChangingLabel - 动态文本标签组件（别名注册）
-- 与 dexchanginglabel.lua 功能相同，以 DEXChangingLabel 为基类注册
-- 提供一个能自动检测值变化并更新显示的 DLabel 扩展
-- ============================================================================

local PANEL = {}

local function empty() end

-- ============================================================================
-- SetChangeFunction - 设置值变化检测函数
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

vgui.Register("DEXChangingLabel", PANEL, "DEXChangingLabel")
