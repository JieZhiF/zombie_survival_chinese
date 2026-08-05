-- ============================================================================
-- vile_bloated_zombie/shared.lua - 恶劣肿胀僵尸 (Vile Bloated Zombie) 共享定义
-- 负责：职业属性（继承肿胀僵尸）、解锁波次、可进化为毒僵尸、
--       胖子模型与受伤/死亡音效（双端加载）
-- ============================================================================

-- 继承肿胀僵尸 (Bloated Zombie) 的基础属性
CLASS.Base = "bloated_zombie"

-- 职业显示名称
CLASS.Name = "Vile Bloated Zombie"
-- 翻译键名
CLASS.TranslationName = "class_vile_bloated_zombie"
-- 描述文本键名
CLASS.Description = "description_vile_bloated_zombie"
-- 控制帮助文本键名
CLASS.Help = "controls_vile_bloated_zombie"

-- 进化目标：毒僵尸 (Poison Zombie)
CLASS.BetterVersion = "Poison Zombie"

-- 解锁波次（总波数的 3/6，中期解锁）
CLASS.Wave = 3 / 6

-- 生命值
CLASS.Health = 350
-- 移动速度（缓慢）
CLASS.Speed = 135

-- 击杀得分（按人形僵尸得分比例计算）
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

-- 绑定的武器
CLASS.SWEP = "weapon_zs_vilebloatedzombie"

-- 胖子模型
CLASS.Model = Model("models/player/fatty/fatty.mdl")

-- 缓存随机数与字符串格式化函数
local math_random = math.random
local string_format = string.format

-- ==== PlayPainSound - 播放受伤音效（随机播放毒僵尸叫声，带 0.5 秒冷却） ====
function CLASS:PlayPainSound(pl)
	pl:EmitSound(string_format("npc/zombie_poison/pz_idle%d.wav", math_random(2, 3)), 72, 75)
	pl.NextPainSound = CurTime() + 0.5

	return true
end

-- ==== PlayDeathSound - 播放死亡音效（鱼龙低吼） ====
function CLASS:PlayDeathSound(pl)
	pl:EmitSound("npc/ichthyosaur/water_growl5.wav", 72, 60)

	return true
end
