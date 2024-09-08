local utils      = require "core.utils"
local enums      = require "data.enums"
local tracker    = require "core.tracker"
local explorer   = require "core.explorer"
local settings   = require "core.settings"

local function interact_with_altar()
    local actors = actors_manager:get_all_actors()
    for _, actor in pairs(actors) do
        local name = actor:get_skin_name()
        if name == "Boss_WT4_Varshan" or name == "Boss_WT4_Duriel" or name == "Boss_WT4_PenitantKnight" or name == "Boss_WT4_Andariel" or name == "Boss_WT4_MegaDemon" or name == "Boss_WT4_S2VampireLord" then
            return actor
        end
    end
    return nil
end

local boss_summon_time = 0

local task = {
    name = "Interact Altar",
    shouldExecute = function()
        local is_in_boss_zone = utils.match_player_zone("Boss_WT4_") or utils.match_player_zone("Boss_WT3_")
        local no_loot_on_ground = not utils.loot_on_floor()
        return is_in_boss_zone and interact_with_altar() and no_loot_on_ground
    end,

    Execute = function()
        local current_time = get_time_since_inject()
        
        if boss_summon_time > 0 and current_time - boss_summon_time < 3 then
            return  -- Wait for 5 seconds after boss summon
        end

        local altar = interact_with_altar()
        if altar then
            local actor_position = altar:get_position()
            if utils.distance_to(actor_position) > 2 then
                pathfinder.force_move_raw(actor_position)
            end

            if utils.distance_to(actor_position) <= 2 then
                interact_object(altar)
                if settings.tormented then
                    utility.summon_boss_next_recipe()
                end

                utility.summon_boss()
                settings.altar_activated = true
                boss_summon_time = current_time  -- Set the boss summon time
            end
        end

        explorer.is_task_running = false
    end
}
return task