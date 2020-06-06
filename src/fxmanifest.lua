fx_version 'adamant'

game 'gta5'

description 'ESX Inventory'

version '1.1.0'

ui_page 'html/ui.html'

client_scripts {
    '@es_extended/locale.lua',
    'locales/pt.lua',
    'config.lua',
    'client/main.lua',
    'client/actions.lua',
    'client/inventory.lua',
    --'client/drop.lua',
    'client/trunk.lua',
    'client/glovebox.lua',
    'client/shop.lua',
    'client/ammo.lua',
    'client/weapons.lua',
    'client/search.lua',
    'client/stash.lua',
    'common/drop.lua',
    'common/weapons.lua',
    'utils.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/pt.lua',
    'config.lua',
    'server/main.lua',
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
    'utils.lua'
}

files {
    -- Minified scripts
    'html/js/minifiedScripts/jquery.min.js',
    'html/js/minifiedScripts/jquery-ui.min.js',
    'html/css/minifiedStyles/jquery-ui.min.css',
    'html/js/minifiedScripts/bootstrap.min.js',
    'html/css/minifiedStyles/bootstrap.min.css',
    'html/js/minifiedScripts/popper.min.js',
    'html/css/style.css',

    -- Sounds
    'html/success.wav',
    'html/fail.wav',
    'html/fail2.wav',

    -- Images
    'html/img/*.png',

    -- Icons
    'html/img/items/*.png',

    -- Languages
    'html/locales/pt.js',

    -- Base
    'html/js/config.js',
    'html/js/inventory.js',
    'html/ui.html'
}

dependencies {
    'es_extended',
    'disc-base'
}
