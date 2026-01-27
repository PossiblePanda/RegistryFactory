local ServerScriptService = game:GetService("ServerScriptService")
local example_types = require(ServerScriptService.Demo.example_types)

return {
    Name = "Pickaxe",
    Description = "A tool for mining.",
    Damage = 5,
    Durability = 150,
} :: example_types.ItemData