local utils      = require "core.utils"
local enums      = require "data.enums"
local settings   = require "core.settings"
local navigation = require "core.navigation"
local explorer   = require "core.explorer"
local tracker    = require "core.tracker"

local stuck_position = nil

local task = {
    name = "Kill Monsters",
    shouldExecute = function()
        if not utils.player_on_quest(get_current_world():get_current_zone_name()) then
            return false
        end

        local close_enemy = utils.get_closest_enemy()
        return close_enemy ~= nil
    end,
    Execute = function()
        local player_pos = get_player_position()

        if explorer.check_if_stuck() then
            -- Log the stuck position
            stuck_position = player_pos
            return false
        end

        if stuck_position and utils.distance_to(stuck_position) < 10 then
            -- Player is still within 10 units of the stuck position, do not resume
            return false
        else
            -- Clear the stuck position once the player has moved 10+ units away
            stuck_position = nil
        end

        local distance_check = settings.melee_logic and 2 or 6.5
        local enemy = utils.get_closest_enemy()
        if not enemy then return false end

        local within_distance = utils.distance_to(enemy) < distance_check
        
        tracker.finished_time = 0
            tracker.start_time = 0

        if not within_distance then
            local enemy_pos = enemy:get_position()

            explorer:clear_path_and_target()
            explorer:set_custom_target(enemy_pos)
            explorer:move_to_target()
        else
            if settings.melee_logic then
                local enemy_pos = enemy:get_position()

                explorer:clear_path_and_target()
                explorer:set_custom_target(enemy_pos:get_extended(player_pos, -1.0))
                explorer:move_to_target()
            else
                -- do nothing for now due to being ranged
            end
        end
    end
}

return task