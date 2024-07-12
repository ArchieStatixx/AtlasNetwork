games { 'rdr3', 'gta5' }

fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Colossal'
name 'f999-elevators'
description ''
version '1.0.0'
repository 'https://five999.co.uk'

dependencies {
    '/onesync',
    'ox_lib',
    'crToolkit'
}

shared_scripts {
    '@crToolkit/import.lua',
    '@crLib/init.lua',
    'shared.lua'
}


server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
	'*.json',
	'plugins/**/*.lua'
}