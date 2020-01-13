---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 28.12.2019 23:20
---

do

    my_locale = nil

    LOCALE_LIST = {
        ["ruRU"] = {
            PHYSICAL_ATTACK_PARAM = "Физическая атака",
            PHYSICAL_DEFENCE_PARAM = 'Физическая защита',
            MAGICAL_ATTACK_PARAM    = 'Магическая атака',
            MAGICAL_SUPPRESSION_PARAM = 'Подавление магии',

            CRIT_CHANCE_PARAM         = 'Критический шанс',
            CRIT_MULTIPLIER_PARAM     = 'Критический множитель',

            PHYSICAL_BONUS_PARAM      = 'Физический урон',
            ICE_BONUS_PARAM           = 'Урон от льда',
            FIRE_BONUS_PARAM          = 'Урон от огня',
            LIGHTNING_BONUS_PARAM     = 'Урон от молнии',
            POISON_BONUS_PARAM        = 'Урон от яда',
            ARCANE_BONUS_PARAM        = 'Урон от тайной магии',
            DARKNESS_BONUS_PARAM      = 'Урон от тьмы',
            HOLY_BONUS_PARAM          = 'Урон от святости',

            ALL_RESIST_PARAM          = 'Сопротивления',
            PHYSICAL_RESIST_PARAM     = 'Сопротивление физ атакам',
            ICE_RESIST_PARAM          = 'Сопротивление холоду',
            FIRE_RESIST_PARAM         = 'Сопротивление огню',
            LIGHTNING_RESIST_PARAM    = 'Сопротивление молнии',
            POISON_RESIST_PARAM       = 'Сопротивление ядам',
            ARCANE_RESIST_PARAM       = 'Сопротивление тайной магии',
            DARKNESS_RESIST_PARAM     = 'Сопротивление тьме',
            HOLY_RESIST_PARAM         = 'Сопротивление святости',

            HP_REGEN_PARAM            = 'Восстановление здоровья',
            MP_REGEN_PARAM            = 'Восстановление ресурса',

            HP_VALUE_PARAM            = 'Здоровье',
            MP_VALUE_PARAM            = 'Ресурс',

            STR_STAT_PARAM            = 'Сила',
            AGI_STAT_PARAM            = 'Ловкость',
            INT_STAT_PARAM            = 'Разум',
            VIT_STAT_PARAM            = 'Выносливость',

            MELEE_DAMAGE_REDUCTION_PARAM  = 'Урон от атак ближнего боя',
            RANGE_DAMAGE_REDUCTION_PARAM  = 'Урон от атак дальнего боя',
            CONTROL_REDUCTION_PARAM       = 'Снижение времени контроля',

            ATTACK_SPEED_PARAM            = 'Скорость атаки',
            CAST_SPEED_PARAM              = 'Скорость заклинаний',
            MOVING_SPEED_PARAM            = 'Скорость бега',

            BLOCK_CHANCE_PARAM            = 'Шанс блока',
            BLOCK_ABSORB_PARAM            = 'Поглощение урона',


            REFLECT_DAMAGE_PARAM   = 'Отражение урона',
            REFLECT_MELEE_DAMAGE_PARAM   = 'Отражение урона ближнего боя',
            REFLECT_RANGE_DAMAGE_PARAM   = 'Отражение урона дальнего боя',

            HP_PER_HIT_PARAM   = 'Здоровье за атаку',
            MP_PER_HIT_PARAM   = 'Ресурса за атаку',


            ITEM_TYPE_WEAPON_NAME = "Оружие",
            ITEM_TYPE_ARMOR_NAME      = "Броня",
            ITEM_TYPE_JEWELRY_NAME    = "Бижутерия",
            ITEM_TYPE_OFFHAND_NAME    = "Альтернативное оружие",
            ITEM_TYPE_CONSUMABLE_NAME = "Расходуемое",
            ITEM_TYPE_GEM_NAME        = "Камень",

            BOW_WEAPON_NAME            = "Лук",
            BLUNT_WEAPON_NAME          = "Булава",
            GREATBLUNT_WEAPON_NAME     = "Двуручная булава",
            SWORD_WEAPON_NAME          = "Меч",
            GREATSWORD_WEAPON_NAME     = "Двуручный меч",
            AXE_WEAPON_NAME            = "Топор",
            GREATAXE_WEAPON_NAME       = "Двуручный топор",
            DAGGER_WEAPON_NAME         = "Кинжал",
            STAFF_WEAPON_NAME          = "Посох",
            JAWELIN_WEAPON_NAME        = "Копье",
            HEAD_ARMOR_NAME            = "Шлем",
            CHEST_ARMOR_NAME           = "Нагрудник",
            LEGS_ARMOR_NAME            = "Сапоги",
            HANDS_ARMOR_NAME           = "Перчатки",
            RING_JEWELRY_NAME          = "Кольцо",
            NECKLACE_JEWELRY_NAME      = "Ожерелье",
            THROWING_KNIFE_WEAPON_NAME = "Метательный нож",

            PHYSICAL_ATTRIBUTE_NAME     = "Физический",
            FIRE_ATTRIBUTE_NAME         = "Огненный",
            ICE_ATTRIBUTE_NAME          = "Ледяной",
            LIGHTNING_ATTRIBUTE_NAME    = "Молния",
            POISON_ATTRIBUTE_NAME       = "Яд",
            ARCANE_ATTRIBUTE_NAME       = "Тайна",
            DARKNESS_ATTRIBUTE_NAME     = "Тьма",
            HOLY_ATTRIBUTE_NAME         = "Свет",

            SKILL_PANEL_TOOLTIP_NAME = "Умения",
            SKILL_PANEL_TOOLTIP_DESCRIPTION = "Настройка и просмотр всех умений",

            SKILL_CATEGORY_LIGHTNING = "Молнии",
            SKILL_CATEGORY_FIRE = "Огонь",
            SKILL_CATEGORY_ICE = "Лед",
            SKILL_CATEGORY_ARCANE = "Тайная магия",
            SKILL_CATEGORY_FIGHTING_MASTERY = "Боебое мастерство",
            SKILL_CATEGORY_BATTLE_ADVANTAGE = "Боевое преимущество",
            SKILL_CATEGORY_INNER_STRENGTH = "Внутренние силы",

            SKILL_CATEGORY_LIGHTNING_ADVANCED = "Умения молнии: ",
            SKILL_CATEGORY_FIRE_ADVANCED = "Умения огня: ",
            SKILL_CATEGORY_ICE_ADVANCED = "Умения льда: ",
            SKILL_CATEGORY_ARCANE_ADVANCED = "Умения тайной магии: ",
            SKILL_CATEGORY_FIGHTING_MASTERY_ADVANCED = "Умения боевого мастерства: ",
            SKILL_CATEGORY_BATTLE_ADVANTAGE_ADVANCED = "Умения боевого преимущества: ",
            SKILL_CATEGORY_INNER_STRENGTH_ADVANCED = "Умения внутренних сил: ",

            SKILL_PANEL_LVL_TEXT = "Уровень: ",
            SKILL_PANEL_UNBIND = "Убрать",

            INVENTORY_PANEL_TOOLTIP_NAME = "Инвентарь",
            INVENTORY_PANEL_TOOLTIP_DESCRIPTION =  "Содержит все ваши вещи и экипировку",

            DAMAGE_UI = "Урон: ",
            DAMAGE_TYPE_UI = "Тип урона: ",
            DEFENCE_UI = "Защита: ",
            SUPPRESSION_UI = "Подавление: ",

            ADDITIONAL_INFO_UI = "|nДополнительные свойства:|n",
            AUGMENTS_UI = "|nАугментации:|n",
            SLOTS_UI = "|nГнезда:|n",

            STAT_PANEL_TOOLTIP_NAME = "Характеристики",
            STAT_PANEL_TOOLTIP_DESCRIPTION =  "Повышение и отслеживание характеристик",

            STAT_PANEL_STR = "Сила: ",
            STAT_PANEL_INT = "Интеллект: ",
            STAT_PANEL_VIT = "Стойкость: ",
            STAT_PANEL_AGI = "Ловкость: ",

            STAT_PANEL_PHYS_ATTACK = "Физ. урон: ",
            STAT_PANEL_PHYS_DEFENCE = "Защита: ",
            STAT_PANEL_MAG_ATTACK = "Маг. урон: ",
            STAT_PANEL_MAG_DEFENCE = "Подавление: ",
            STAT_PANEL_ATTACK_SPEED = "Атак в сек.: ",
            STAT_PANEL_CRIT_CHANCE = "Крит. Шанс: ",

            STAT_PANEL_FIRE = "Огонь: ",
            STAT_PANEL_PHYSICAL = "Физ.: ",
            STAT_PANEL_ICE = "Лед: ",
            STAT_PANEL_LIGHTNING = "Молния: ",
            STAT_PANEL_DARKNESS = "Тьма: ",
            STAT_PANEL_HOLY = "Свет: ",
            STAT_PANEL_POISON = "Яд: ",
            STAT_PANEL_ARCANE = "Тайное: ",

            WORN_DECL_HE = "Изношенный ",
            WORN_DECL_SHE = "Изношенная ",
            WORN_DECL_THEY = "Изношенные ",
            WORN_DECL_IT = "Изношенное ",

            FINE_DECL_HE = "Качественный ",
            FINE_DECL_SHE = "Качественная ",
            FINE_DECL_THEY = "Качественные ",
            FINE_DECL_IT = "Качественное ",

            EXCELLENT_DECL_HE = "Превосходный ",
            EXCELLENT_DECL_SHE = "Превосходная ",
            EXCELLENT_DECL_THEY = "Превосходные ",
            EXCELLENT_DECL_IT = "Превосходное ",

            IDEAL_DECL_HE = "Безупречный ",
            IDEAL_DECL_SHE = "Безупречная ",
            IDEAL_DECL_THEY = "Безупречные ",
            IDEAL_DECL_IT = "Безупречное ",

            ITEM_SUFFIX_ANGER = " Злости",
            ITEM_SUFFIX_FURY = " Ярости",
            ITEM_SUFFIX_CONCENTRATION = " Концентрации",
            ITEM_SUFFIX_PRECISION = " Точности",
            ITEM_SUFFIX_ICE_WIZARD = " Ледяного Колдуна",
            ITEM_SUFFIX_FIRE_WIZARD = " Огненного Колдуна",
            ITEM_SUFFIX_LIGHTNING_WIZARD = " Электрического Колдуна",
            ITEM_SUFFIX_SLAYER = " Убийцы",
            ITEM_SUFFIX_TRICKSTER = " Обманщика",
            ITEM_SUFFIX_ROCK = " Скалы",
            ITEM_SUFFIX_KNIGHT = " Рыцаря",
            ITEM_SUFFIX_MYSTERY = " Загадки",
            ITEM_SUFFIX_KNOWLEDGE = " Знаний",

            GENERIC_SWORD_NAME_1 = "необработанный клинок",
            GENERIC_SWORD_NAME_2 = "короткий меч",
            GENERIC_SWORD_NAME_3 = "рунический клинок",
            GENERIC_SWORD_NAME_4 = "широкий меч",

            GENERIC_GREATSWORD_NAME_1 = "варварский разрезатель",
            GENERIC_GREATSWORD_NAME_2 = "нож великанов",

            GENERIC_AXE_NAME_1 = "широкий топор",
            GENERIC_AXE_NAME_2 = "зазубренный топор",
            GENERIC_AXE_NAME_3 = "стальной топор",

            GENERIC_GREATAXE_NAME_1 = "огромный резак",

            GENERIC_BLUNT_NAME_1 = "древняя булава",
            GENERIC_BLUNT_NAME_2 = "дубина",
            GENERIC_BLUNT_NAME_3 = "шипованная палица",
            GENERIC_BLUNT_NAME_4 = "цеп",

            GENERIC_GREATBLUNT_NAME_1 = "большая шипованная палица",
            GENERIC_GREATBLUNT_NAME_2 = "мифриловый молот",

            GENERIC_DAGGER_NAME_1 = "изогнутый нож",
            GENERIC_DAGGER_NAME_2 = "позолоченный нож",
            GENERIC_DAGGER_NAME_3 = "нож",
            GENERIC_DAGGER_NAME_4 = "заточка",
            GENERIC_DAGGER_NAME_5 = "разделочный нож",

            GENERIC_STAFF_NAME_1 = "Сверток Природы",
            GENERIC_STAFF_NAME_2 = "огненный скипетр",
            GENERIC_STAFF_NAME_3 = "Нефритовый Свет",
            GENERIC_STAFF_NAME_4 = "Лунный Свет",
            GENERIC_STAFF_NAME_5 = "Путы Мира",

            GENERIC_BOW_NAME_1 = "Позолоченное Древо",
            GENERIC_BOW_NAME_2 = "длинный лук",
            GENERIC_BOW_NAME_3 = "грубый лук",
            GENERIC_BOW_NAME_4 = "лук разведчика",
            GENERIC_BOW_NAME_5 = "тяжелый лук",
            GENERIC_BOW_NAME_6 = "Рог",

            GENERIC_CHEST_NAME_1 = "композитный нагрудник",
            GENERIC_CHEST_NAME_2 = "Воронье крыло",
            GENERIC_CHEST_NAME_3 = "укрепленный нагрудник",
            GENERIC_CHEST_NAME_4 = "панцирь",
            GENERIC_CHEST_NAME_5 = "легкая броня",
            GENERIC_CHEST_NAME_6 = "тяжелая броня",
            GENERIC_CHEST_NAME_7 = "стальная броня",
            GENERIC_CHEST_NAME_8 = "роба",
            GENERIC_CHEST_NAME_9 = "крепкий доспех",
            GENERIC_CHEST_NAME_10 = "бронированный нагрудник",
            GENERIC_CHEST_NAME_11 = "кираса",
            GENERIC_CHEST_NAME_12 = "составной нагрудник",
            GENERIC_CHEST_NAME_13 = "Сияние Ночи",


            GENERIC_HANDS_NAME_1 = "меховые перчатки",
            GENERIC_HANDS_NAME_2 = "кожанные перчатки",
            GENERIC_HANDS_NAME_3 = "кольчужные перчатки",
            GENERIC_HANDS_NAME_4 = "латные перчатки",

            GENERIC_LEGS_NAME_1 = "походные сапоги",
            GENERIC_LEGS_NAME_2 = "сандали",
            GENERIC_LEGS_NAME_3 = "кожанные сандали",
            GENERIC_LEGS_NAME_4 = "укрепленные сандали",
            GENERIC_LEGS_NAME_5 = "латные сапоги",

            GENERIC_HEAD_NAME_1 = "латный шлем",
            GENERIC_HEAD_NAME_2 = "демоническая каска",
            GENERIC_HEAD_NAME_3 = "рогатый шлем",
            GENERIC_HEAD_NAME_4 = "шлем фанатиков",
            GENERIC_HEAD_NAME_5 = "накидка",
            GENERIC_HEAD_NAME_6 = "легкий шлем",
            GENERIC_HEAD_NAME_7 = "стальной шлем",
            GENERIC_HEAD_NAME_8 = "шлем охотника на драконов",
            GENERIC_HEAD_NAME_9 = "укрепленный шлем",
            GENERIC_HEAD_NAME_10 = "каска юстициария",
            GENERIC_HEAD_NAME_11 = "королевский шлем",

            GENERIC_RING_NAME_1 = "адамантитовое кольцо",
            GENERIC_RING_NAME_2 = "позолоченное кольцо",
            GENERIC_RING_NAME_3 = "рыцарская печатка",
            GENERIC_RING_NAME_4 = "фамильный перстень",
            GENERIC_RING_NAME_5 = "золотое кольцо",
            GENERIC_RING_NAME_6 = "адамантитовое кольцо",
            GENERIC_RING_NAME_7 = "почерневшее кольцо",
            GENERIC_RING_NAME_8 = "арканитовый перстень",
            GENERIC_RING_NAME_9 = "жестокое кольцо",
            GENERIC_RING_NAME_10 = "руническое кольцо",
            GENERIC_RING_NAME_11 = "заиневшее кольцо",

            GENERIC_NECKLACE_NAME_1 = "подвеска с камнем",
            GENERIC_NECKLACE_NAME_2 = "серебрянный амулет",
            GENERIC_NECKLACE_NAME_3 = "древний амулет",
            GENERIC_NECKLACE_NAME_4 = "четки колдуна",
            GENERIC_NECKLACE_NAME_5 = "зачарованная подвеска",
            GENERIC_NECKLACE_NAME_6 = "заряженный амулет",
            GENERIC_NECKLACE_NAME_7 = "изумрудная подвеска",
            GENERIC_NECKLACE_NAME_8 = "рубиновая подвеска",
            GENERIC_NECKLACE_NAME_9 = "сапфировая подвеска",


            ITEM_NAME_RAT_HUNTER = 'Охотник на крыс',
            ITEM_SPEC_DESCRIPTION_RAT_HUNTER = "Даже у крысоловов был легендарный лук, коего желали все охотники на крыс",

            ITEM_NAME_BOOT_OF_COWARD = 'Сапог труса',
            ITEM_SPEC_DESCRIPTION_BOOT_OF_COWARD = "Владелец этого сапога применял секретную тактику своего знатного рода, передававшуюся в течении 300 лет. До поры до времени...",
            ITEM_LEG_DESCRIPTION_BOOT_OF_COWARD = "Каждый противник неподалеку, повышает скорость передвижения на 3%% до максимума в 25%%",

            ITEM_NAME_WITCH_MASTERY = "Мастерство Ведьмы",
            ITEM_SPEC_DESCRIPTION_WITCH_MASTERY = "Принадлежал очень древней ведьме. Впитал в себя часть заклинаний крови, которыми может поделиться.",
            ITEM_LEG_DESCRIPTION_WITCH_MASTERY = "Каждое произнесенное заклинание увеличивает силу магии на 10%%, однако взамен пожирает 5%% здоровья",

            ITEM_NAME_DARK_CROWN = "Темная Корона",
            ITEM_SPEC_DESCRIPTION_DARK_CROWN = "Хочешь сопротивляться тьме - стань тьмой сам",

            ITEM_NAME_RITUAL_DAGGER = "Ритуальный Кинжал",
            ITEM_LEG_DESCRIPTION_RITUAL_DAGGER = "При атаке вы накапливаете эффекты Хаоса. Накопив 15 эффектов, сила и скорость атаки на короткое время сильно повышаются, но на это время регенерация здоровья идет в обратную сторону.",
            ITEM_SPEC_DESCRIPTION_RITUAL_DAGGER = "Сила, заточенная в этом клинке раскрывается с каждым порезом. И пусть тот кто ею завладеет, справится с ней",


            ITEM_NAME_ACOLYTE_MANTLE = "Мантия Аколита",
            ITEM_SPEC_DESCRIPTION_ACOLYTE_MANTLE = "Идеальное решение что бы уйти в себя",


            ITEM_NAME_SMORC_PICKAXE = "Кирка Сморка",
            ITEM_SPEC_DESCRIPTION_SMORC_PICKAXE = "Легенды гласят, что шахтёр Сморк наповал косил ей врагов",
        },
        ["enUS"] = {
            PHYSICAL_ATTACK_PARAM = "Physical attack",
            PHYSICAL_DEFENCE_PARAM = 'Physical defence',
            MAGICAL_ATTACK_PARAM    = 'Magical attack',
            MAGICAL_SUPPRESSION_PARAM = 'Magic suppression',

            CRIT_CHANCE_PARAM         = 'Critical chance',
            CRIT_MULTIPLIER_PARAM     = 'Critical multiplier',

            PHYSICAL_BONUS_PARAM      = 'Physical damage',
            ICE_BONUS_PARAM           = 'Cold damage',
            FIRE_BONUS_PARAM          = 'Fire damage',
            LIGHTNING_BONUS_PARAM     = 'Lightning damage',
            POISON_BONUS_PARAM        = 'Poison damage',
            ARCANE_BONUS_PARAM        = 'Arcane damage',
            DARKNESS_BONUS_PARAM      = 'Darkness damage',
            HOLY_BONUS_PARAM          = 'Holy damage',

            ALL_RESIST_PARAM          = 'Resistances',
            PHYSICAL_RESIST_PARAM     = 'Physical resistance',
            ICE_RESIST_PARAM          = 'Cold resistance',
            FIRE_RESIST_PARAM         = 'Fire resistance',
            LIGHTNING_RESIST_PARAM    = 'Lightning resistance',
            POISON_RESIST_PARAM       = 'Poison resistance',
            ARCANE_RESIST_PARAM       = 'Arcane resistance',
            DARKNESS_RESIST_PARAM     = 'Darkness resistance',
            HOLY_RESIST_PARAM         = 'Holy resistance',

            HP_REGEN_PARAM            = 'Health regeneration',
            MP_REGEN_PARAM            = 'Resource regeneration',

            HP_VALUE_PARAM            = 'Health',
            MP_VALUE_PARAM            = 'Resource',

            STR_STAT_PARAM            = 'Strength',
            AGI_STAT_PARAM            = 'Agility',
            INT_STAT_PARAM            = 'Intelligence',
            VIT_STAT_PARAM            = 'Vitality',

            MELEE_DAMAGE_REDUCTION_PARAM  = 'Melee damage',
            RANGE_DAMAGE_REDUCTION_PARAM  = 'Range damage',
            CONTROL_REDUCTION_PARAM       = 'Control resistance',

            ATTACK_SPEED_PARAM            = 'Attack speed',
            CAST_SPEED_PARAM              = 'Cast speed',
            MOVING_SPEED_PARAM            = 'Moving speed',

            BLOCK_CHANCE_PARAM            = 'Block chance',
            BLOCK_ABSORB_PARAM            = 'Block damage reduction',


            REFLECT_DAMAGE_PARAM   = 'Damage reflection',
            REFLECT_MELEE_DAMAGE_PARAM   = 'Melee damage reflection',
            REFLECT_RANGE_DAMAGE_PARAM   = 'Range damage reflection',

            HP_PER_HIT_PARAM   = 'Health per hit',
            MP_PER_HIT_PARAM   = 'Resource per hit',


            ITEM_TYPE_WEAPON_NAME = "Weapon",
            ITEM_TYPE_ARMOR_NAME      = "Armor",
            ITEM_TYPE_JEWELRY_NAME    = "Jewelry",
            ITEM_TYPE_OFFHAND_NAME    = "Alternate",
            ITEM_TYPE_CONSUMABLE_NAME = "Consumable",
            ITEM_TYPE_GEM_NAME        = "Gem",

            BOW_WEAPON_NAME            = "Bow",
            BLUNT_WEAPON_NAME          = "Blunt",
            GREATBLUNT_WEAPON_NAME     = "Twohanded blunt",
            SWORD_WEAPON_NAME          = "Sword",
            GREATSWORD_WEAPON_NAME     = "Twohanded sword",
            AXE_WEAPON_NAME            = "Axe",
            GREATAXE_WEAPON_NAME       = "Twohanded axe",
            DAGGER_WEAPON_NAME         = "Dagger",
            STAFF_WEAPON_NAME          = "Staff",
            JAWELIN_WEAPON_NAME        = "Jawelin",
            HEAD_ARMOR_NAME            = "Head",
            CHEST_ARMOR_NAME           = "Chest",
            LEGS_ARMOR_NAME            = "Boots",
            HANDS_ARMOR_NAME           = "Glows",
            RING_JEWELRY_NAME          = "Ring",
            NECKLACE_JEWELRY_NAME      = "Necklace",
            THROWING_KNIFE_WEAPON_NAME = "Throwing knife",

            PHYSICAL_ATTRIBUTE_NAME     = "Physical",
            FIRE_ATTRIBUTE_NAME         = "Fire",
            ICE_ATTRIBUTE_NAME          = "Ice",
            LIGHTNING_ATTRIBUTE_NAME    = "Lightning",
            POISON_ATTRIBUTE_NAME       = "Poison",
            ARCANE_ATTRIBUTE_NAME       = "Arcane",
            DARKNESS_ATTRIBUTE_NAME     = "Darkness",
            HOLY_ATTRIBUTE_NAME         = "Holy",

            SKILL_PANEL_TOOLTIP_NAME = "Skills",
            SKILL_PANEL_TOOLTIP_DESCRIPTION = "Overlook and bind settings for all abilities.",

            SKILL_CATEGORY_LIGHTNING = "Lightning",
            SKILL_CATEGORY_FIRE = "Fire",
            SKILL_CATEGORY_ICE = "Ice",
            SKILL_CATEGORY_ARCANE = "Arcane",
            SKILL_CATEGORY_FIGHTING_MASTERY = "Fighting Mastery",
            SKILL_CATEGORY_BATTLE_ADVANTAGE = "Battle Advantage",
            SKILL_CATEGORY_INNER_STRENGTH = "Inner Strength",

            SKILL_CATEGORY_LIGHTNING_ADVANCED = "Lightning skills: ",
            SKILL_CATEGORY_FIRE_ADVANCED = "Fire skills: ",
            SKILL_CATEGORY_ICE_ADVANCED = "Ice skills: ",
            SKILL_CATEGORY_ARCANE_ADVANCED = "Arcane skills: ",
            SKILL_CATEGORY_FIGHTING_MASTERY_ADVANCED = "Fighting Mastery skills: ",
            SKILL_CATEGORY_BATTLE_ADVANTAGE_ADVANCED = "Battle Advantage skills: ",
            SKILL_CATEGORY_INNER_STRENGTH_ADVANCED = "Inner Strength skills: ",

            SKILL_PANEL_LVL_TEXT = "Level: ",
            SKILL_PANEL_UNBIND = "Unbind",

            INVENTORY_PANEL_TOOLTIP_NAME = "Inventory",
            INVENTORY_PANEL_TOOLTIP_DESCRIPTION =  "Contains all of your items.",

            DAMAGE_UI = "Damage: ",
            DAMAGE_TYPE_UI = "Damage Type: ",
            DEFENCE_UI = "Defence: ",
            SUPPRESSION_UI = "Suppression: ",

            ADDITIONAL_INFO_UI = "|nBonuses:|n",
            AUGMENTS_UI = "|nAugments:|n",
            SLOTS_UI = "|nSockets:|n",


            STAT_PANEL_TOOLTIP_NAME = "Stats",
            STAT_PANEL_TOOLTIP_DESCRIPTION =  "Increasing and monitoring of various stats",

            STAT_PANEL_STR = "STR: ",
            STAT_PANEL_INT = "INT: ",
            STAT_PANEL_VIT = "VIT: ",
            STAT_PANEL_AGI = "AGI: ",

            STAT_PANEL_PHYS_ATTACK = "Phys. attack: ",
            STAT_PANEL_PHYS_DEFENCE = "Defence: ",
            STAT_PANEL_MAG_ATTACK = "Mag. attack: ",
            STAT_PANEL_MAG_DEFENCE = "Suppress: ",
            STAT_PANEL_ATTACK_SPEED = "Attacks per sec.: ",
            STAT_PANEL_CRIT_CHANCE = "Crit. chance: ",

            STAT_PANEL_FIRE = "Fire: ",
            STAT_PANEL_PHYSICAL = "Phys.: ",
            STAT_PANEL_ICE = "Ice: ",
            STAT_PANEL_LIGHTNING = "Lightning: ",
            STAT_PANEL_DARKNESS = "Darkness: ",
            STAT_PANEL_HOLY = "Holy: ",
            STAT_PANEL_POISON = "Poison: ",
            STAT_PANEL_ARCANE = "Arcane: ",


            WORN_DECL_HE = "Worn ",
            WORN_DECL_SHE = "Worn ",
            WORN_DECL_THEY = "Worn ",
            WORN_DECL_IT = "Worn ",

            FINE_DECL_HE = "Fine ",
            FINE_DECL_SHE = "Fine ",
            FINE_DECL_THEY = "Fine ",
            FINE_DECL_IT = "Fine ",

            EXCELLENT_DECL_HE = "Excellent ",
            EXCELLENT_DECL_SHE = "Excellent ",
            EXCELLENT_DECL_THEY = "Excellent ",
            EXCELLENT_DECL_IT = "Excellent ",

            IDEAL_DECL_HE = "Perfect ",
            IDEAL_DECL_SHE = "Perfect ",
            IDEAL_DECL_THEY = "Perfect ",
            IDEAL_DECL_IT = "Perfect ",

            ITEM_SUFFIX_ANGER = " of Anger",
            ITEM_SUFFIX_FURY = " of Fury",
            ITEM_SUFFIX_CONCENTRATION = " of Concentration",
            ITEM_SUFFIX_PRECISION = " of Precision",
            ITEM_SUFFIX_ICE_WIZARD = " of Frost Wizard",
            ITEM_SUFFIX_FIRE_WIZARD = " of Fire Wizard",
            ITEM_SUFFIX_LIGHTNING_WIZARD = " of Lightning Wizard",
            ITEM_SUFFIX_SLAYER = " of Slayer",
            ITEM_SUFFIX_TRICKSTER = " of Trickster",
            ITEM_SUFFIX_ROCK = " of Rock",
            ITEM_SUFFIX_KNIGHT = " of Knight",
            ITEM_SUFFIX_MYSTERY = " of Mystery",
            ITEM_SUFFIX_KNOWLEDGE = " of Knowledge",

            GENERIC_SWORD_NAME_1 = "rough blade",
            GENERIC_SWORD_NAME_2 = "short blade",
            GENERIC_SWORD_NAME_3 = "runic blade",
            GENERIC_SWORD_NAME_4 = "broadsword",
            GENERIC_SWORD_NAME_5 = "charmed blade",
            GENERIC_SWORD_NAME_6 = "rapier",

            GENERIC_GREATSWORD_NAME_1 = "barbaric cutter",
            GENERIC_GREATSWORD_NAME_2 = "giants knife",
            GENERIC_GREATSWORD_NAME_3 = "claymore",
            GENERIC_GREATSWORD_NAME_4 = "estoc",

            GENERIC_AXE_NAME_1 = "broad axe",
            GENERIC_AXE_NAME_2 = "serrated axe",
            GENERIC_AXE_NAME_3 = "steel axe",
            GENERIC_AXE_NAME_4 = "mystic axe",

            GENERIC_GREATAXE_NAME_1 = "huge cutter",
            GENERIC_GREATAXE_NAME_2 = "curved axe",

            GENERIC_BLUNT_NAME_1 = "ancient mace",
            GENERIC_BLUNT_NAME_2 = "club",
            GENERIC_BLUNT_NAME_3 = "studded club",
            GENERIC_BLUNT_NAME_4 = "flail",
            GENERIC_BLUNT_NAME_5 = "harbringer's mace",
            GENERIC_BLUNT_NAME_6 = "morgenstern",

            GENERIC_GREATBLUNT_NAME_1 = "large studded club",
            GENERIC_GREATBLUNT_NAME_2 = "mithril hammer",
            GENERIC_GREATBLUNT_NAME_3 = "charmed scepter",
            GENERIC_GREATBLUNT_NAME_4 = "runic warhammer",

            GENERIC_DAGGER_NAME_1 = "curved knife",
            GENERIC_DAGGER_NAME_2 = "gilded knife",
            GENERIC_DAGGER_NAME_3 = "knife",
            GENERIC_DAGGER_NAME_4 = "sharpening",
            GENERIC_DAGGER_NAME_5 = "chopping knife",
            GENERIC_DAGGER_NAME_6 = "stinger",
            GENERIC_DAGGER_NAME_7 = "molten dagger",

            GENERIC_STAFF_NAME_1 = "Parcel of Nature",
            GENERIC_STAFF_NAME_2 = "fiery scepter",
            GENERIC_STAFF_NAME_3 = "Jade Light",
            GENERIC_STAFF_NAME_4 = "Moonlight",
            GENERIC_STAFF_NAME_5 = "The ways of World",
            GENERIC_STAFF_NAME_6 = "Prophet",
            GENERIC_STAFF_NAME_7 = "Moonglade staff",
            GENERIC_STAFF_NAME_8 = "Death's Gift",
            GENERIC_STAFF_NAME_9 = "Seeker",

            GENERIC_BOW_NAME_1 = "Gilded Tree",
            GENERIC_BOW_NAME_2 = "Longbow",
            GENERIC_BOW_NAME_3 = "Rough bow",
            GENERIC_BOW_NAME_4 = "Scouter bow",
            GENERIC_BOW_NAME_5 = "Heavy bow",
            GENERIC_BOW_NAME_6 = "Horn",
            GENERIC_BOW_NAME_7 = "runic bow",
            GENERIC_BOW_NAME_8 = "empowered bow",
            GENERIC_BOW_NAME_9 = "twitching bow",
            GENERIC_BOW_NAME_10 = "mystic bow",
            GENERIC_BOW_NAME_11 = "iced bow",


            GENERIC_CHEST_NAME_1 = "composite chest",
            GENERIC_CHEST_NAME_2 = "Raven Wing",
            GENERIC_CHEST_NAME_3 = "enforced plate",
            GENERIC_CHEST_NAME_4 = "carapace",
            GENERIC_CHEST_NAME_5 = "light armor",
            GENERIC_CHEST_NAME_6 = "heavy armor",
            GENERIC_CHEST_NAME_7 = "steel armor",
            GENERIC_CHEST_NAME_8 = "robe",
            GENERIC_CHEST_NAME_9 = "sturdy armor",
            GENERIC_CHEST_NAME_10 = "armored chest",
            GENERIC_CHEST_NAME_11 = "cuirass",
            GENERIC_CHEST_NAME_12 = "complex chest",
            GENERIC_CHEST_NAME_13 = "Moonglade",

            GENERIC_HANDS_NAME_1 = "fur gloves",
            GENERIC_HANDS_NAME_2 = "leather gloves",
            GENERIC_HANDS_NAME_3 = "chain gauntlets",
            GENERIC_HANDS_NAME_4 = "plate gauntlets",
            GENERIC_HANDS_NAME_5 = "enforced plate gauntlets",
            GENERIC_HANDS_NAME_6 = "duelist gauntlets",
            GENERIC_HANDS_NAME_7 = "charmed gloves",

            GENERIC_LEGS_NAME_1 = "hiking boots",
            GENERIC_LEGS_NAME_2 = "sandals",
            GENERIC_LEGS_NAME_3 = "leather sandals",
            GENERIC_LEGS_NAME_4 = "reinforced sandals",
            GENERIC_LEGS_NAME_5 = "plate boots",
            GENERIC_LEGS_NAME_6 = "armored boots",
            GENERIC_LEGS_NAME_7 = "composite boots",


            GENERIC_HEAD_NAME_1 = "plate cape",
            GENERIC_HEAD_NAME_2 = "demonic helmet",
            GENERIC_HEAD_NAME_3 = "horned helmet",
            GENERIC_HEAD_NAME_4 = "fanatic's helmet",
            GENERIC_HEAD_NAME_5 = "cape",
            GENERIC_HEAD_NAME_6 = "light helmet",
            GENERIC_HEAD_NAME_7 = "steel cap",
            GENERIC_HEAD_NAME_8 = "dragonhunter's helmet",
            GENERIC_HEAD_NAME_9 = "enforced helmet",
            GENERIC_HEAD_NAME_10 = "justicars helmet",
            GENERIC_HEAD_NAME_11 = "royal helmet",


            GENERIC_RING_NAME_1 = "adamantite ring",
            GENERIC_RING_NAME_2 = "gold-plated ring",
            GENERIC_RING_NAME_3 = "knight's signet",
            GENERIC_RING_NAME_4 = "heir ring",
            GENERIC_RING_NAME_5 = "golden ring",
            GENERIC_RING_NAME_6 = "aquamarine ring",
            GENERIC_RING_NAME_7 = "blackened ring",
            GENERIC_RING_NAME_8 = "arcanite ring",
            GENERIC_RING_NAME_9 = "cruel ring",
            GENERIC_RING_NAME_10 = "runic ring",
            GENERIC_RING_NAME_11 = "hoarfrost ring",


            GENERIC_NECKLACE_NAME_1 = "pendant with stone",
            GENERIC_NECKLACE_NAME_2 = "silver amulet",
            GENERIC_NECKLACE_NAME_3 = "ancient amulet",
            GENERIC_NECKLACE_NAME_4 = "sorcerer rosary",
            GENERIC_NECKLACE_NAME_5 = "charmed pendant",
            GENERIC_NECKLACE_NAME_6 = "energized amulet",
            GENERIC_NECKLACE_NAME_7 = "emerald pendant",
            GENERIC_NECKLACE_NAME_8 = "ruby pendant",
            GENERIC_NECKLACE_NAME_9 = "sapphire pendant",


            ITEM_NAME_RAT_HUNTER = 'Rat Hunter',
            ITEM_SPEC_DESCRIPTION_RAT_HUNTER = "Even the rat-hunters had a legendary bows, which all rat hunters desired.",

            ITEM_NAME_BOOT_OF_COWARD = 'Boot of Coward',
            ITEM_SPEC_DESCRIPTION_BOOT_OF_COWARD = "The owner of this boot used the secret tactic of his noble family, that was inherited over 300 years. But that wasn't for long...",
            ITEM_LEG_DESCRIPTION_BOOT_OF_COWARD = "Each enemy near the hero increasing his moving speed by 3%%, with maximum of 25%%",

            ITEM_NAME_WITCH_MASTERY = "Witch Mastery",
            ITEM_SPEC_DESCRIPTION_WITCH_MASTERY = "That staff belonged to a very ancient witch. It absorbed some blood magick, and can share it with wielder.",
            ITEM_LEG_DESCRIPTION_WITCH_MASTERY = "Each casted spell increasing spell power by 10%% in exhange of 5%% life",

            ITEM_NAME_DARK_CROWN = "Dark Crown",
            ITEM_SPEC_DESCRIPTION_DARK_CROWN = "If you want to resist the darkness, became darkness yourself.",

            ITEM_NAME_RITUAL_DAGGER = "Ritual Dagger",
            ITEM_LEG_DESCRIPTION_RITUAL_DAGGER = " With each attack you gain stack of Chaos effect. After reaching 15 stacks, attack power and speed gain major boost for short period of time, but health regeneration is inversed.",
            ITEM_SPEC_DESCRIPTION_RITUAL_DAGGER = "Power within this blade is revealed with every slash. And let the one who takes possession of it can bear it.",

            ITEM_NAME_ACOLYTE_MANTLE = "Acolyte Mantle",
            ITEM_SPEC_DESCRIPTION_ACOLYTE_MANTLE = "The ideal solution for withdrawing into himself",

            ITEM_NAME_SMORC_PICKAXE = "Smorc Pickaxe",
            ITEM_SPEC_DESCRIPTION_SMORC_PICKAXE = "Legends says, that miner Smorc was crushing his enemies with that thing.",
        }

    }


    function InitLocaleLibrary()
        my_locale = "enUS"--"ruRU"--BlzGetLocale() --
    end


end