resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'TeamMOH'
author 'ANNE'
version '1.0'

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0'

files {
    'data/**/*.meta',
    'data/**/*.dat',
  }


data_file 'HANDLING_FILE'            'data/**/handling*.meta'
data_file 'VEHICLE_LAYOUTS_FILE'    'data/**/vehiclelayouts*.meta'
data_file 'VEHICLE_METADATA_FILE'    'data/**/vehicles*.meta'
data_file 'CARCOLS_FILE'            'data/**/carcols*.meta'
data_file 'VEHICLE_VARIATION_FILE'    'data/**/carvariations*.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'data/**/*unlocks.meta'
data_file 'PTFXASSETINFO_FILE' 'data/**/ptfxassetinfo.meta'


dependency '/assetpacks'