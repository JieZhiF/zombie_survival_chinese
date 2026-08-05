-- ============================================================================
-- weapon_zs_cameracontrol/init.lua - 监控摄像头遥控器（服务器端定义）
-- 负责：摄像头视野同步与摄像头循环切换逻辑
-- ============================================================================
-- 服务器端专用（GMod 武器文件的标准服务器入口标记）
INC_SERVER()

-- ==== SetupPlayerVisibility - 把摄像头位置加入玩家的可见区域（PVS） ====
function SWEP:SetupPlayerVisibility(pl)
	local owner = self:GetOwner()
	-- 只为武器主人扩展视野
	if owner ~= pl then return end

	local camera = self:GetCamera()
	if camera:IsValid() then
		-- 确保摄像头所在区域被服务器传给客户端
		AddOriginToPVS(camera:WorldSpaceCenter())
	end
end

-- ==== CycleCamera - 在可用摄像头间循环切换（支持正反向） ====
function SWEP:CycleCamera(reverse)
	-- 收集场上所有有效的摄像头
	local cameras = {}

	for _, camera in pairs(ents.FindByClass("prop_camera")) do
		if camera:IsValid() then
			table.insert(cameras, camera)
		end
	end

	-- 没有摄像头时不切换
	if #cameras == 0 then return end

	-- 找到当前摄像头在列表中的位置
	local index
	for i, camera in pairs(cameras) do
		if self:GetCamera() == camera then
			index = i
			break
		end
	end

	-- 当前无选中或只有一个摄像头时，选中第一个
	if not index or #cameras == 1 then
		self:SetCamera(cameras[1])
		return
	end

	-- 反向切换（上一个）/ 正向切换（下一个），越界时循环回另一端
	if reverse then
		self:SetCamera(cameras[index - 1] or cameras[#cameras])
	else
		self:SetCamera(cameras[index + 1] or cameras[1])
	end
end
