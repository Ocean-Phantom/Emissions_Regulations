local migrate = require("__flib__.migration")

---@param MigrationsTable
local migration_data = {
}


function on_configuration_changed(event)
    setup_globals() --rebuild all the lists in case a new air purifier type was added/removed. There's nothing we need to keep, so it's safe

    -- migrate.on_config_changed(event, migration_data)
end