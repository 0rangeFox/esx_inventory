# esx_inventory | Only works with this [es_extended](https://github.com/0rangeFox/es_extended)

### I will accept PR or do bug fixes, if you found one, [just report it on section "issues"](https://github.com/0rangeFox/es_extended/issues). You can [join on my support discord](https://discord.gg/5vrjddj) to get help.

# Description
Adds the following features

- Inventory HUD
[![Image from Imgur](https://i.imgur.com/UZSpzfD.png)](https://imgur.com/a/ZWKonJ6)
[![Image from Imgur](https://i.imgur.com/Zp6XcIC.png)](https://imgur.com/a/ZWKonJ6)
- Drops HUD
[![Image from Imgur](https://i.imgur.com/E8EH6sE.png)](https://imgur.com/a/ZWKonJ6)
[![Image from Imgur](https://i.imgur.com/BhQ3uua.png)](https://imgur.com/a/ZWKonJ6)
- Shops HUD
[![Image from Imgur](https://i.imgur.com/498U5K7.png)](https://imgur.com/a/ZWKonJ6)
- Glovebox HUD
[![Image from Imgur](https://i.imgur.com/49D5kJG.png)](https://imgur.com/a/ZWKonJ6)
- Trunks HUD
[![Image from Imgur](https://i.imgur.com/NPD7sx0.png)](https://imgur.com/a/ZWKonJ6)
[![Image from Imgur](https://i.imgur.com/XRbZsF1.png)](https://imgur.com/a/ZWKonJ6)
- Weapons as Items
[![Image from Imgur](https://i.imgur.com/JT68wpV.png)](https://imgur.com/a/ZWKonJ6)

# Explanation
## Weapons as Items
Weapons are read from the `items` table with the prefix `WEAPON_`. Add all usable weapons into the `items` table with their limit.
Ammo for each weapon is stored in `ammos` with amount of bullets, Ammos are read from the `items` table with the prefix `AMMO_`. Add all usable ammos into the `items` table with their limit and the use of ammo can be configurable on `config.lua`.

## Hotbar Keys
The weapon wheel is disabled for the use of hot keys. Weapons being used as items is needed in this case

# Installation
[Download `disc-base`](https://github.com/DiscworldZA/gta-resources/tree/master/disc-base)

Add the disc-base and esx_inventory to resource folder `[esx]/[inventory]`

Execute SQL : `esx_inventory.sql`

Add the following lines to your config:
```
start disc-base
start esx_inventory
```

# Editing CSS
The source CSS is written in SASS, which is a superset of the CSS3 syntax. Compiling this will require some form of a SASS compiler to compile it into valid vanilla CSS that a browser (or in this case, NUI/CEF) can understand and parse. Can easily get a Visual Studio Code extension to achieve this, a good one to try is [Live SASS Compiler](https://marketplace.visualstudio.com/items?itemName=ritwickdey.live-sass), once installed add the below to your VSCode config and it'll compile the SCSS files into CSS and put it in the correct location.

```JSON
"liveSassCompile.settings.formats":[{
        "format": "compressed",
        "extensionName": ".css",
        "savePath": "~/../"
    },
]
```