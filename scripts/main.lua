local function on_moved(event)
	if settings.global.Limit_Distance.value == false then return end
	local entity = event.entity or event.moved_entity
	if global.Pollution_Absorbers[event.unit_number] then
		entity = global.Pollution_Absorbers[event.unit_number].entity
	end
	if entity == nil then return end
	if global.Pollution_Removing_Entities[entity.name] ~= nil then
		local G_entity = global.Pollution_Absorbers[entity.unit_number]
		local G_surface = global.Surfaces[entity.surface_index]
		if G_entity == nil then return end

		---update anything at the old position, then update the machine at the new position, including position in global
		local Filtered_Entities = {}
		local chunk_box = {top_left = {math.floor(G_entity.position.x/32)*32, math.floor(G_entity.position.y/32)*32}, right_bottom = {math.floor(G_entity.position.x/32)*32+31, math.floor(G_entity.position.y/32)*32+31}}

		Filtered_Entities = G_surface.Surface.find_entities_filtered({area = chunk_box, name=global.Pollution_Removing_Entities_array})
		for _, filtered_entity in pairs(Filtered_Entities) do
			if filtered_entity.unit_number ~= G_entity.ID then
				check_entity_too_close(filtered_entity, nil, entity.unit_number, false)
			end
		end
		check_entity_too_close(entity, nil, nil, false)
		G_entity.position=entity.position
		G_entity.surface_index=entity.surface_index
	end
end

local function on_removed(event)
	if settings.global.Limit_Distance.value == false then return end
	local entity = event.entity or event.moved_entity
	if global.Pollution_Absorbers[event.unit_number] then
		entity = global.Pollution_Absorbers[event.unit_number].entity
	end
	if entity == nil then return end
	if global.Pollution_Removing_Entities[entity.name] ~= nil then
		local G_entity = global.Pollution_Absorbers[entity.unit_number]
		local G_surface = global.Surfaces[entity.surface_index]
		if G_entity == nil then return end
		local Filtered_Entities = {}
		local chunk_box = {top_left = {math.floor(entity.position.x/32)*32, math.floor(entity.position.y/32)*32}, right_bottom = {math.floor(entity.position.x/32)*32+31, math.floor(entity.position.y/32)*32+31}}

		Filtered_Entities = G_surface.Surface.find_entities_filtered({area = chunk_box, name=global.Pollution_Removing_Entities_array})
		for _, filtered_entity in pairs(Filtered_Entities) do
			if filtered_entity.unit_number ~= G_entity.ID then
				check_entity_too_close(filtered_entity, nil, entity.unit_number, false)
			end
		end
	end
end

function setup_globals()
	global.Surfaces = global.Surfaces or {}
	global.Pollution_Removing_Entities = {}
	global.Special_Entities = {}
	global.Special_Recipes = {}
	-- global.Pollution_Removing_Recipies = {}
	global.Settings = {
		Surface_Poll_Time = settings.global.Surface_Poll_Time.value,
		Max_Linear_Pollution_Absorption = settings.global.Max_Linear_Pollution_Absorption.value / 100,
		Exponential_Const_Multiplier = settings.global.Exponential_Const_Multiplier.value ^ (settings.global.Exponential_Exponent.value - 1),
		Exponential_Exponent = 1 / settings.global.Exponential_Exponent.value,
		Logistic_Limit = settings.global.Logistic_Limit.value,
		Logistic_k = settings.global.Logistic_k.value,
		Logistic_z = settings.global.Logistic_z.value,
		Entities_per_Poll = settings.global.Entities_per_Poll.value
	}
	if settings.global.Pollution_Absorption_Limit_Type.value == "Linear" then
		global.Settings.Limit_Type = 1
	elseif settings.global.Pollution_Absorption_Limit_Type.value == "Exponential" then
		global.Settings.Limit_Type = 2
	elseif settings.global.Pollution_Absorption_Limit_Type.value == "Logistic" then
		global.Settings.Limit_Type = 3
	end

	global.Poll = {Last_Surface = nil, Last_Entity = nil}
	global.Pollution_Absorbers = {}

	for entity_name, entity in pairs(game.entity_prototypes) do
		if entity.electric_energy_source_prototype and entity.electric_energy_source_prototype.emissions < 0 then
			global.Pollution_Removing_Entities[entity_name] = entity_name
		end
		if entity.heat_energy_source_prototype and entity.heat_energy_source_prototype.emissions < 0 then
			global.Pollution_Removing_Entities[entity_name] = entity_name
		end
		if entity.fluid_energy_source_prototype and entity.fluid_energy_source_prototype.emissions < 0 then
			global.Pollution_Removing_Entities[entity_name] = entity_name
		end
		if entity.void_energy_source_prototype and entity.void_energy_source_prototype.emissions < 0 then
			global.Pollution_Removing_Entities[entity_name] = entity_name
		end
	end
	local names, i = {}, 1
	for mod_name, mod_info in pairs(SPECIAL_CASES) do
		if game.active_mods[mod_name] then
			for _, entity_name in pairs(mod_info.ENTITY_NAMES) do
				if not global.Pollution_Removing_Entities[entity_name] then
					global.Pollution_Removing_Entities[entity_name] = entity_name
					global.Special_Entities[entity_name] = true
				end
			end
			for recipe_name, recipe in pairs(mod_info.RECIPE_INFO) do
				global.Special_Recipes[recipe_name] = recipe
			end
		end
	end

	for PRE_name in pairs(global.Pollution_Removing_Entities) do
		names[i] = PRE_name
		i = i + 1
	end
	global.Pollution_Removing_Entities_array = names

	if not next(global.Surfaces) then
		update_surface_list()
	end

	if remote.interfaces["PickerDollies"] then
		script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_moved)
	end
end

local function on_load()
	if remote.interfaces["PickerDollies"] then
		script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_moved)
	end
end


local function on_built(event)
	local player = nil
	if event.player_index ~= nil then
		player = game.get_player(event.player_index)
	end
	add_pollution_absorber(event.created_entity or event.entity or event.destination, player, true)
end

local function on_gui_opened(event)
	player = game.get_player(event.player_index)
	local entity = event.entity
	if event.entity ~= nil and global.Pollution_Absorbers[event.entity.unit_number] ~= nil then
		if global.Pollution_Absorbers[event.entity.unit_number].Active == false then
			local reason = nil
			if global.Pollution_Absorbers[event.entity.unit_number].Inactivity_Reason == 2 then
				reason = "being too close to another pollution remover"
			else
				reason = "having too many pollution removers on "..event.entity.surface.name
			end
			player.create_local_flying_text{
				text = {"alert-text.machine-disabled", entity.localised_name, reason},
				create_at_cursor = true,
			}
		end
	end
end

local function on_tick(event)
	local tick = event.tick % global.Settings.Surface_Poll_Time
	if tick == 0 then
		poll_surfaces()
	end
	poll_entities()
end

local function on_setting_changed(event)
	global.Settings = {
		Surface_Poll_Time = settings.global.Surface_Poll_Time.value,
		Max_Linear_Pollution_Absorption = settings.global.Max_Linear_Pollution_Absorption.value / 100,
		Exponential_Const_Multiplier = settings.global.Exponential_Const_Multiplier.value ^ (settings.global.Exponential_Exponent.value - 1),
		Exponential_Exponent = 1 / settings.global.Exponential_Exponent.value,
		Logistic_Limit = settings.global.Logistic_Limit.value,
		Logistic_k = settings.global.Logistic_k.value,
		Logistic_z = settings.global.Logistic_z.value,
		Entities_per_Poll = settings.global.Entities_per_Poll.value
	}
	if settings.global.Pollution_Absorption_Limit_Type.value == "Linear" then
		global.Settings.Limit_Type = 1
	elseif settings.global.Pollution_Absorption_Limit_Type.value == "Exponential" then
		global.Settings.Limit_Type = 2
	elseif settings.global.Pollution_Absorption_Limit_Type.value == "Logistic" then
		global.Settings.Limit_Type = 3
	end
	if settings.global.Limit_Distance.value == true then
		for _, entity in pairs(global.Pollution_Absorbers) do
			local G_surface = global.Surfaces[entity.Surface_Index]
			entity = entity.Entity
			local Filtered_Entities = {}
			local chunk_box = {top_left = {math.floor(entity.position.x/32)*32, math.floor(entity.position.y/32)*32}, right_bottom = {math.floor(entity.position.x/32)*32+31, math.floor(entity.position.y/32)*32+31}}
			Filtered_Entities = G_surface.Surface.find_entities_filtered({area = chunk_box, name=global.Pollution_Removing_Entities_array})
			for _, filtered_entity in pairs(Filtered_Entities) do
				check_entity_too_close(filtered_entity)
			end
		end
	else
		for _, entity in pairs(global.Pollution_Absorbers) do
			if entity.Inactivity_Reason == 2 then
				entity.Inactivity_Reason = 3
			end
		end
	end
end

local function on_surface_created(event)
	add_surface(nil, event.surface_index)
end
local function on_surface_deleted(event)
	delete_surface(event.surface_index)
end

script.on_init(setup_globals)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_setting_changed)

script.on_event(defines.events.on_surface_created, on_surface_created)
script.on_event(defines.events.on_surface_imported, on_surface_created)
script.on_event(defines.events.on_surface_deleted, on_surface_deleted)
script.on_event(defines.events.on_surface_cleared, on_surface_deleted)

script.on_event(defines.events.on_built_entity,on_built)
script.on_event(defines.events.on_entity_cloned, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)


script.on_event(defines.events.on_entity_died, on_removed)
script.on_event(defines.events.on_player_mined_entity, on_removed)
script.on_event(defines.events.on_robot_mined_entity, on_removed)
script.on_event(defines.events.script_raised_destroy, on_removed)
script.on_event(defines.events.script_raised_teleported, on_moved)

script.on_event(defines.events.on_gui_opened, on_gui_opened)
