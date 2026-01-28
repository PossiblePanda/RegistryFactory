# What is RegistryFactory?

**RegistryFactory** is a fully type-safe registry module for Roblox Luau that makes it easy to load, validate, and access collections of data defined as `ModuleScript`s.

It’s designed for cases where you want:

* Centralized, validated data
* Fast lookups by name
* Strong static typing
* Clean, predictable APIs

Common use cases include item databases, abilities, configs, resources, and more.

---

## Installation

### Roblox Studio

If you are using Roblox Studio or want to manually import the module, you can get the latest version from the [Releases](https://github.com/PossiblePanda/RegistryFactory/releases) tab, or install it from the **Creator Marketplace / Toolbox**.

### Wally

If you are using Wally, add the following to your `wally.toml`:

```toml
[dependencies]
registryfactory = "possiblepanda/registryfactory@1.0.0"
```

### Pesde

If you are using Pesde, run:

```sh
pesde install possiblepanda/registryfactory@1.0.0
```

---

## Features

* Fully **type-safe**
* Zero runtime dependencies
* Optional per-module validation
* Fast O(1) lookups
* Simple, predictable API

---

## Basic Usage

### Folder Structure

Each registry loads all `ModuleScript`s in a folder:

```
Items
├─ Sword.lua
├─ Shield.lua
└─ Potion.lua
```

Each module should return a value of the same type:

```lua
-- Sword.lua
return {
	Name = "Sword",
	Damage = 25,
}
```

---

### Creating a Registry

```lua
local RegistryFactory = require(path.to.RegistryFactory)

type Item = {
	Name: string,
	Damage: number,
}

local Items = RegistryFactory.Create(script.Items) :: RegistryFactory.Registry<Item>
```

---

### Accessing Data

```lua
local sword = Items:Get("Sword")
print(sword.Damage)

if Items:Exists("Shield") then
	print("Shield exists!")
end

for name, item in Items:GetAll() do
	print(name, item)
end
```

---

## Validation

You can optionally validate each module as it’s loaded.

```lua
local Items = RegistryFactory.Create(
	script.Items,
	function(data: Item, module: ModuleScript)
		assert(type(data.Name) == "string", module.Name .. " is missing Name")
		assert(type(data.Damage) == "number", module.Name .. " is missing Damage")
	end
) :: RegistryFactory.Registry<Item>
```

If validation throws, registry creation will fail immediately.

---

## API

### `RegistryFactory.Create<T>(folder, validate?) -> Registry<T>`

Creates a registry by requiring all `ModuleScript` children of `folder`.

* `folder` — Folder containing `ModuleScript`s
* `validate` *(optional)* — Function called once per module for validation

---

### `Registry<T>`

A read-only registry mapping string names to values of type `T`.

#### `Registry:Get(name: string) -> T`

Returns the value associated with `name`.
Throws if the name does not exist.

#### `Registry:Exists(name: string) -> boolean`

Returns `true` if the registry contains an entry for `name`.

#### `Registry:GetAll() -> { [string]: T }`

Returns the internal map of all registered values.
This table should be treated as read-only.
