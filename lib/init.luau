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

type ValidateCallback<T> = ((key: string, entry: T) -> ())

export type Registry<T> = {
	_items: {[string]: T},

	Get: (self: Registry<T>, name: string) -> T,
	Exists: (self: Registry<T>, name: string) -> boolean,
	GetAll: (self: Registry<T>) -> {[string]: T},
	GetRandom: (self: Registry<T>, weights: {[string]: number}?, rng: Random?) -> T,
	
	CreateQuery: (self: Registry<T>) -> RegistryQuery<T>
}

export type RegistryQuery<T> = {
	_registry: Registry<T>,
	_filters: { 
		{path: {string}, predicate: (any) -> boolean} 
	},

	-- chainable methods
	GreaterThan: (self: RegistryQuery<T>, path: {string}, value: number) -> RegistryQuery<T>,
    LessThan: (self: RegistryQuery<T>, path: {string}, value: number) -> RegistryQuery<T>,
    Exact: (self: RegistryQuery<T>, path: {string}, value: any) -> RegistryQuery<T>,
    Where: (self: RegistryQuery<T>, predicate: (item: T) -> boolean) -> RegistryQuery<T>,

	Query: (self: RegistryQuery<T>) -> {[string]: T},
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
	@param rng Random?
	@return T

	Selects a random value from the registry.

	If `weights` is provided, it is used to perform weighted random
	selection, where higher weights increase the likelihood of being chosen.
	Items not present in the weights table default to a weight of `0`
	and will never be selected.

	If `weights` is omitted, all registry items are treated as having
	equal weight (`1`).

	You may pass `rng` to use a custom `Random` object for randomness.

	Throws an error if the registry is empty, if the total weight is zero,
	or if any weight is negative.
]=]
local function GetRandom<T>(
	self: Registry<T>,
	weights: {[string]: number}?,
	rng: Random?
): T
	rng = rng or Random.new()

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

	local roll = (rng :: Random):NextNumber(0, totalWeight)
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

function RegistryFactory.fromModules<T>(
	parent: Instance,
	recursive: boolean?,
	validate: ValidateCallback<T>?
): Registry<T>
	local module_instances: {Instance}

	recursive = recursive or true

	if recursive then
		module_instances = parent:GetDescendants()
	else
		module_instances = parent:GetChildren()
	end

	local data: {[string]: T} = {}
	for _,module in module_instances do
		if not module:IsA("ModuleScript") then continue end
		
		local entry = (require :: any)(module)

		data[module.Name] = entry
	end

	return RegistryFactory.fromTable(data, validate)
end

-- Helper to get a nested value from a table by path
local function getNestedValue(item: any, path: {string})
	local value = item
	for _, key in path do
		if type(value) ~= "table" then
			return nil
		end
		value = value[key]
	end
	return value
end

local function CreateQuery<T>(self: Registry<T>): RegistryQuery<T>
	local query: RegistryQuery<T> = {} :: any -- cast to satisfy Luau strict

	query._registry = self
	query._filters = {}

	-- selene: allow(shadowing)
	function query:GreaterThan(path: {string}, threshold: number): RegistryQuery<T>
		table.insert(query._filters, {
			path = path,
			predicate = function(val)
				if type(val) ~= "number" then return false end
				return val > threshold
			end,
		})
		return query
	end

	-- selene: allow(shadowing)
	function query:LessThan(path: {string}, threshold: number): RegistryQuery<T>
		table.insert(query._filters, {
			path = path,
			predicate = function(val)
				if type(val) ~= "number" then return false end
				return val < threshold
			end,
		})
		return query
	end

	-- selene: allow(shadowing)
	function query:Exact(path: {string}, target: any): RegistryQuery<T>
		table.insert(query._filters, {
			path = path,
			predicate = function(val)
				return val == target
			end,
		})
		return query
	end

	-- selene:allow(shadowing)
	function query:Where(predicate: (item: T) -> boolean): RegistryQuery<T>
		table.insert(query._filters, {
			path = {},
			predicate = function(value)
				return predicate(value)  -- now 'value' is the item
			end,
		})
		return query
	end


	-- selene:allow(shadowing)
	function query:Query(): {[string]: T}
		local results: {[string]: T} = {}

		for key, entry in query._registry:GetAll() do
			local pass = true
			for _, filter in query._filters do
				local value = if #filter.path > 0 then getNestedValue(entry, filter.path) else entry
				if not filter.predicate(value) then
					pass = false
					break
				end
			end
			if pass then
				results[key] = entry
			end
		end

		return results
	end

	return query
end

--[=[
	@function fromTable
	@within RegistryFactory

	@param folder Instance
	@param validate ((key: string, data: T) -> ())?
	@return Registry<T>

	Creates a new registry by using a table with keys and values.

	The optional `validate` callback is invoked once per module and
	may throw an error if the module's exported data is invalid.
]=]
function RegistryFactory.fromTable<T>(
	data: {[string]: T},
	validate: ValidateCallback<T>?
): Registry<T>
	local items: {[string]: T} = {}

	for key, entry in data do
		if validate then
			validate(key, entry)
		end

		assert(items[key] == nil, "Duplicate Registry entry: " .. key)
		items[key] = entry
	end

	return {
		_items = items,

		Get = Get,
		Exists = Exists,
		GetAll = GetAll,
		GetRandom = GetRandom,

		CreateQuery = CreateQuery
	}
end

return RegistryFactory
