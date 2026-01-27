local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RegistryFactory = require(ReplicatedStorage.RegistryFactory)

local example_types = require(ServerScriptService.Demo.example_types)

return RegistryFactory.Create(ServerScriptService.Demo.example_data.enemies) :: RegistryFactory.Registry<example_types.EnemyData>