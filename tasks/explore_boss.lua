local utils = require "core.utils"
local enums = require "data.enums"
local explorer = require "core.explorer"
local settings = require "core.settings"

local task = {
    name = "Explore Boss Dungeon",
    shouldExecute = function()
        local is_in_boss_zone = utils.match_player_zone("Boss_WT4_") or utils.match_player_zone("Boss_WT3_")
        
        if not is_in_boss_zone then
            return false
        end

        local player_position = get_player_position()
        if player_position:dist_to(enums.positions.getBossRoomPosition(get_current_world():get_current_zone_name())) < 10 then
            return false
        end

        return not utils.get_closest_enemy()
    end,

    Execute = function()
        
        local player_position = get_player_position()
        if player_position:dist_to(enums.positions.getBossRoomPosition(get_current_world():get_current_zone_name())) < 5 then
            explorer.enabled = false
        else
            explorer.enabled = true
        end

        local player_pos = get_player_position()

        if not settings.is_stuck then
            explorer:clear_path_and_target()
            explorer:set_custom_target(enums.positions.getBossRoomPosition(get_current_world():get_current_zone_name()))
            explorer:move_to_target()
        end
    end
}

return task