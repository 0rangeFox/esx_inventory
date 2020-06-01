Config = {}

Config.Locale = 'pt'
Config.OpenControl = 289 -- Tecla F2
Config.TrunkOpenControl = 47 -- Tecla G
Config.DeleteDropsOnStart = false -- Deseja remover os drops no startup do servidor?
Config.HotbarKeyCooldown = 1000 -- Em milisegundos
Config.CheckLicense = true -- Necessita do esx_licenses

-- Weights
Config.PlayerMaxWeight = 100 -- Peso máximo que o jogador pode suportar
Config.StashMaxWeight = 650 -- Peso máximo que os armazéns podem suportar
Config.GloveboxMaxWeight = 30 -- Peso máximo que os torpedos podem suportar

Config.Ammo = {
    {
        name = 'AMMO_PISTOL',
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_APPISTOL',
            'WEAPON_SNSPISTOL',
            'WEAPON_COMBATPISTOL',
            'WEAPON_HEAVYPISTOL',
            'WEAPON_MACHINEPISTOL',
            'WEAPON_MARKSMANPISTOL',
            'WEAPON_PISTOL50',
            'WEAPON_VINTAGEPISTOL',
            'WEAPON_DOUBLEACTION',
            'WEAPON_REVOLVER'
        },
        count = 30
    },
    {
        name = 'AMMO_PISTOL_LARGE',
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_APPISTOL',
            'WEAPON_SNSPISTOL',
            'WEAPON_COMBATPISTOL',
            'WEAPON_HEAVYPISTOL',
            'WEAPON_MACHINEPISTOL',
            'WEAPON_MARKSMANPISTOL',
            'WEAPON_PISTOL50',
            'WEAPON_VINTAGEPISTOL',
            'WEAPON_DOUBLEACTION',
            'WEAPON_REVOLVER'
        },
        count = 60
    },
    {
        name = 'AMMO_SHOTGUN',
        weapons = {
            'WEAPON_ASSAULTSHOTGUN',
            'WEAPON_AUTOSHOTGUN',
            'WEAPON_BULLPUPSHOTGUN',
            'WEAPON_DBSHOTGUN',
            'WEAPON_HEAVYSHOTGUN',
            'WEAPON_PUMPSHOTGUN',
            'WEAPON_SAWNOFFSHOTGUN',
            'WEAPON_MUSKET'
        },
        count = 12
    },
    {
        name = 'AMMO_SHOTGUN_LARGE',
        weapons = {
            'WEAPON_ASSAULTSHOTGUN',
            'WEAPON_AUTOSHOTGUN',
            'WEAPON_BULLPUPSHOTGUN',
            'WEAPON_DBSHOTGUN',
            'WEAPON_HEAVYSHOTGUN',
            'WEAPON_PUMPSHOTGUN',
            'WEAPON_SAWNOFFSHOTGUN',
            'WEAPON_MUSKET'
        },
        count = 18
    },
    {
        name = 'AMMO_SMG',
        weapons = {
            'WEAPON_ASSAULTSMG',
            'WEAPON_MICROSMG',
            'WEAPON_MINISMG',
            'WEAPON_SMG',
            'WEAPON_COMBATMG',
            'WEAPON_COMBATPDW',
            'WEAPON_GUSENBERG'
        },
        count = 45
    },
    {
        name = 'AMMO_SMG_LARGE',
        weapons = {
            'WEAPON_ASSAULTSMG',
            'WEAPON_MICROSMG',
            'WEAPON_MINISMG',
            'WEAPON_SMG',
            'WEAPON_COMBATMG',
            'WEAPON_COMBATPDW',
            'WEAPON_GUSENBERG'
        },
        count = 65
    },
    {
        name = 'AMMO_RIFLE',
        weapons = {
            'WEAPON_ADVANCEDRIFLE',
            'WEAPON_ASSAULTRIFLE',
            'WEAPON_BULLPUPRIFLE',
            'WEAPON_CARBINERIFLE',
            'WEAPON_SPECIALCARBINE',
            'WEAPON_COMPACTRIFLE',
            'WEAPON_MG',
            'WEAPON_RAILGUN'
        },
        count = 45
    },
    {
        name = 'AMMO_RIFLE_LARGE',
        weapons = {
            'WEAPON_ADVANCEDRIFLE',
            'WEAPON_ASSAULTRIFLE',
            'WEAPON_BULLPUPRIFLE',
            'WEAPON_CARBINERIFLE',
            'WEAPON_SPECIALCARBINE',
            'WEAPON_COMPACTRIFLE',
            'WEAPON_MG',
            'WEAPON_RAILGUN'
        },
        count = 65
    },
    {
        name = 'AMMO_SNIPER',
        weapons = {
            'WEAPON_SNIPERRIFLE',
            'WEAPON_HEAVYSNIPER',
            'WEAPON_MARKSMANRIFLE'
        },
        count = 10
    },
    {
        name = 'AMMO_SNIPER_LARGE',
        weapons = {
            'WEAPON_SNIPERRIFLE',
            'WEAPON_HEAVYSNIPER',
            'WEAPON_MARKSMANRIFLE'
        },
        count = 15
    }
}

Config.Shops = {
    ['TwentyFourSeven'] = {
        coords = {
            vector3(374.07, 325.86, 102.680),
            vector3(2557.46, 382.32, 107.80),
            vector3(-3039.01, 586.17, 7.10),
            vector3(-3241.9, 1001.56, 12.0),
            vector3(547.444, 2671.24, 41.30),
            vector3(1961.530, 3740.800, 31.510),
            vector3(2679.0, 3280.76, 54.40),
            vector3(1729.29, 6414.53, 34.2),
            vector3(26.18, -1347.37, 28.650),
        },
        items = {
            { name = 'bread', price = 20, count = 10 },
            { name = 'water', price = 10, count = 10 },
        },
        markerType = 27,
        markerColour = { r = 0, g = 255, b = 0 },
        msg = nil,
        enableBlip = true,
        job = 'all'
    },

    ['LTDgasoline'] = {
        coords = {
            vector3(-707.86, -914.62, 18.32),
            vector3(-48.58, -1757.69, 28.62),
            vector3(-1820.79, 792.52, 137.15),
            vector3(1163.39, -323.94, 68.31),
            vector3(1698.19, 4924.7, 41.16)
        },
        items = {
            { name = 'bread', price = 20, count = 10 },
            { name = 'water', price = 10, count = 10 },
        },
        markerType = 27,
        markerColour = { r = 255, g = 0, b = 0  },
        msg = nil,
        enableBlip = true,
        job = 'all'
    },
    ['Weapon Shop - Police'] = {
        coords = {
            vector3(450.06, -990.55, 30.69),
        },
        items = {
            -- Ammo
            { name = 'AMMO_PISTOL', price = 0, count = 1, grade = 0 },
            { name = 'AMMO_PISTOL_LARGE', price = 0, count = 1, grade = 0 },
            { name = 'AMMO_RIFLE', price = 0, count = 1, grade = 0 },
            { name = 'AMMO_RIFLE_LARGE', price = 0, count = 1, grade = 0 },
            { name = 'AMMO_SHOTGUN', price = 0, count = 1, grade = 0 },
            { name = 'AMMO_SMG', price = 0, count = 1, grade = 0 },
            { name = 'AMMO_SNIPER', price = 0, count = 1, grade = 0 },
            { name = 'WEAPON_COMBATPISTOL', price = 0, count = 1, grade = 0 },
            { name = 'WEAPON_STUNGUN', price = 0, count = 1, grade = 0 },
            { name = 'WEAPON_NIGHTSTICK', price = 0, count = 1, grade = 0 },
            { name = 'WEAPON_FLASHLIGHT', price = 0, count = 1, grade = 0 },
            { name = 'WEAPON_PUMPSHOTGUN', price = 0, count = 1, grade = 2 },
            { name = 'WEAPON_CARBINERIFLE', price = 0, count = 1, grade = 3 },
        },
        markerType = 2,
        markerColour = { r = 0, g = 0, b = 255 },
        msg = 'Pressione na tecla ~INPUT_CONTEXT~ para abrir a loja da polícia.',
        job = 'police'
    },
}

Config.Stash = {
    ['Police'] = {
        coords = vector3(457.76, -981.05, 30.69),
        size = vector3(1.0, 1.0, 1.0),
        job = 'police',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Pressione na tecla ~INPUT_CONTEXT~ para abrir o cofre da polícia.'
    },
    ['Mc'] = {
        coords = vector3(457.76, -979.05, 30.69),
        size = vector3(1.0, 1.0, 1.0),
        job = 'police',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = nil
    }
}

Config.VehicleLimit = { -- Número de slots
    ['Zentorno'] = 10,
    ['Panto'] = 1,
    ['Zion'] = 5
}

Config.VehicleWeight2 = { -- Número de peso
    ['Zentorno'] = 10,
    ['Panto'] = 1,
    ['Zion'] = 5
}

-- Se o seu peso não for adicionado em cima, seu veículo obterá os valores padrões listado em baixo dependendo da sua categoria
Config.VehicleSlot = {
    [0] = 10, --Compact
    [1] = 15, --Sedan
    [2] = 20, --SUV
    [3] = 15, --Coupes
    [4] = 5, --Muscle
    [5] = 5, --Sports Classics
    [6] = 5, --Sports
    [7] = 0, --Super
    [8] = 5, --Motorcycles
    [9] = 10, --Off-road
    [10] = 20, --Industrial
    [11] = 20, --Utility
    [12] = 30, --Vans
    [13] = 0, --Cycles
    [14] = 0, --Boats
    [15] = 0, --Helicopters
    [16] = 0, --Planes
    [17] = 20, --Service
    [18] = 20, --Emergency
    [19] = 90, --Military
    [20] = 0, --Commercial
    [21] = 0 --Trains
}

Config.VehicleWeight = {
    [0] = 10, --Compact
    [1] = 15, --Sedan
    [2] = 20, --SUV
    [3] = 16, --Coupes
    [4] = 5, --Muscle
    [5] = 5, --Sports Classics
    [6] = 5, --Sports
    [7] = 0, --Super
    [8] = 5, --Motorcycles
    [9] = 10, --Off-road
    [10] = 20, --Industrial
    [11] = 20, --Utility
    [12] = 30, --Vans
    [13] = 0, --Cycles
    [14] = 0, --Boats
    [15] = 0, --Helicopters
    [16] = 0, --Planes
    [17] = 20, --Service
    [18] = 20, --Emergency
    [19] = 90, --Military
    [20] = 0, --Commercial
    [21] = 0 --Trains
}

Config.Throwables = {
    WEAPON_MOLOTOV = 615608432,
    WEAPON_GRENADE = -1813897027,
    WEAPON_STICKYBOMB = 741814745,
    WEAPON_PROXMINE = -1420407917,
    WEAPON_SMOKEGRENADE = -37975472,
    WEAPON_PIPEBOMB = -1169823560,
    WEAPON_SNOWBALL = 126349499
}

Config.FuelCan = 883325847
