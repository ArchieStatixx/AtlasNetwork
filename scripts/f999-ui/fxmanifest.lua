games { 'rdr3', 'gta5' }

fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Jack'
name 'f999-track'
description 'Manages Five999 UI components such as blips, name tags, CAD HUDs and other radial triggered interactions.'
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
    '@configurations/resources/radial.lua',
    'shared.lua'
}


server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
	'plugins/**/*.json',
	'plugins/**/*.lua'
}