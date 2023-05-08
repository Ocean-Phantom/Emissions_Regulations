function update_surface_list()
	local sur = game.surfaces
	for _, surface in pairs(game.surfaces) do
		add_surface(surface, nil)
	end
end

---@param surface? LuaSurface
---@param surface_index? uint
function add_surface(surface, surface_index)
	if surface ~= nil and surface_index == nil then
		surface_index = surface.index
	elseif surface == nil and surface_index ~= nil then
		surface = game.surfaces[surface_index]
	end
	if surface == nil or surface_index == nil then return end

	if not global.Surfaces[surface_index] then
		global.Surfaces[surface_index] = {
			Surface = surface or {},
			Pollution_Amount = surface.get_total_pollution(),
			Pollution_Delta = 0,
			Pollution_Absorption_Amount = 0,
			Active_Pollution_Absorbers = {},
			Inactive_Pollution_Absorbers = {}
		}
		local existing_removers = surface.find_entities_filtered({name = global.Pollution_Removing_Entities})
		if next(existing_removers) then
			for index, entity in pairs(existing_removers) do
				add_pollution_absorber(entity)
			end
		end
	end
end

---resets pollution absorbers to 0 and counts the total pollution of all active pollution absorbers
---@param G_surface
function recount_absorption(G_surface)
	G_surface.Pollution_Absorption_Amount = 0
	for id, G_entity in pairs(G_surface.Active_Pollution_Absorbers) do
		G_surface.Pollution_Absorption_Amount = G_surface.Pollution_Absorption_Amount + G_entity.Pollution_Absorption_Amount
	end
end

---@param index uint
function delete_surface(index)
	global.Surfaces[index] = nil
end