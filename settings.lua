data:extend({
    {
        type = "string-setting",
        name = "Pollution_Absorption_Limit_Type",
        order = "aa",
        setting_type = "runtime-global",
        allowed_values = {"Linear", "Exponential", "Logistic"},
        default_value = "Linear"
    },
    {
        type = "bool-setting",
        name = "Limit_Distance",
        order = "ba",
        setting_type = "runtime-global",
        default_value = false,
    },
    {
        type = "int-setting",
        name = "Max_Linear_Pollution_Absorption",
        order = "ca",
        setting_type = "runtime-global",
        default_value = 60,
        minimum_value = 0,
        maximum_value = 100
    },
    {
        type = "double-setting",
        name = "Exponential_Const_Multiplier",
        order = "da",
        setting_type = "runtime-global",
        default_value = 50000,
        minimum_value = 0,
    },
    {
        type = "double-setting",
        name = "Exponential_Exponent",
        order = "db",
        setting_type = "runtime-global",
        default_value = 2,
        minimum_value = 1,
        maximum_value = 1000
    },
    {
        type = "double-setting",
        name = "Logistic_Limit",
        order = "ea",
        setting_type = "runtime-global",
        default_value = 125000,
        minimum_value = 1
    },
    {
        type = "double-setting",
        name = "Logistic_k",
        order = "eb",
        setting_type = "runtime-global",
        default_value = 2.71828,
        minimum_value = -100,
        maximum_value = 100
    },
    {
        type = "double-setting",
        name = "Logistic_z",
        order = "ec",
        setting_type = "runtime-global",
        default_value = 70000,
        minimum_value = 0,
    },
    {
        type = "int-setting",
        name = "Entities_per_Poll",
        order = "ya",
        setting_type = "runtime-global",
        minimum_value = 1,
        default_value = 5
    },
    {
        type = "int-setting",
        name = "Surface_Poll_Time",
        order = "za",
        setting_type = "runtime-global",
        hidden = true,
        default_value = 2
    }
})