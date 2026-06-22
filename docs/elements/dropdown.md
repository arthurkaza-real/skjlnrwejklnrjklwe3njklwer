# Dropdown

A picker control that opens a searchable popup list of options when clicked. Supports **single-select** (default) where one option is chosen at a time, or **multi-select** (`Multi = true`) where any number of options toggle on/off independently. The selected value text is shown in the dropdown bar, the value is written to the global `Flags` table under the `Flag` key, and the `Callback` fires on every change. Includes a live case-insensitive search box that filters options by name, and supports premium-lock and disabled overlays.

**Builder:** `Section:Dropdown(Params) -> Dropdown`

### Arguments

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | string | `"Dropdown"` | The dropdown's left-hand label text, also used as the `OptionHolder` popup instance name and as the default `Flag`. Also accepts `Params.name`. |
| `Items` | `table<string>` | `{ }` (empty table) | The initial list of option-value strings to populate. Also accepts `Params.items`. Stored internally as `Dropdown.OptionItems`; after construction each entry is passed to `Dropdown:Add`. Each value serves as both display text and the key in `Dropdown.Options`. |
| `Flag` | string | `Params.Name` or `Params.name` (the Name) | The key under which the current value is stored in `Flags` and registered in `SetFlags`. Also accepts `Params.flag`. Defaults to the Name when omitted (note: it falls back to `Params.Name`/`Params.name`, NOT to the resolved `Dropdown.Name`, so if `Name` was omitted entirely the `Flag` is `nil`). |
| `MaxSize` | number | `250` | The pixel height the open `OptionHolder` popup is sized to when opened. Also accepts `Params.maxsize`. |
| `Default` | string \| `table<string>` | `""` (empty string) | The initial selection, applied via `Dropdown:Set(Default)` at the very end of construction. Also accepts `Params.default`. For single-select pass a string matching an option; for `Multi = true` pass a table (array) of option strings. The default empty string is not an existing option, so `Set` returns early and nothing is selected. |
| `Multi` | boolean | `false` | When `false` (default) the dropdown is single-select. When `true` it is multi-select: `Dropdown.Value` becomes an array, `Default` should be a table, options toggle independently, the `Flag` stores the array, and the displayed text is the selected names joined by `", "`. Also accepts `Params.multi`. |
| `Premium` | boolean | `false` | When `true`, builds a premium overlay on `DropdownBackground` (`BuildPremiumOverlay`) and locks per-option selection while premium-locked (`IsPremiumLocked` / `IsLockedOrDisabled`). Also accepts `Params.premium`. Toggle later with `Dropdown:UpdatePrem`. |
| `Disabled` | boolean | `false` | When `true`, builds a disabled overlay (`BuildDisabledOverlay`) and blocks `Set`/`SetOpen` via `IsLockedOrDisabled`. Read from the first truthy of `Params.Disable`, `Params.disable`, `Params.Disabled`, `Params.disabled` (defaults to `false`). Toggle later with `Dropdown:UpdateDisable`. |
| `Callback` | function | `function() end` (no-op) | Invoked via `Library:SafeCall` on every selection change with the current `Dropdown.Value`. Also accepts `Params.callback`. Single-select: receives the selected string (or `nil` when deselected). Multi-select: receives the array of selected strings. |
| `Parent` | object | `Dropdown.Section.Items["Content"]` | Optional explicit parent wrapper object (must have an `.Instance`) to host the dropdown frame instead of the owning Section's content. When provided, the dropdown is excluded from auto-close-others behavior, from page-search registration, and from the off-screen-clip `AbsolutePosition` reposition handler. No lowercase alias. |

### Methods

- `Dropdown:Set(Value)` — Programmatically sets the selection and fires the `Callback`. Returns early if `IsLockedOrDisabled`. **Multi-select** (`Multi = true`): `Value` MUST be a table (non-tables return early); sets `Dropdown.Value = Value`, marks each listed existing option `IsSelected` and `ToggleState("Active")`, writes the table to `Flags`, and shows the names joined by `", "`. **Single-select**: returns early unless `Value` is an existing option name; sets `Dropdown.Value = Value` (the string), marks that option `Active` and all others `Inactive`, writes the string to `Flags`, and shows it as the value text. Finally calls `Library:SafeCall(Dropdown.Callback, Dropdown.Value)`.
- `Dropdown:Add(Value)` — Adds a new option whose name and display text are `Value` (string): creates its button row (`Background`/`Button`/`Text`) in the popup, defines `OptionData:ToggleState` and `OptionData:Set`, wires its `MouseButton1Down` click to `OptionData:Set`, stores it in `Dropdown.Options[Value]`, and returns the `OptionData`. Clicking toggles selection (single or multi per `Multi`) and fires the `Callback`. Per-option click is blocked while `IsPremiumLocked`.
- `Dropdown:Remove(Option)` — Removes the option named `Option` (string): destroys its `RealButton` UI instance and deletes `Dropdown.Options[Option]`. No-op if the option does not exist.
- `Dropdown:Refresh(List)` — Removes every current option (calls `Dropdown:Remove` on each existing option's Name) then calls `Dropdown:Add` for every entry in `List` (a table/array of option-name strings), rebuilding the option set. Does **not** reset `Dropdown.Value`.
- `Dropdown:SetText(Text)` — Sets the dropdown's left-hand title label (`Items["Text"]`) to `tostring(Text)`. This changes the **title** label, not the selected-value display.
- `Dropdown:SetVisibility(Bool)` — Shows (`true`) or hides (`false`) the entire dropdown frame via `Items["Dropdown"].Instance.Visible`.
- `Dropdown:UpdatePrem(State)` — Enables (truthy `State`) or disables (falsy) the premium lock at runtime: coerces `State` to boolean, sets `Dropdown.Premium`, and calls `UpdatePremiumOverlay(Items, "DropdownBackground", IsEnabled, Dropdown)`.
- `Dropdown:UpdateDisable(State)` — Enables (truthy `State`) or disables (falsy) the disabled state at runtime: coerces `State` to boolean, sets `Dropdown.Disabled`, and calls `UpdateDisabledOverlay(Items, "DropdownBackground", IsEnabled, Dropdown)`. While disabled, `Set` and `SetOpen` are blocked by `IsLockedOrDisabled`.
- `Dropdown:SetOpen(Bool)` — Opens (`true`) or closes (`false`) the option popup. Returns early if `IsLockedOrDisabled` or while a debounce is active. Sets `Dropdown.IsOpen = Bool`. Opening: rotates the arrow, positions/sizes the `OptionHolder` under the bar (height = `Dropdown.MaxSize`), reparents it to `Library.Holder`, fades it in, starts a `RenderStepped` connection to track the bar position, registers in `Library.OpenFrames`, and (unless a custom `Params.Parent` was given) closes all other open dropdowns. Closing: rotates arrow back, fades out, reparents `OptionHolder` to `Library.UnusedHolder`, clears the `Library.OpenFrames` entry, and disconnects the `RenderStepped` tracker. Also adjusts `ZIndex` of non-UI descendants.

### Callback

Called via `Library:SafeCall(Dropdown.Callback, Dropdown.Value)` on every change (from `Dropdown:Set` and from per-option `OptionData:Set`). **Single-select**: the selected option name (string), or `nil` when the currently selected option is clicked off (deselected). **Multi-select** (`Multi = true`): the array (table) of currently selected option-name strings (may be empty).

### Returns

Returns the `Dropdown` object via `setmetatable(Dropdown, Library)`, inheriting the Library builder API. Registers a setter `SetFlags[Dropdown.Flag] = function(Value) Dropdown:Set(Value) end`, and (via `Set` being called at construction) populates `Flags[Dropdown.Flag]`. Also calls `TrackWindowPremiumControl(Dropdown)`. The object holds `Dropdown.Value` (initialized to `{}`, becomes a string in single mode / array in multi mode), `Dropdown.Options` (map of name → `OptionData`), `Dropdown.IsOpen` (boolean), `Dropdown.OptionItems` (the initial Items list), `Dropdown.MaxSize`, `Dropdown.Multi`, `Dropdown.Premium`, `Dropdown.Disabled`, and `Dropdown.Items` (internal UI instances).

### Gotchas

> `Multi = true` changes the value model: `Dropdown.Value` is an array of names, `Default` should be a table, the `Flag` stores the array, displayed text is the selected names joined by `", "`, and clicking options toggles them independently. `Multi = false` (default) stores a single string; clicking the already-selected option again deselects it (`Dropdown.Value` and `Flags[Flag]` become `nil`, displayed text becomes `"..."`).

- `Dropdown.Value` is initialized to an empty table `{}` at construction (before any `Set`), regardless of `Multi` mode.
- `Dropdown:Set` in multi mode silently ignores a non-table `Value` (returns early); in single mode it silently ignores a value that is not an existing option key.
- **Important:** `Dropdown:Set` in multi mode marks listed options `Active` but does NOT deactivate options no longer in the list; clicking (`OptionData:Set`) toggles correctly via `table.find`/`remove`. Use `Set` on a fresh dropdown or be aware previously-active rows may remain visually active.
- The `Flag` default is `Params.Name`/`Params.name` (the raw param), so if `Name` is also omitted, `Flag` is `nil`; otherwise omitting `Flag` registers under the Name key in both `Flags` and `SetFlags`.
- A built-in search box (`Items["Input"]`) filters option visibility by case-insensitive substring match of each option Name against the typed text on every Text change.
- Premium and Disabled each render an overlay and gate interaction: `IsLockedOrDisabled` blocks `Set`/`SetOpen`; `IsPremiumLocked` blocks per-option `OptionData:Set` selection.
- Passing `Params.Parent` opts the dropdown out of auto-closing other dropdowns, out of page-search (`SearchItems`) registration, and out of the `AbsolutePosition` off-screen-clip reposition handler.
- Clicking the bar (`Items["RealDropdown"]`) toggles open/closed; clicking outside the `OptionHolder` (via `UserInputService.InputBegan`) closes it when open.
- `Dropdown:Set(Dropdown.Default)` is invoked at the end of construction, so the default empty-string single-select default selects nothing.

### Example

```lua
-- Single-select dropdown
local Mode = Section:Dropdown({
    Name = "Aim Mode",
    Items = { "Closest", "Crosshair", "Random" },
    Default = "Closest",
    Flag = "AimMode",
    Callback = function(value)
        print("Selected:", value) -- string or nil
    end,
})

Mode:Set("Crosshair")
Mode:Refresh({ "Closest", "Crosshair" })

-- Multi-select dropdown
local Targets = Section:Dropdown({
    Name = "Target Parts",
    Items = { "Head", "Torso", "Legs" },
    Multi = true,
    Default = { "Head", "Torso" },
    MaxSize = 200,
    Callback = function(values)
        print("Selected:", table.concat(values, ", ")) -- table
    end,
})

Targets:Set({ "Head" })
Targets:UpdateDisable(true)
```

---

**See also:** [Colorpicker](./colorpicker.md) · [Keybind](./keybind.md) · [Picker overview](../pickers.md) · [Theming](../theming.md) · [Config & Flags](../config-and-flags.md) · [API Reference](../api-reference.md) · [Index](../../README.md)
