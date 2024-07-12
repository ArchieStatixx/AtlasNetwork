fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'


version '1.0.0'

author 'Archie '
description 'f-999 Armoury'

client_scripts {
    'client.lua'
}


shared_scripts {
    '@crToolkit/import.lua',
    '@ox_lib/init.lua',
    '@configurations/f999/armoury.lua'
}

dependencies {
    'ox_lib',
    'crToolkit'
}
