local EnemyRegistry = require(script.registries.EnemyRegistry)
local ItemRegistry = require(script.registries.ItemRegistry)

print("Should print pickaxe data:")
print(ItemRegistry:Get("pickaxe"))

print("Should print false:")
print(ItemRegistry:Exists("non_existent_item"))

print("Should print a list of every item:")
print(ItemRegistry:GetAll())


print("Should error:")
print(EnemyRegistry:Get("non_existent_enemy"))

print("Should print a list of every enemy:")
print(EnemyRegistry:GetAll())