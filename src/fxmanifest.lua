fx_version 'adamant'

game 'gta5'

description 'ESX Inventory'

version '1.1.0'

ui_page 'html/ui.html'

client_scripts {
    '@es_extended/locale.lua',
    'client/main.lua',
    'config.lua',
    'client/actions.lua',
    'client/inventory.lua',
    'client/drop.lua',
    'client/trunk.lua',
    'client/glovebox.lua',
    'client/shop.lua',
    'client/ammo.lua',
    'client/weapons.lua',
    'client/search.lua',
    'client/stash.lua',
    'common/drop.lua',
    'common/weapons.lua',
    'utils.lua',
    'locales/cs.lua',
    'locales/en.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'server/main.lua',
    'config.lua',
    'server/actions.lua',
    'server/inventory.lua',
    'server/player.lua',
    'server/drop.lua',
    'server/trunk.lua',
    'server/glovebox.lua',
    'server/shop.lua',
    'server/ammo.lua',
    'server/weapons.lua',
    'server/search.lua',
    'server/stash.lua',
    'server/itemdata.lua',
    'common/drop.lua',
    'common/weapons.lua',
    'utils.lua',
    'locales/cs.lua',
    'locales/en.lua'
}

files {
    'html/ui.html',
    'html/css/style.min.css',
    'html/js/inventory.js',
    'html/js/config.js',
    'html/css/jquery-ui.min.css',
    'html/css/bootstrap.min.css',
    'html/js/jquery.min.js',
    'html/js/jquery-ui.min.js',
    'html/js/bootstrap.min.js',
    'html/js/popper.min.js',

    -- JS langs
    'html/locales/cs.js',
    'html/locales/en.js',

    -- IMAGES
    'html/img/*.png',
    'html/success.wav',
    'html/fail.wav',
    'html/fail2.wav',

    -- ICONS
    'html/img/items/*.png'
}

dependencies {
    'es_extended',
    'disc-base'
}
