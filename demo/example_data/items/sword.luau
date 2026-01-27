local ServerScriptService = game:GetService("ServerScriptService")
local example_types = require(ServerScriptService.Demo.example_types)

return {
    Name = "Sword",
    Description = "A sharp blade for combat.",
    Damage = 25,
    Durability = 100,
} :: example_types.ItemData