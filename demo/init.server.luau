local EnemyRegistry = require(script.registries.EnemyRegistry)
local ItemRegistry = require(script.registries.ItemRegistry)

print("Should print pickaxe data:")
print(ItemRegistry:Get("pickaxe"))

print("Should print false:")
print(ItemRegistry:Exists("non_existent_item"))

print("Should print a list of every item:")
print(ItemRegistry:GetAll())

print("Should print a random item:")
print(ItemRegistry:GetRandom())

print("Should always print pickaxe:")
print(ItemRegistry:GetRandom({
    pickaxe = 1
}))

print("Should error:")
print(EnemyRegistry:Get("non_existent_enemy"))

print("Should print a list of every enemy:")
print(EnemyRegistry:GetAll())