shared_script '@dgc_acu/ai_module_fg-obfuscated.lua'
shared_script '@dgc_acu/shared_fg-obfuscated.lua'
shared_script '@klrp-aman/ai_module_fg-obfuscated.lua'
shared_script '@klrp-aman/shared_fg-obfuscated.lua'
fx_version 'adamant'
game 'gta5'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}

dependencies {
    'ox_lib'
}
client_script "@klrp-tnt/module/client_module.lua"
shared_script "@klrp-tnt/module/server_module.lua"
client_script "@klrp-tnt/module/client_module.lua"
shared_script "@klrp-tnt/module/server_module.lua"
client_script "@klrp-tnt/module/client_module.lua"
shared_script "@klrp-tnt/module/server_module.lua"