fx_version 'adamant'
game 'gta5'
lua54 'yes'
authot 'RNR`Developments'

shared_scripts {
    '@ox_lib/init.lua',
    'sh_*.lua'
}

client_scripts {
    'bridge/client.lua',
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua',
    'server/*.lua',
}

dependencies {
    'ox_lib'
}