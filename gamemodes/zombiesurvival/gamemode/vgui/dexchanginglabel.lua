local PANEL = {}
//这个不知道是干啥的，所以注释有可能不对或者看不懂。但应该是作者用来改变文本的。
//注释状态：已完成，
local function empty() end

function PANEL:SetChangeFunction(func, autosize)//设置改变函数,里面参数是一个函数,返回值是一个字符串,如果autosize为true,则会自动调整大小
	self.Think = function(me)//设置Think函数,每帧都会调用
		local val = func()//调用函数
		if self.LastValue ~= val and val ~= nil then//上一个值不等于新值并且新值不为空则
			self.LastValue = val//设置上一个值为新值

			self:SetText(val)//设置文本

			if autosize then//如果autosize为true则
				self:SizeToContents()//自动调整大小
			end

			if self.OnChanged then//如果有OnChanged函数则
				self:OnChanged(val)//调用OnChanged函数
			end
		end
	end
end

function PANEL:RemoveChangeFunction()//移除改变函数
	self.Think = empty
end

function PANEL:SetChangedFunction(func)//设置改变函数,里面参数是一个函数,返回值是一个字符串
	self.OnChanged = func
end

function PANEL:RemoveChangedFunction()//移除改变函数
	self.OnChanged = empty
end

vgui.Register("DEXChangingLabel", PANEL, "DLabel")
