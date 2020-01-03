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

            GENERIC_SWORD_NAME_1 = "Рунический клинок",
            GENERIC_SWORD_NAME_2 = "Короткий клинок",
            GENERIC_SWORD_NAME_3 = "Изогнутый клинок",

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
        ["enGB"] = {
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
            CAST_SPEED_PARAM              = 'Magic speed',
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

            GENERIC_SWORD_NAME_1 = "Runic blade",
            GENERIC_SWORD_NAME_2 = "Short blade",
            GENERIC_SWORD_NAME_3 = "Crooked blade",

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
        my_locale = BlzGetLocale() -- "enGB"
    end


end