#!/bin/bash
cd "$( cd "$( dirname "$0" )" && pwd )"

# Concat
mkdir -p bin
touch bin/engine.coffee
paste -s -d '\n' \
    src/namespace.coffee \
    src/storage.coffee \
    src/input/keyboard_manager.coffee \
    src/utils.coffee \
    src/utils/matrix_array.coffee \
    src/utils/relationship_dictionary.coffee \
    src/random.coffee \
    src/application.coffee \
    src/actions/action_manager.coffee \
    src/actions/action.coffee \
    src/actions/move.coffee \
    src/actions/walk.coffee \
    src/events/event.coffee \
    src/events/basic_events.coffee \
    src/events/event_emitter.coffee \
    src/user.coffee \
    src/character_generator.coffee \
    src/game.coffee \
    src/game_history.coffee \
    src/message_console.coffee \
    src/constructor_manager.coffee \
    src/registry_subcategory.coffee \
    src/brain_manager.coffee \
    src/timekeeper.coffee \
    src/sprite_distance_manager.coffee \
    src/lighting/lighting_manager.coffee \
    src/lighting/light_tile.coffee \
    src/geography/world.coffee \
    src/geography/stratum.coffee \
    src/geography/zone_manager.coffee \
    src/geography/zones/zone.coffee \
    src/geography/tiles/tile.coffee \
    src/geography/tiles/basic_tiles.coffee \
    src/perception/perception_manager.coffee \
    src/ui/components/component.coffee \
    src/ui/components/menu.coffee \
    src/ui/components/query.coffee \
    src/ui/components/tile_map.coffee \
    src/ui/components/data_sources/data_source.coffee \
    src/ui/components/data_sources/menu_data_source.coffee \
    src/ui/components/data_sources/query_data_source.coffee \
    src/ui/components/data_sources/tile_map_data_source.coffee \
    src/things/thing.coffee \
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
    src/things/player_playback.coffee \
    src/things/non_player.coffee \
    src/amd.coffee \
    > bin/engine.coffee

# Compile
coffee -c bin/engine.coffee
