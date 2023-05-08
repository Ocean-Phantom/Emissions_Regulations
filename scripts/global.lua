---@class Surfaces
---@field Surface LuaSurface
---@field Pollution_Amount double = surface.get_total_pollution
---@field Pollution_Absorption_Amount {} -- only counting entities we track
---@field Active_Pollution_Absorbers {} k = ID, v = Absorption_Amount
---@field Inactive_Pollution_Absorbers {} k = ID, v = Absorption_Amount

---@class Pollution_Absorbers
---@field ID int
---@field Entity LuaEntity
---@field Surface int = surface_index
---@field Pollution_Absorption_Amount int
---@field Active boolean
---@field Inactivity_Reason int 1 = too little pollution, 2 = too close to another machine -1 = unknown

---@class Poll
---@field Last_Train_Stop (uint)
---@field Last_Train (uint)
---@field Tick (uint) - init to 1, then get advanced once every time a poll occurs

---@class Settings
