-- ============================================================================
-- wild_poison_zombie/shared.lua - 野性毒僵尸 (Wild Poison Zombie) 共享定义
-- 负责：职业属性（继承毒僵尸）、解锁波次、击杀得分与受伤音效（双端加载）
-- ============================================================================

-- 继承毒僵尸 (Poison Zombie) 的基础属性
CLASS.Base = "poison_zombie"

-- 职业显示名称
CLASS.Name = "Wild Poison Zombie"
-- 翻译键名
CLASS.TranslationName = "class_wild_poison_zombie"
-- 描述文本键名
CLASS.Description = "description_wild_poison_zombie"
-- 控制帮助文本键名（沿用毒僵尸的说明）
CLASS.Help = "controls_poison_zombie"

-- 解锁波次（总波数的 5/6，后期解锁）
CLASS.Wave = 5 / 6

-- 生命值
CLASS.Health = 460
-- 绑定的武器
CLASS.SWEP = "weapon_zs_wildpoisonzombie"

-- 击杀得分（按毒僵尸得分比例计算）
CLASS.Points = CLASS.Health/GM.PoisonZombiePointRatio

-- 缓存随机数函数
local math_random = math.random

-- ==== PlayPainSound - 播放受伤音效（随机播放毒僵尸受击音，带 0.5 秒冷却） ====
function CLASS:PlayPainSound(pl)
	pl:EmitSound("npc/zombie_poison/pz_pain"..math_random(3)..".wav", 74, math.random(88, 95))
	pl.NextPainSound = CurTime() + 0.5

	return true
end
