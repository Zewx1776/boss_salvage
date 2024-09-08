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

local task = {
    name = "Interact Altar",
    shouldExecute = function()
        local is_in_boss_zone = utils.match_player_zone("Boss_WT4_") or utils.match_player_zone("Boss_WT3_")
        return is_in_boss_zone and interact_with_altar()
    end,

    Execute = function()
        local altar = interact_with_altar()
        if altar then
            local actor_position = altar:get_position()  -- Abrufen der Position des Altars
            if utils.distance_to(actor_position) > 4 then
                pathfinder.force_move_raw(actor_position)  -- Bewege den Spieler zum Altar
            end

            if utils.distance_to(actor_position) <= 2 then
                interact_object(altar)
                if settings.tormented then
                    utility.summon_boss_next_recipe()
                end

                utility.summon_boss()
                settings.altar_activated = true
            end
        end

        explorer.is_task_running = false  -- Zurücksetzen des Flags
    end
}
return task
