local for_n_of = require('__flib__.table').for_n_of

local function poll_surface(G_surface, surface_index)
    if G_surface.Surface == nil then delete_surface(surface_index) return end
    ---unlikely to happen, but this is just a fail-safe
    if G_surface.Pollution_Absorption_Amount > 0 then
        recount_absorption(G_surface)
    end
    local previous_amount = G_surface.Pollution_Amount
    G_surface.Pollution_Amount = G_surface.Surface:get_total_pollution()
    -- G_surface.Pollution_Delta = G_surface.Pollution_Amount - previous_amount
    return nil,false,false
end

function poll_surfaces()
    if not next(global.Surfaces) then return end
    --dummy variables we don't do anything with
    local result
    local reached_end

    global.Poll.Last_Surface, result, reached_end = for_n_of(global.Surfaces, global.Poll.Last_Surface, 1, poll_surface)
end

local function poll_entity(G_entity, entity_id)
    Lua_Entity = G_entity.Entity
    if Lua_Entity.valid == false then remove_pollution_absorber(entity_id) return end
    if G_entity.Active == true and G_entity.Activated_by_mod ~= true then
        deactivate_pollution_absorber(G_entity, false, G_entity.Inactivity_Reason)
    end
    local previous_absorption = G_entity.Pollution_Absorption_Amount
    local recipe = G_entity.Entity.get_recipe()
    if global.Special_Entities[Lua_Entity.name] then
        local G_recipe
        if recipe ~= nil then
            G_recipe=global.Special_Recipes[recipe.name]
            G_entity.Pollution_Absorption_Amount = 60 * G_recipe.pollution_removal_amount / (G_recipe.energy / Lua_Entity.crafting_speed)

            --testing seems to indicate that these two entities are soft-capped at 180 pollution removed/minute
            --due to their fluidbox only containing a maximum of 1 unit of pollution
            if (G_entity.Entity.name == "bery0zas-air-suction-tower-2" or G_entity.Entity.name == "bery0zas-air-suction-tower-3") and G_entity.Pollution_Absorption_Amount > 180 then
                G_entity.Pollution_Absorption_Amount = 180
            end
        else
            G_entity.Pollution_Absorption_Amount = 0
        end
    elseif Lua_Entity.prototype.electric_energy_source_prototype then
        local recipe_pollution = 1
        if recipe ~= nil then
            recipe_pollution = recipe.prototype.emissions_multiplier
        end
        G_entity.Pollution_Absorption_Amount = Lua_Entity.prototype.electric_energy_source_prototype.emissions * (Lua_Entity.pollution_bonus + 1) * 60 * Lua_Entity.prototype.max_energy_usage * (Lua_Entity.consumption_bonus + 1) * 60 * recipe_pollution
    end

    local G_surface = global.Surfaces[G_entity.Surface_Index]
    ---account for modules & beacons changing pollution amount
    if G_entity.Active and (previous_absorption > G_entity.Pollution_Absorption_Amount or previous_absorption < G_entity.Pollution_Absorption_Amount) then
        G_surface.Pollution_Absorption_Amount = G_surface.Pollution_Absorption_Amount - (previous_absorption - G_entity.Pollution_Absorption_Amount)
    end


    --For each Limit Type, do the following:
    ---Check if the machine is disabled due to being too close to another machine then check if having this machine active would put the surface over the absorption limit and if so, disable machine & alert player
    ---Otherwise, enable the machine
    if global.Settings.Limit_Type == 1 then ---Linear
        if G_entity.Active == true and math.abs(G_surface.Pollution_Absorption_Amount) > G_surface.Pollution_Amount * global.Settings.Max_Linear_Pollution_Absorption then
            deactivate_pollution_absorber(G_entity, true, 1)

        elseif G_entity.Active == false and G_entity.Inactivity_Reason ~= 2 and G_surface.Pollution_Amount * global.Settings.Max_Linear_Pollution_Absorption > math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) then
            activate_pollution_absorber(G_entity, true)
        end

    elseif global.Settings.Limit_Type == 2 then ---Exponential
        if G_entity.Active == true and math.abs(G_surface.Pollution_Absorption_Amount) > (G_surface.Pollution_Amount * global.Settings.Exponential_Const_Multiplier) ^ global.Settings.Exponential_Exponent then
            deactivate_pollution_absorber(G_entity, true, 1)

        elseif G_entity.Active == false and G_entity.Inactivity_Reason ~= 2 and (G_surface.Pollution_Amount * global.Settings.Exponential_Const_Multiplier) ^ global.Settings.Exponential_Exponent > math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) then
            activate_pollution_absorber(G_entity, true)
        end

    elseif global.Settings.Limit_Type == 3 then ---Logistic
        local k = global.Settings.Logistic_k / G_surface.Pollution_Amount
        local t = G_surface.Pollution_Amount - global.Settings.Logistic_z
        ---additional check due to logistic function being undefined at x=0
        if G_surface.Pollution_Amount == 0 then
            if G_entity.Active == true then
                deactivate_pollution_absorber(G_entity, true, 1)
            else -- do nothing
            end
        elseif G_entity.Active == true and math.abs(G_surface.Pollution_Absorption_Amount) > (global.Settings.Logistic_Limit / (1 + MATH_E^(-1 * k * t))) then
            deactivate_pollution_absorber(G_entity, true, 1)

        elseif G_entity.Active == false and G_entity.Inactivity_Reason ~= 2 and (global.Settings.Logistic_Limit / (1 + MATH_E^(-1 * k * t))) > math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) then
            activate_pollution_absorber(G_entity, true)
        end
    end
    return nil,false,false
end

function poll_entities()
    if not next(global.Pollution_Absorbers) then return end
    --dummy variables we don't do anything with
    local result
    local reached_end

    global.Poll.Last_Entity, result, reached_end = for_n_of(global.Pollution_Absorbers, global.Poll.Last_Entity, global.Settings.Entities_per_Poll, poll_entity)
end
