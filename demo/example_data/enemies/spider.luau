local ServerScriptService = game:GetService("ServerScriptService")
local example_types = require(ServerScriptService.Demo.example_types)

return {
    Name = "Spider",
    Description = "A creature that spins webs.",
    Health = 50,
    AttackPower = 10,
}  :: example_types.EnemyData