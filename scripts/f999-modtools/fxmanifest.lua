fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'


version '1.0.0'

author 'Archie'
description 'f-999 Mod tools making it accessible for all'

client_scripts {
    'client.lua',
    'server.lua'
}


shared_scripts {
    '@crToolkit/import.lua',
    '@ox_lib/init.lua'
}

dependencies {
    'ox_lib',
    'crToolkit'
}
