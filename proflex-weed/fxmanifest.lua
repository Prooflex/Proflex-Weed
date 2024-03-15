fx_version "cerulean"
game "gta5"
lua54 'yes'

description "Proflex-weed"
version "1.0.0"


client_scripts {
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client/main.lua'
} 

server_script 'server/main.lua'

shared_scripts {
 '@ox_lib/init.lua',
 'config.lua'
}

escrow_ignore {

}
