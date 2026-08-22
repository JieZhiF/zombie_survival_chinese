-- cl_camera.lua
-- 镜头层：应用武器镜头后坐力（角度弹跳/滚转/FOV 冲击弹簧）——ARC9 风格射击手感
-- 此前 sh_recoil 计算的 CamRecoilCurrent/CamFOV_Vel 无消费方，本文件补齐渲染应用

function SWEP:CalcView(ply, pos, ang, fov)
	local ft = FrameTime()
	if ft <= 0 or ft > 0.1 then return end

	-- [FOV 弹簧] 半隐式欧拉积分：射击瞬间收缩，随后回弹稳定
	self.CamFOVOffset = self.CamFOVOffset or 0
	self.CamFOV_Vel = self.CamFOV_Vel or 0

	local stiffness = self.CamRecoilFOVStiffness or 200
	local damping = self.CamRecoilFOVDamping or 12

	self.CamFOV_Vel = self.CamFOV_Vel + (-self.CamFOVOffset * stiffness - self.CamFOV_Vel * damping) * ft
	self.CamFOVOffset = self.CamFOVOffset + self.CamFOV_Vel * ft

	-- [镜头弹跳] 应用 Think 层平滑好的角度后坐力与滚转
	local cam = self.CamRecoilCurrent
	local outang = Angle(ang.p, ang.y, ang.r)
	if cam then
		outang.p = outang.p + (cam.p or 0)
		outang.y = outang.y + (cam.y or 0)
	end
	outang.roll = outang.roll + (self.CamRecoilRollVal or 0)

	return pos, outang, fov + self.CamFOVOffset
end
