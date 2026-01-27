local ServerScriptService = game:GetService("ServerScriptService")
local example_types = require(ServerScriptService.Demo.example_types)

return {
    Name = "Goblin",
    Description = "A small, mischievous creature.",
    Health = 50,
    AttackPower = 10,
} :: example_types.EnemyData