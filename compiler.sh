#!/bin/bash
VERSION="0.0.0"
YEAR="2014"
cd "$( cd "$( dirname "$0" )" && pwd )"

# Concat
mkdir -p bin
touch bin/engine.coffee
paste -s -d '\n' \
    src/namespace.coffee \
    src/utils.coffee \
    src/utils/matrix_array.coffee \
    src/utils/relationship_dictionary.coffee \
    src/random.coffee \
    src/application.coffee \
    src/actions/action_manager.coffee \
    src/actions/base.coffee \
    src/actions/move.coffee \
    src/actions/walk.coffee \
    src/events/base.coffee \
    src/events/event_emitter.coffee \
    src/user.coffee \
    src/character_generator.coffee \
    src/game.coffee \
    src/message_console.coffee \
    src/constructor_manager.coffee \
    src/registry_subcategory.coffee \
    src/brain_manager.coffee \
    src/timekeeper.coffee \
    src/sprite_distance_manager.coffee \
    src/lighting_manager.coffee \
    src/perception/perceived.coffee \
    src/perception/perception_filter.coffee \
    src/perception/perception_manager.coffee \
    src/geography/world.coffee \
    src/geography/stratum.coffee \
    src/geography/zone_manager.coffee \
    src/geography/zones/base.coffee \
    src/geography/tiles/base.coffee \
    src/ui/components/base.coffee \
    src/ui/components/menu.coffee \
    src/ui/components/query.coffee \
    src/ui/components/tile_map.coffee \
    src/ui/components/data_sources/base.coffee \
    src/ui/components/data_sources/menu_data_source.coffee \
    src/ui/components/data_sources/query_data_source.coffee \
    src/ui/components/data_sources/tile_map_data_source.coffee \
    src/things/base.coffee \
    src/things/abstract.coffee \
    src/things/light_source.coffee \
    src/things/non_abstract.coffee \
    src/things/registry.coffee \
    src/things/effect.coffee \
    src/things/effect.coffee \
    src/things/condition.coffee \
    src/things/sprite.coffee \
    src/things/sentient.coffee \
    src/things/brain.coffee \
    src/things/player.coffee \
    src/things/non_player.coffee \
    src/config.coffee \
    src/boot_loader.coffee \
    src/amd.coffee \
    > bin/engine.coffee

# Compile
coffee -c bin/engine.coffee
java -jar compiler.jar --js bin/engine.js --js_output_file scryengine-$VERSION.min.js
printf "/*\n  Scry Engine version ${VERSION} (c) ${YEAR} David Mauro.\n  Licensed under the Apache License, Version 2.0\n  http://www.apache.org/licenses/LICENSE-2.0\n*/\n"|cat - scryengine-$VERSION.min.js > /tmp/out && mv /tmp/out scryengine-$VERSION.min.js
