-- 本文件主要用于扩展Garry's Mod中"Vector"（向量）对象的功能，为其添加了新的方法和重载了几个运算符，以方便进行特定的向量计算和操作。

-- DistanceZSkew 计算两个向量之间的距离，但在Z轴上应用一个“倾斜”或“权重”因子。
-- __pow 重载 ^ 运算符。将向量标准化（长度变为1），然后将其长度设置为指定的值。这是一个引用操作（直接修改原向量）。
-- __mod 重载 % 运算符。将向量的Z分量增加指定的值。这是一个引用操作。
-- __len 重载 # 运算符。返回向量的长度（大小）。
-- NormalizeRef 将向量自身标准化（长度变为1）并返回其自身的引用，与通常返回一个新向量的GetNormalized不同。
local meta = FindMetaTable("Vector")

function meta:DistanceZSkew(vec, skew)
	return math.sqrt((self.x - vec.x) ^ 2 + (self.y - vec.y) ^ 2 + ((self.z - vec.z) * skew) ^ 2)
end

-- ^ operator: by reference normalize and optional multiply
function meta:__pow(len)
	self:Normalize()
	if len == 1 then
		return self
	end

	self.x = self.x * len
	self.y = self.y * len
	self.z = self.z * len

	return self
end

-- % operator: by reference raise Z
function meta:__mod(z)
	self.z = self.z + z

	return self
end

-- # operator: length
function meta:__len()
	return self:Length()
end

-- Normalize self and return self (GetNormalized makes a copy)
function meta:NormalizeRef()
	self:Normalize()
	return self
end
