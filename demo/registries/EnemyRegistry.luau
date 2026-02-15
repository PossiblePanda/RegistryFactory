local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RegistryFactory = require(ReplicatedStorage.RegistryFactory)

local example_types = require(ServerScriptService.Demo.example_types)

local Enemies: {
    [string]: example_types.EnemyData
} = {
    ["goblin"] = {
        Name = "Goblin",
        Description = "A small, mischievous creature.",
        Health = 50,
        AttackPower = 10,
    },

    ["spider"] = {
        Name = "Spider",
        Description = "A creature that spins webs.",
        Health = 50,
        AttackPower = 10,
    }
}

return RegistryFactory.fromTable(Enemies) :: RegistryFactory.Registry<example_types.EnemyData>