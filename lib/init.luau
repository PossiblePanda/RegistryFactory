--!strict
--[=[
	@class RegistryFactory
	A fully type-safe module for creating registries of data in Roblox Luau.

	For more information, see:
	https://github.com/PossiblePanda/RegistryFactory
]=]

local RegistryFactory = {}

--[=[
	@class Registry<T>
	@within RegistryFactory

	A generic, read-only registry mapping string names to values of type `T`.

	Registries are created via `RegistryFactory.Create` and expose
	methods for safe lookup and enumeration.
]=]
export type Registry<T> = {
	_items: {[string]: T},

	Get: (self: Registry<T>, name: string) -> T,
	Exists: (self: Registry<T>, name: string) -> boolean,
	GetAll: (self: Registry<T>) -> {[string]: T},
	GetRandom: (self: Registry<T>, weights: {[string]: number}?, seed: number?) -> T,
}

--[=[
	@method Get
	@within Registry

	@param name string
	@return T

	Retrieves a value from the registry by name.

	Throws an error if the name does not exist.
]=]
local function Get<T>(self: Registry<T>, name: string): T
	local item = self._items[name]
	assert(item ~= nil, "Unknown module name: " .. name)
	return item
end

--[=[
	@method Exists
	@within Registry

	@param name string
	@return boolean

	Returns true if a value exists in the registry for the given name.
]=]
local function Exists<T>(self: Registry<T>, name: string): boolean
	return self._items[name] ~= nil
end

--[=[
	@method GetAll
	@within Registry

	@return {[string]: T}

	Returns a map containing all registered values.
	The returned table should be treated as read-only.
]=]
local function GetAll<T>(self: Registry<T>): {[string]: T}
	return self._items
end

--[=[
	@method GetRandom
	@within Registry

	@param weights {[string]: number}?
	@param seed number?
	@return T

	Selects a random value from the registry.

	If `weights` is provided, it is used to perform weighted random
	selection, where higher weights increase the likelihood of being chosen.
	Items not present in the weights table default to a weight of `1`.

	If `weights` is omitted, all registry items are treated as having
	equal weight.

	If `seed` is provided, the selection is deterministic.
	If `seed` is omitted, a random seed is used.

	Throws an error if the registry is empty or if any weight is less than
	or equal to zero.
]=]
local function GetRandom<T>(
	self: Registry<T>,
	weights: {[string]: number}?,
	seed: number?
): T
	local rng = if seed ~= nil then Random.new(seed) else Random.new()

	local totalWeight = 0
	for name in self._items do
		local weight
		if weights == nil then
			weight = 1
		else
			weight = weights[name] or 0
		end

		assert(weight >= 0, "Weight must be >= 0 for item: " .. name)
		totalWeight += weight
	end

	assert(totalWeight > 0, "Cannot pick random item from registry with zero total weight")

	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0

	for name, item in self._items do
		local weight = if weights == nil then 1 else (weights[name] or 0)
		cumulative += weight

		if roll <= cumulative then
			return item
		end
	end

	error("Failed to select random registry item")
end


--[=[
	@function Create
	@within RegistryFactory

	@param folder Instance
	@param validate ((data: T, module: ModuleScript) -> ())?
	@return Registry<T>

	Creates a new registry by requiring all `ModuleScript` children
	of the given folder.

	The optional `validate` callback is invoked once per module and
	may throw an error if the module's exported data is invalid.
]=]
function RegistryFactory.Create<T>(
	folder: Instance,
	validate: ((data: T, module: ModuleScript) -> ())?
): Registry<T>
	local items: {[string]: T} = {}

	for _, module in folder:GetChildren() do
		if not module:IsA("ModuleScript") then
			continue
		end

		local data = require(module) :: T
		if validate then
			validate(data, module)
		end

		local name = module.Name
		assert(items[name] == nil, "Duplicate module name: " .. name)
		items[name] = data
	end

	return {
		_items = items,

		Get = Get,
		Exists = Exists,
		GetAll = GetAll,
		GetRandom = GetRandom
	}
end

return RegistryFactory
