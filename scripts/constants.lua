SPECIAL_CASES={
    ["better-air-filtering"]={
        ENTITY_NAMES = {"air-filter-machine-1", "air-filter-machine-2", "air-filter-machine-3"},
        RECIPE_INFO = {
            ["filter-air"] = {pollution_removal_amount = -2, energy = 1},
            ["filter-air2"] = {pollution_removal_amount = -20, energy = 5},
            ["filter-air-expendable"] = {pollution_removal_amount = -10, energy = 3},
            ["liquid-pollution"] = {pollution_removal_amount = -6, energy = 1}
        }
    },
    ["bery0zas-pure-it"] = {
        ENTITY_NAMES = {"bery0zas-air-suction-tower-1", "bery0zas-air-suction-tower-2", "bery0zas-air-suction-tower-3"},
        RECIPE_INFO = {
            ["bery0zas-air-suction"] = {pollution_removal_amount = -1, energy = 1}
        }
    }
}

MATH_E = 2.71828