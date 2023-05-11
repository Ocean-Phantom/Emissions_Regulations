---checks if machines are too close to each other
---@param entity any
---@param player? LuaPlayer
---@param ignore? uint (unit number)
---@param newly_built? boolean
function check_entity_too_close(entity, player, ignore, newly_built)
    local G_entity = global.Pollution_Absorbers[entity.unit_number]
    local G_surface = global.Surfaces[entity.surface_index]
    local Filtered_Entities = {}
    -- if settings.global.Radius_Mode.value == true then
    --     Filtered_Entities = G_surface.Surface.find_entities_filtered({radius=31, position=entity.position, name=global.Pollution_Removing_Entities_array})
    -- else
    local chunk_box = {top_left = {math.floor(entity.position.x/32)*32, math.floor(entity.position.y/32)*32}, right_bottom = {math.floor(entity.position.x/32)*32+31, math.floor(entity.position.y/32)*32+31}}
    Filtered_Entities = G_surface.Surface.find_entities_filtered({area = chunk_box, name=global.Pollution_Removing_Entities_array})
    -- end
    local num_active_entities = 0
    for _, filtered_entity in pairs(Filtered_Entities) do
        if (global.Pollution_Absorbers[filtered_entity.unit_number].Active == true or global.Pollution_Absorbers[filtered_entity.unit_number].Inactivity_Reason ~= 2) and filtered_entity.unit_number ~= ignore then
            num_active_entities = num_active_entities + 1
        elseif filtered_entity.unit_number ~= ignore and filtered_entity.unit_number~=entity.unit_number then
            Filtered_Entities[_] = nil
        end
    end

    for _, filtered_entity in pairs(Filtered_Entities) do
        if filtered_entity.unit_number == entity.unit_number and num_active_entities > 1 then
            if newly_built == true then
                deactivate_pollution_absorber(G_entity, false, 2)
            else
                deactivate_pollution_absorber(G_entity, true, 2)
            end
            num_active_entities = num_active_entities - 1
            if player ~= nil then
                player.create_local_flying_text{
                    text = {"alert-text.machine-disabled", entity.localised_name, "being too close to another pollution remover"},
                    create_at_cursor = true,
                }
            end
            return
        elseif num_active_entities == 0 then
            activate_pollution_absorber(G_entity, true)
            num_active_entities = num_active_entities + 1
            return
        elseif global.Pollution_Absorbers[filtered_entity.unit_number].Inactivity_Reason ~=2 then
            global.Pollution_Absorbers[filtered_entity.unit_number].Inactivity_Reason = 3
        end
    end
end

---add a de-polluting entity to the global table
---@param entity LuaEntity
---@param player? LuaPlayer
---@param newly_built? boolean
function add_pollution_absorber(entity, player, newly_built)
    if global.Pollution_Removing_Entities[entity.name] then
        global.Pollution_Absorbers[entity.unit_number] = {
            ID = entity.unit_number,
            Entity = entity,
            Surface_Index = entity.surface_index,
            Active = entity.active,
            Inactivity_Reason = 0,
            position = entity.position
        }
        if entity.prototype.electric_energy_source_prototype then
            global.Pollution_Absorbers[entity.unit_number].Pollution_Absorption_Amount = entity.prototype.electric_energy_source_prototype.emissions * (entity.pollution_bonus + 1) * 60 * entity.prototype.max_energy_usage * (entity.consumption_bonus + 1) * 60
        else
            global.Pollution_Absorbers[entity.unit_number].Pollution_Absorption_Amount = 0
        end
        local G_entity = global.Pollution_Absorbers[entity.unit_number]
        local G_surface = global.Surfaces[entity.surface_index]

        if settings.global.Limit_Distance.value == true then
            newly_built = newly_built or false
            check_entity_too_close(entity, player, nil, newly_built)
            return
        end

        --For each Limit Type, do the following:
        ---Check if the machine is disabled due to being too close to another machine then check if having this machine active would put the surface over the absorption limit and if so, disable machine & alert player
        ---Otherwise, enable the machine
        if global.Settings.Limit_Type == 1 then ---Linear
            if G_entity.Inactivity_Reason ~= 2 and math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) > G_surface.Pollution_Amount * global.Settings.Max_Linear_Pollution_Absorption then
                deactivate_pollution_absorber(G_entity, false, 1)
                goto PLAYER_ALERT
            elseif G_entity.Inactivity_Reason ~= 2 and G_surface.Pollution_Amount * global.Settings.Max_Linear_Pollution_Absorption > math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) then
                activate_pollution_absorber(G_entity, true)
                return
            end

        elseif global.Settings.Limit_Type == 2 then ---Exponential
            if G_entity.Inactivity_Reason ~= 2 and math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) > (G_surface.Pollution_Amount * global.Settings.Exponential_Const_Multiplier) ^ global.Settings.Exponential_Exponent then
                deactivate_pollution_absorber(G_entity, false, 1)
                goto PLAYER_ALERT
            elseif G_entity.Inactivity_Reason ~= 2 and (G_surface.Pollution_Amount * global.Settings.Exponential_Const_Multiplier) ^ global.Settings.Exponential_Exponent > math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) then
                activate_pollution_absorber(G_entity, true)
                return
            end

        elseif global.Settings.Limit_Type == 3 then ---Logistic
            local k = global.Settings.Logistic_k / G_surface.Pollution_Amount
            local t = G_surface.Pollution_Amount - global.Settings.Logistic_z

            ---additional check due to Logistic Function being undefined at x=0
            if G_surface.Pollution_Amount == 0 and G_entity.Inactivity_Reason ~= 2 then
                deactivate_pollution_absorber(G_entity, false, 1)
                goto PLAYER_ALERT
            elseif G_entity.Inactivity_Reason ~= 2 and math.abs(G_surface.Pollution_Absorption_Amount) > (global.Settings.Logistic_Limit / (1 + MATH_E^(-1 * k * t))) then
                deactivate_pollution_absorber(G_entity, false, 1)
                goto PLAYER_ALERT
            elseif G_entity.Inactivity_Reason ~= 2 and (global.Settings.Logistic_Limit / (1 + MATH_E^(-1 * k * t))) > math.abs(G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount) then
                activate_pollution_absorber(G_entity, true)
                return
            end
        end

        ::PLAYER_ALERT::
        if player ~= nil then
            player.create_local_flying_text{
                text = {"alert-text.machine-disabled", entity.localised_name, "having too many pollution removers on "..G_surface.Surface.name},
                create_at_cursor = true,
            }
            -- player.play_sound{ path = "rc-warning-sound" }
        end
    end
end

---@param entity_id int
function remove_pollution_absorber(entity_id)
    local G_surface = global.Surfaces[global.Pollution_Absorbers[entity_id].Surface_Index]
    G_surface.Active_Pollution_Absorbers[entity_id] = nil
    G_surface.Inactive_Pollution_Absorbers[entity_id] = nil
    local G_entity = global.Pollution_Absorbers[entity_id]
    if G_entity.Active == true then
        G_surface.Pollution_Absorption_Amount = G_surface.Pollution_Absorption_Amount - G_entity.Pollution_Absorption_Amount
    end
    global.Pollution_Absorbers[entity_id] = nil
end

---Activates the entity, and optionally adds its polution reduction to the surface
---@param G_entity {}
---@param Add_to_surface? boolean default true
function activate_pollution_absorber(G_entity, Add_to_surface)
    Add_to_surface = Add_to_surface
    Machine = G_entity.Entity
    Machine.active = true
    local G_surface = global.Surfaces[G_entity.Surface_Index]
    G_surface.Active_Pollution_Absorbers[G_entity.ID] = G_entity
    G_surface.Inactive_Pollution_Absorbers[G_entity.ID] = nil
    G_entity.Inactivity_Reason = 0
    G_entity.Active = true
    G_entity.Activated_by_mod = true
    if Add_to_surface == true then
        G_surface.Pollution_Absorption_Amount = G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount
    end
end

---Deactivates the entity, and optionally removes its polution reduction to the surface
---@param G_entity {}
---@param Add_to_surface? boolean default true
---@param reason? integer
function deactivate_pollution_absorber(G_entity, Add_to_surface, reason)
    Add_to_surface = Add_to_surface
    Machine = G_entity.Entity
    Machine.active = false
    local G_surface = global.Surfaces[G_entity.Surface_Index]
    G_surface.Active_Pollution_Absorbers[G_entity.ID] = nil
    G_surface.Inactive_Pollution_Absorbers[G_entity.ID] = G_entity
    G_entity.Activated_by_mod = false
    if reason then
        G_entity.Inactivity_Reason = reason
    end
    G_entity.Active = false
    if Add_to_surface == true then
        G_surface.Pollution_Absorption_Amount = G_surface.Pollution_Absorption_Amount - G_entity.Pollution_Absorption_Amount
    end
end